#!/bin/zsh
# Move paths to the Trash, so that everything stays recoverable.
# Usage: zsh al_cestino.sh PERCORSO...   (quote each path)
# Paths come as arguments, not from a list file: a name containing a line break
# would split into two entries and could send an unapproved folder to the Trash.
# Only paths inside the home folder are accepted, and never its main folders.
emulate -L zsh

if (( $# == 0 )); then
  print -u2 -- 'Uso: zsh al_cestino.sh "PERCORSO" "ALTRO PERCORSO"'
  exit 2
fi

log_file="$HOME/analisi-spazio-mac/$(date +%Y-%m-%d)/cestino.log"
mkdir -p "${log_file:h}"
home_real="${HOME:A}"
moved=0
refused=0
failed=0

report() { print -r -- "$1" | tee -a "$log_file"; }

# Prints the reason why a path must stay where it is, or nothing when it can go.
refusal_reason() {
  local target="$1" relative
  [[ "$target" == "$home_real"/* ]] || { print -r -- "fuori dalla cartella Inizio"; return; }
  relative="${target#$home_real/}"
  if [[ "$relative" != */* ]]; then
    case "$relative" in
      Library|Documents|Desktop|Downloads|Pictures|Movies|Music|Public|Applications)
        print -r -- "cartella principale"; return ;;
    esac
  fi
  case "$target" in
    *.photoslibrary|*.photoslibrary/*) print -r -- "libreria Foto"; return ;;
    "$home_real/Library/Mail"*|"$home_real/Library/Messages"*|"$home_real/Library/Keychains"*)
      print -r -- "dati protetti"; return ;;
    "$home_real/.ssh"*|"$home_real/.gnupg"*) print -r -- "chiavi di accesso"; return ;;
    "$home_real/.npm/_npx"*) print -r -- "programmi in uso"; return ;;
    "$home_real/Library/Mobile Documents"*) print -r -- "iCloud: va tolto solo dal Mac, non cestinato"; return ;;
    "$home_real/Library/CloudStorage"*) print -r -- "cartella cloud: va tolta solo dal Mac, non cestinata"; return ;;
  esac
  if [[ -d "$target" && ! -L "$target" ]] && find "$target" -maxdepth 4 -name '*.photoslibrary' -print -quit 2>/dev/null | grep -q .; then
    print -r -- "contiene una libreria Foto"
  fi
}

move_to_trash() {
  if [[ -x /usr/bin/trash ]]; then
    /usr/bin/trash "$1" >> "$log_file" 2>&1
  else
    osascript -l JavaScript \
      -e 'ObjC.import("Foundation");' \
      -e 'function run(argv) { var url = $.NSURL.fileURLWithPath(argv[0]); if (!$.NSFileManager.defaultManager.trashItemAtURLResultingItemURLError(url, null, null)) throw new Error("rifiutato"); }' \
      "$1" >> "$log_file" 2>&1
  fi
}

for given in "$@"; do
  if [[ "$given" != /* && "$given" != \~/* ]]; then
    report "RIFIUTATO $given: serve il percorso completo"
    refused=$(( refused + 1 ))
    continue
  fi
  absolute="${given/#\~/$HOME}"
  if [[ ! -e "$absolute" && ! -L "$absolute" ]]; then
    report "MANCA $absolute"
    continue
  fi
  # Resolve the parent, not the last name: a link goes to the Trash as a link, while a
  # protected folder reached through a link in the path is seen for what it really is.
  target="${absolute:h:A}/${absolute:t}"
  reason=$(refusal_reason "$target")
  if [[ -n "$reason" ]]; then
    report "RIFIUTATO $target: $reason"
    refused=$(( refused + 1 ))
    continue
  fi
  if move_to_trash "$target"; then
    report "CESTINO $target"
    moved=$(( moved + 1 ))
  else
    report "ERRORE $target"
    failed=$(( failed + 1 ))
  fi
done

report "Nel Cestino: $moved | Rifiutati: $refused | Errori: $failed"
report "Lo spazio si libera quando svuoti il Cestino."
(( failed == 0 && refused == 0 ))
