#!/bin/zsh
# Report whether a running process visibly uses the given paths. Read-only.
# Usage: zsh in_uso.sh PATH...
# Exit status: 0 no file open, 1 at least one path in use, 2 the check could not run.
# "Nessun file aperto" is not proof that a path is free: an app can hold a document in
# memory without keeping the file open, so the person still has to close the apps.
emulate -L zsh

if (( $# == 0 )); then
  print -u2 -- "Uso: zsh in_uso.sh PERCORSO..."
  exit 2
fi

open_files=$(lsof -n -P 2>/dev/null)
running=$(ps -axo comm=,command= 2>/dev/null)
if [[ -z "$open_files" || -z "$running" ]]; then
  print -r -- "NON VERIFICABILE: elenco dei processi non disponibile"
  exit 2
fi

any_in_use=0
for given in "$@"; do
  target="${given:A}"
  if [[ ! -e "$target" ]]; then
    print -r -- "NON ESISTE: $target"
    continue
  fi
  users=$(print -r -- "$open_files" | grep -F -- "$target" | awk '{print $1}' | sort -u | tr '\n' ' ')
  starters=$(print -r -- "$running" | grep -F -- "$target" | grep -v 'in_uso.sh' | awk '{print $1}' | sed 's|.*/||' | sort -u | tr '\n' ' ')
  if [[ -n "$users$starters" ]]; then
    any_in_use=1
    print -r -- "IN USO: $target (${users}${starters})"
  else
    print -r -- "NESSUN FILE APERTO: $target"
  fi
done

exit $any_in_use
