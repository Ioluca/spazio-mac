#!/usr/bin/env python3
"""Measure the real disk space of folders, counting files that share blocks only once.

On APFS two clones of a file occupy the space of one, but du counts both. Each file
belongs to a clone family, so summing one member per family gives the real space.

Usage: python3 -I spazio_reale.py PATH... [--escludi PATH]
Blocks that also belong to an --escludi folder are not counted: removing PATH would
not free them. The result is a ceiling: clones outside PATH and local snapshots can
keep blocks alive, and neither can be seen from here. Read-only.
"""
from __future__ import annotations

import argparse
import ctypes
import os
import struct
import sys

ATTR_BIT_MAP_COUNT = 5
ATTR_CMNEXT_CLONEID = 0x00000100
FSOPT_NOFOLLOW = 0x00000001
FSOPT_ATTR_CMN_EXTENDED = 0x00000020
GB = 1024 ** 3
MEANINGFUL_GAP = 0.8


class AttrList(ctypes.Structure):
    _fields_ = [
        ("bitmapcount", ctypes.c_ushort),
        ("reserved", ctypes.c_uint16),
        ("commonattr", ctypes.c_uint32),
        ("volattr", ctypes.c_uint32),
        ("dirattr", ctypes.c_uint32),
        ("fileattr", ctypes.c_uint32),
        ("forkattr", ctypes.c_uint32),
    ]


libc = ctypes.CDLL(None, use_errno=True)


def clone_family(path: str) -> int | None:
    """Return the clone family of a file, or None when the volume does not report it."""
    request = AttrList(ATTR_BIT_MAP_COUNT, 0, 0, 0, 0, 0, ATTR_CMNEXT_CLONEID)
    buffer = ctypes.create_string_buffer(32)
    options = FSOPT_NOFOLLOW | FSOPT_ATTR_CMN_EXTENDED
    if libc.getattrlist(os.fsencode(path), ctypes.byref(request), buffer, 32, options) != 0:
        return None
    return struct.unpack_from("<IQ", buffer.raw, 0)[1]


def walk_files(root: str, errors: list[str]):
    """Yield files under root, recording what could not be read instead of hiding it."""
    if os.path.isfile(root) and not os.path.islink(root):
        yield root, os.lstat(root)
        return
    for folder, _, names in os.walk(root, onerror=lambda error: errors.append(str(error))):
        for name in names:
            path = os.path.join(folder, name)
            try:
                yield path, os.lstat(path)
            except OSError as error:
                errors.append(str(error))


def collect_families(root: str) -> set[int]:
    families: set[int] = set()
    for path, _ in walk_files(root, []):
        family = clone_family(path)
        if family:
            families.add(family)
    return families


def measure(root: str, excluded: set[int], errors: list[str]) -> tuple[int, float, float]:
    seen_inodes: set[int] = set()
    families: dict[int, int] = {}
    apparent = 0
    without_family = 0
    files = 0
    for path, info in walk_files(root, errors):
        if info.st_ino in seen_inodes:
            continue
        seen_inodes.add(info.st_ino)
        allocated = info.st_blocks * 512
        apparent += allocated
        files += 1
        family = clone_family(path)
        if family:
            if family not in excluded:
                families[family] = max(families.get(family, 0), allocated)
        else:
            without_family += allocated
    return files, apparent / GB, (sum(families.values()) + without_family) / GB


def main() -> int:
    parser = argparse.ArgumentParser(description="Misura lo spazio reale delle cartelle.")
    parser.add_argument("paths", nargs="+")
    parser.add_argument("--escludi", action="append", default=[])
    arguments = parser.parse_args()

    excluded: set[int] = set()
    for root in arguments.escludi:
        excluded |= collect_families(os.path.expanduser(root))

    for root in arguments.paths:
        expanded = os.path.expanduser(root)
        if not os.path.exists(expanded):
            print(f"{root} | non esiste")
            continue
        errors: list[str] = []
        files, apparent, real = measure(expanded, excluded, errors)
        if errors:
            verdict = f"INCOMPLETO: {len(errors)} elementi non leggibili, il numero non e' affidabile"
        elif real < apparent * MEANINGFUL_GAP:
            verdict = "PESO APPARENTE: conta il valore massimo"
        else:
            verdict = "peso vero"
        print(f"{root} | {files} file | apparente {apparent:.1f} GB | liberabile al massimo {real:.1f} GB | {verdict}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
