#!/bin/zsh
# Read-only space survey of a Mac. It never deletes, moves or changes anything.
# Usage: zsh scansione.sh --livello 1|2 [--output FILE]
emulate -L zsh
setopt null_glob

level=1
output=""
while (( $# > 0 )); do
  case "$1" in
    --livello) level="${2:-}"; shift 2 ;;
    --output) output="${2:-}"; shift 2 ;;
    *) print -u2 -- "Opzione sconosciuta: $1"; exit 2 ;;
  esac
done
if [[ "$level" != 1 && "$level" != 2 ]]; then
  print -u2 -- "Uso: zsh scansione.sh --livello 1|2 [--output FILE]"
  exit 2
fi
if [[ "$(uname -s)" != Darwin ]]; then
  print -u2 -- "Questa scansione funziona solo su macOS."
  exit 3
fi

script_dir="${0:A:h}"
[[ -n "$output" ]] || output="$HOME/analisi-spazio-mac/$(date +%Y-%m-%d)/scansione-livello-$level.txt"
mkdir -p "${output:h}"
: > "$output"
exec 3>&1 1>>"$output" 2>/dev/null

data_volume="/System/Volumes/Data"
[[ -d "$data_volume" ]] || data_volume="/"

section() { print -r -- ""; print -r -- "=== $1"; }

# Input lines: "<kilobytes><TAB><path>". Output: size in GB and a path shortened to ~.
format_sizes() {
  awk -F'\t' -v home="$HOME" '{
    path = $2
    if (index(path, home) == 1) path = "~" substr(path, length(home) + 1)
    printf "%8.1f GB  %s\n", $1 / 1048576, path
  }'
}

measure_path() {
  [[ -e "$1" ]] || return 0
  du -xsk "$1" 2>/dev/null
}

list_children() {
  du -xk -d 1 "$1" 2>/dev/null | sort -rn | head -n "$2" | format_sizes
}

section "SISTEMA"
print -r -- "Data: $(date '+%d/%m/%Y %H:%M')"
print -r -- "macOS: $(sw_vers -productVersion)"
print -r -- "Modello: $(sysctl -n hw.model)"
print -r -- "Acceso da: $(uptime | sed -E 's/.*up +//; s/, *[0-9]+ users?.*//')"
df -k "$data_volume" | tail -1 | awk '{
  printf "Disco interno: %.0f GB totali, %.0f GB occupati, %.1f GB liberi (%s pieno)\n",
         $2 / 1048576, $3 / 1048576, $4 / 1048576, $5
}'
if xcode-select -p >/dev/null 2>&1; then
  print -r -- "Strumenti da sviluppatore: presenti (Python usabile)"
else
  print -r -- "Strumenti da sviluppatore: assenti (non lanciare python3: aprirebbe una finestra di installazione)"
fi
if ls "$HOME/Library/Mail" >/dev/null 2>&1; then
  print -r -- "Accesso completo al disco: si"
else
  print -r -- "Accesso completo al disco: no (Mail, Messaggi, Foto e dati delle app non si misurano)"
fi

section "COPIE DI SISTEMA"
print -r -- "Istantanee locali di Time Machine: $(tmutil listlocalsnapshots / | grep -c 'com.apple')"
destinations=$(tmutil destinationinfo | grep -cE '^Name')
print -r -- "Dischi Time Machine configurati: ${destinations:-0}"
latest=$(tmutil latestbackup | tail -1)
[[ "$latest" == /* ]] && print -r -- "Ultimo backup: $latest"

section "DISCHI COLLEGATI"
for volume in /Volumes/*; do
  [[ -L "$volume" ]] && continue
  free_gb=$(df -k "$volume" | tail -1 | awk '{printf "%.0f", $4 / 1048576}')
  format=$(diskutil info "$volume" | sed -n 's/.*File System Personality: *//p')
  print -r -- "${volume:t}: $free_gb GB liberi, formato ${format:-rete o sconosciuto}"
done

section "CLOUD"
quota=$(brctl quota | head -1 | awk '$1 ~ /^[0-9]+$/ {printf "%.0f GB liberi", $1 / 1000000000}')
print -r -- "iCloud: ${quota:-spazio non leggibile}"
osascript -l JavaScript "$script_dir/stato_icloud.js" --solo-cartella "$HOME/Documents" "$HOME/Desktop"
for provider in "$HOME"/Library/CloudStorage/*; do
  print -r -- "Servizio cloud collegato: ${provider:t}"
done

section "PUNTI CALDI (peso apparente, da verificare)"
hot_spots=(
  "$HOME/Downloads" "$HOME/Desktop" "$HOME/Documents" "$HOME/Movies" "$HOME/Music" "$HOME/Pictures"
  "$HOME/Library/Caches" "$HOME/Library/Logs"
  "$HOME/Library/Developer/Xcode/DerivedData" "$HOME/Library/Developer/Xcode/iOS DeviceSupport"
  "$HOME/Library/Developer/Xcode/watchOS DeviceSupport" "$HOME/Library/Developer/Xcode/Archives"
  "$HOME/Library/Developer/CoreSimulator/Devices"
  "$HOME/Library/Application Support/MobileSync/Backup"
  "$HOME/Library/Application Support/Claude/vm_bundles"
  "$HOME/.npm/_cacache" "$HOME/.npm/_npx" "$HOME/.cache" "$HOME/.gradle" "$HOME/.m2" "$HOME/.cargo"
  "$HOME/.pub-cache" "$HOME/.cocoapods" "$HOME/.docker" "$HOME/.ollama" "$HOME/.lmstudio"
  "$HOME/.conda" "$HOME/miniconda3" "$HOME/anaconda3" "$HOME/.nvm" "$HOME/.rustup" "$HOME/.pyenv"
  "$HOME/.pnpm-store" "$HOME/Library/pnpm" "$HOME/.bun" "$HOME/.yarn"
)
for target in "${hot_spots[@]}"; do measure_path "$target"; done | awk -F'\t' '$1 >= 104858' | sort -rn | format_sizes

if [[ "$level" == 1 ]]; then
  section "FINE"
  print -u3 -r -- "Risultato in: $output"
  exit 0
fi

section "CASA"
home_sizes=$(du -xk -d 1 "$HOME" 2>/dev/null | sort -rn)
print -r -- "$home_sizes" | head -n 41 | format_sizes

section "LIBRERIA"
list_children "$HOME/Library" 15
section "SUPPORTO APP"
list_children "$HOME/Library/Application Support" 15
section "CACHE APP"
list_children "$HOME/Library/Caches" 12

section "FUORI DALLA CASA"
list_children "/Applications" 21
for folder in /Library /opt/homebrew /usr/local /Users/Shared /private/var; do
  [[ -d "$folder" ]] && list_children "$folder" 5
done

section "PESI APPARENTI NOTI (quasi sempre molto meno del valore mostrato)"
find /private/var/folders -maxdepth 5 -type d -name '*code_sign_clone' -print0 2>/dev/null \
  | xargs -0 du -sk 2>/dev/null | sort -rn | format_sizes

section "FILE GRANDI (spazio occupato davvero, oltre 1 GB)"
find "$HOME" -xdev \( -path "$HOME/Library/Developer/CoreSimulator" -o -path "$HOME/.Trash" \) -prune \
  -o -type f -size +1G -exec stat -f '%b%t%Sm%t%N' -t '%m/%Y' {} + 2>/dev/null \
  | awk -F'\t' -v home="$HOME" '$1 > 0 {
      path = $3
      if (index(path, home) == 1) path = "~" substr(path, length(home) + 1)
      printf "%d\t%8.1f GB  %s  %s\n", $1, $1 * 512 / 1073741824, $2, path
    }' | sort -rn | cut -f2- | head -n 30

section "LAVORI DI SVILUPPO"
find "$HOME" -xdev \( -path "$HOME/Library" -o -path "$HOME/.Trash" -o -path "$HOME/.npm" -o -path "$HOME/.cache" \) -prune \
  -o -type d \( -name node_modules -o -name '.build*' -o -name .venv -o -name venv -o -name .next -o -name Pods \) -print0 -prune 2>/dev/null \
  | xargs -0 du -sk 2>/dev/null | sort -rn > "${output:r}-sviluppo.tmp"
awk -F'\t' '{ count += 1; total += $1 } END { printf "Cartelle trovate: %d, peso apparente %.1f GB\n", count, total / 1048576 }' "${output:r}-sviluppo.tmp"
head -n 25 "${output:r}-sviluppo.tmp" | format_sizes
rm -f "${output:r}-sviluppo.tmp"

section "CARTELLE DELLA CASA OLTRE 1 GB: ULTIMA MODIFICA (dice se e' cambiata, non se viene letta)"
print -r -- "$home_sizes" | sed 1d | head -n 30 | while IFS=$'\t' read -r kilobytes folder; do
  (( kilobytes >= 1048576 )) || continue
  if find "$folder" -xdev -type f -mtime -90 ! -name '.DS_Store' -print -quit 2>/dev/null | grep -q .; then
    state="modificata negli ultimi 90 giorni"
  else
    state="nessuna modifica da oltre 90 giorni"
  fi
  printf '%s\t%s  [%s]\n' "$kilobytes" "$folder" "$state"
done | format_sizes

section "APP FERME DA OLTRE UN ANNO (oltre 200 MB)"
cutoff=$(date -v-1y +%Y-%m-%d)
for app in /Applications/*.app; do
  last_used=$(mdls -raw -name kMDItemLastUsedDate "$app" 2>/dev/null)
  [[ "$last_used" == "(null)" ]] && last_used=""
  [[ -n "$last_used" && "${last_used:0:10}" > "$cutoff" ]] && continue
  kilobytes=$(du -sk "$app" 2>/dev/null | cut -f1)
  (( ${kilobytes:-0} >= 204800 )) || continue
  printf '%s\t%s  [ultimo uso registrato: %s]\n' "$kilobytes" "${app:t}" "${last_used:0:10}"
done | sort -rn | head -n 15 | format_sizes

section "CONTI"
used_kb=$(df -k "$data_volume" | tail -1 | awk '{print $3}')
home_kb=$(print -r -- "$home_sizes" | head -1 | cut -f1)
apps_kb=$(du -xsk /Applications 2>/dev/null | cut -f1)
other_kb=0
for folder in /Library /opt/homebrew /usr/local /Users/Shared /private/var; do
  if [[ -d "$folder" ]]; then
    size=$(du -xsk "$folder" 2>/dev/null | cut -f1)
    other_kb=$(( other_kb + ${size:-0} ))
  fi
done
measured_kb=$(( ${home_kb:-0} + ${apps_kb:-0} + other_kb ))
awk -v used="$used_kb" -v measured="$measured_kb" 'BEGIN {
  printf "Occupato secondo il disco: %.0f GB\n", used / 1048576
  printf "Misurato cartella per cartella: %.0f GB (comprende i pesi apparenti)\n", measured / 1048576
  printf "Differenza: %.0f GB\n", (used - measured) / 1048576
}'

section "FINE"
print -u3 -r -- "Risultato in: $output"
