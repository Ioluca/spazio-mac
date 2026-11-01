# Livello 4: esecuzione

Si arriva qui solo dopo che la persona ha visto il piano e ha detto sì a uno o più gruppi. Un sì a un gruppo non vale per gli altri, e una voce aggiunta dopo chiede un nuovo sì.

## Prima di ogni gruppo

1. Chiedi alla persona di chiudere le app legate alle voci: un documento aperto in memoria non si vede dall'esterno.
2. Rilancia `zsh scripts/in_uso.sh PERCORSO` su ogni voce. Una voce `IN USO` si salta e si segnala. Con `NON VERIFICABILE` fermati.
3. Annota lo spazio libero con `df -h ~`.
4. Tieni il registro in `~/analisi-spazio-mac/AAAA-MM-GG/esecuzione.log`.

## Gruppo 1: al Cestino

Passa ogni percorso come argomento, tra virgolette, non in un file di testo: un nome con un ritorno a capo si spezzerebbe e potrebbe colpire la cartella sbagliata.

```
zsh scripts/al_cestino.sh "PERCORSO" "ALTRO PERCORSO"
```

Lo script risolve i collegamenti, rifiuta le cartelle principali e quelle protette, registra ogni passo e continua se una voce fallisce. Non usare `rm`, `npm cache clean` o simili: cancellano davvero, senza ritorno.

Quando tieni le compilazioni più recenti, ordina per data di modifica e controlla la lista prima di lanciare il comando.

## Gruppo 2: copia verificata

Lavora in due fasi separate, perché l'originale si tocca solo dopo aver visto il risultato della copia.

**Fase 1, copia e verifica.** Prima controlla che il disco esterno abbia spazio e il formato giusto (`diskutil info PERCORSO`). Crea una cartella dedicata, per esempio `Archivio-Mac`, in modo che sia facile ritrovare tutto. Per ogni voce:

```
zsh scripts/copia_verificata.sh ORIGINALE DESTINAZIONE
```

Lo script copia, confronta byte per byte contenuto, collegamenti e numero di file, poi scrive `OK` o `ERRORE`. Non tocca gli originali e si rifiuta di scrivere su una destinazione che esiste già, perché sovrascriverebbe i file senza ritorno: se fallisce per questo, scegli un nome nuovo. Non confronta permessi e metadati: su un disco non APFS scrive un'avvertenza, e la persona deve saperlo. Lancialo in sottofondo se i dati sono molti. Con più voci, una voce fallita non deve fermare le altre.

**Fase 2, togli gli originali.** Rileggi il risultato. Solo le voci con `OK` vanno passate ad `al_cestino.sh`. Una voce con `ERRORE` resta dov'è e va segnalata.

Lascia al loro posto le cartelle vuote che i programmi si aspettano di trovare, per esempio la cartella dei modelli di LM Studio: sposta il contenuto.

## Gruppo 3: solo copia locale

Prima controlla che non ci siano file non caricati:

```
osascript -l JavaScript scripts/stato_icloud.js PERCORSO
```

Procedi solo se "non caricati" e "stato sconosciuto" sono entrambi zero:

```
osascript -l JavaScript scripts/rimuovi_download.js PERCORSO
```

Se uno dei due è maggiore di zero, non toccare la voce e dillo. "Non caricati" vuol dire che quei file esistono solo sul Mac. "Stato sconosciuto" non vuol dire caricati: vuol dire che non si sa, e se un controllo non dà un sì esplicito non vale come sì. I pacchetti (progetti Camtasia, Final Cut e simili) spesso rifiutano il comando: spiega alla persona come usare "Rimuovi download" nel Finder. Per Dropbox e Google Drive usa la stessa voce del Finder o le opzioni dell'app.

## Dopo

1. Controlla che i programmi legati alle voci toccate partano ancora, se puoi farlo senza interferire.
2. Rilancia `zsh scripts/scansione.sh --livello 1` e confronta con il piano.
3. Scrivi cosa è stato fatto, cosa è stato saltato e perché, dove sta ogni voce spostata e quanto spazio si libererà svuotando il Cestino.
4. Ricorda che il disco esterno è l'unica copia delle voci marcate come tali.

Se qualcosa si rompe, l'originale è ancora nel Cestino: basta rimetterlo a posto con "Rimetti al suo posto" dal Finder.
