# Catalogo delle cartelle tipiche

Per ogni voce: cos'è, gruppo e come si libera. "Sposta" vuol dire Gruppo 2. Le voci non presenti qui vanno capite prima di proporle.

## Indice

- Cache e file temporanei
- Sviluppo software
- Apple: iPhone, Xcode, simulatori
- AI locale
- Foto, video e creatività
- Applicazioni
- Cloud
- Aree protette

## Cache e file temporanei

| Percorso | Cos'è | Gruppo | Come si libera | Attenzione |
|---|---|---|---|---|
| `~/Library/Caches/*` | Cache delle app | 1 | Cartelle ferme, al Cestino, una per una | Lascia quelle di app aperte |
| `~/Library/Logs` | Registri degli eventi | 1 | Al Cestino | Di solito pesa poco |
| `/private/var/folders` | Temporanei di sistema | Non toccare | Riavvio del Mac | Spesso è peso apparente |
| `~/.Trash` | Cestino | Decide la persona | Lo svuota lei | Da qui spesso non si misura |

## Sviluppo software

| Percorso | Cos'è | Gruppo | Come si libera | Attenzione |
|---|---|---|---|---|
| `~/.npm/_cacache` | Cache di npm | 1 | Al Cestino | Mai `~/.npm/_npx` |
| `~/.cache/uv` | Cache di uv | 1 | Al Cestino | Solo senza processi attivi; spesso vale metà del peso apparente |
| `~/Library/Caches/pip`, `Homebrew`, `Yarn` | Cache di pacchetti | 1 | Al Cestino | Si riscaricano |
| `~/.gradle/caches`, `~/.cargo/registry`, `~/.pub-cache`, `~/.cocoapods` | Cache di librerie | 1 | Al Cestino | Il primo avvio dopo sarà lento |
| `~/.m2/repository` | Librerie Java | Non toccare | Decide la persona | Può contenere componenti creati a mano, non scaricabili |
| `node_modules` | Librerie di un progetto | 1 | Al Cestino, solo in progetti fermi | Serve un file `package-lock.json` per ricrearle |
| `.build`, `build`, `target`, `.next`, `DerivedData` | Risultati di compilazione | 1 | Tieni le più recenti, il resto al Cestino | Controlla che non sia in corso una compilazione |
| `.venv`, `venv` | Ambienti Python | 1 | Solo in progetti fermi | Servono le dipendenze scritte per ricrearli |
| `~/Library/Containers/com.docker.docker` | Immagini Docker | Non toccare | Dalle impostazioni di Docker | Dentro ci possono essere database |
| `~/.nvm`, `~/.rustup`, `~/.pyenv`, `~/miniconda3`, `~/anaconda3` | Versioni di linguaggi | Non toccare | Solo se la persona sa di non usarle | Possono bloccare progetti |

## Apple: iPhone, Xcode, simulatori

| Percorso | Cos'è | Gruppo | Come si libera | Attenzione |
|---|---|---|---|---|
| `~/Library/Developer/Xcode/DerivedData` | Compilazioni Xcode | 1 | Al Cestino | Solo a Xcode chiuso |
| `~/Library/Developer/Xcode/iOS DeviceSupport` | Dati per ogni versione iOS collegata | 1 | Le versioni vecchie al Cestino | Tieni la versione del telefono in uso |
| `~/Library/Developer/Xcode/Archives` | App archiviate | Non toccare | Decide la persona | Serve per le app pubblicate |
| `~/Library/Developer/CoreSimulator/Devices` | Simulatori | Non toccare | Da Xcode, se la persona lo decide | Cancella per sempre, senza Cestino, anche i dati di prova |
| `~/Library/Application Support/MobileSync/Backup` | Backup di iPhone e iPad | 2 | Sposta intero | Può essere l'unica copia |

## AI locale

| Percorso | Cos'è | Gruppo | Come si libera | Attenzione |
|---|---|---|---|---|
| `~/.ollama/models` | Modelli Ollama | Non toccare | Dall'app, se la persona lo decide | Cancella per sempre e un modello personalizzato non si riscarica |
| `~/.lmstudio/models` | Modelli LM Studio | 2 | Sposta a LM Studio chiuso | Il programma li cerca lì |
| `~/.cache/huggingface` | Modelli scaricati | 2 oppure 1 | Si riscaricano | Possono pesare decine di GB |
| `~/Library/Application Support/Claude/vm_bundles` | Macchina virtuale di Claude Desktop | Non toccare | Dall'app | Non è una cache libera |

## Foto, video e creatività

| Percorso | Cos'è | Gruppo | Come si libera | Attenzione |
|---|---|---|---|---|
| `~/Pictures/*.photoslibrary` | Libreria Foto | Non misurato | Dall'app Foto, "Ottimizza spazio" | Mai a mano |
| `~/Pictures/*` (cartelle) | Foto normali | 2 | Sposta | Controlla i cataloghi Lightroom |
| `*.lrcat` | Catalogo Lightroom | Non toccare | Decide la persona | È un archivio di lavoro |
| `* Previews.lrdata` | Anteprime Lightroom | 1 | Al Cestino, a Lightroom chiuso | Solo le anteprime normali; `Smart Previews.lrdata` può servire se le foto sono su un disco scollegato |
| `Mobile Downloads.lrdata` | **Foto originali** arrivate da Lightroom mobile | Non toccare | Mai | Sembra una cache, ma contiene gli originali |
| `~/Movies/*` | Video e progetti | 2 | Sposta | Controlla i progetti aperti |
| `~/Library/Caches/Adobe*` | Cache Adobe | 1 | Meglio dalle preferenze dell'app | Solo ad app chiusa |
| `~/Music/*` | Musica | 2 | Sposta | La libreria Musica cerca i file lì |

## Applicazioni

| Percorso | Cos'è | Gruppo | Come si libera | Attenzione |
|---|---|---|---|---|
| `/Applications/*.app` | App | Decide la persona | Elenca le app ferme da oltre un anno | Mai le app Apple; le licenze vanno ricordate |
| `~/Library/Application Support/*` | Dati delle app | Non toccare | Solo se l'app è stata tolta | Dentro ci sono dati veri |

## Cloud

| Percorso | Cos'è | Gruppo | Come si libera | Attenzione |
|---|---|---|---|---|
| `~/Documents`, `~/Desktop` con iCloud attivo | File sincronizzati | 3 | "Rimuovi download" | Mai spostarli |
| `~/Library/Mobile Documents` | iCloud Drive | 3 | "Rimuovi download" | Mai toccare la cartella a mano |
| `~/Library/CloudStorage/*` | Dropbox, Google Drive, OneDrive | 3 | "Rimuovi download" dal Finder | Dipende dal servizio |

## Aree protette

Mail (`~/Library/Mail`), Messaggi (`~/Library/Messages`), Foto e `~/Library/Containers` sono chiusi al terminale senza "Accesso completo al disco". Non chiedere di concederlo per una pulizia: basta Impostazioni di Sistema > Generali > Spazio, dove la persona vede i pesi e trova i consigli di Apple. I Messaggi si riducono togliendo gli allegati grandi dall'app, la Mail dall'app stessa.
