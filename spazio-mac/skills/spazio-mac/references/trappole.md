# Trappole

Ogni voce nasce da un errore vero. Rileggile prima di scrivere il piano.

## Il peso che inganna

- **Copie che condividono i dati.** Sul disco dei Mac moderni due copie dello stesso file possono occupare lo spazio di una. `du`, il Finder e molti programmi di pulizia le contano una per una. Il caso tipico è `com.google.Chrome.code_sign_clone` in `/private/var/folders`: si è visto segnare 67 GB per un valore reale di 1,4 GB. Vale per qualunque cartella fatta di copie simili: app, simulatori, ambienti Python. Misura con `spazio_reale.py` e usa solo quel numero. Per le copie di un'app aggiungi `--escludi "/Applications/Nome.app"`, così non conta i dati condivisi con l'app installata.
- **File scaricati solo in apparenza.** Un file iCloud o Dropbox "solo online" mostra la sua dimensione ma occupa zero. `find -size` lo conta. La scansione filtra già questi casi: se usi comandi tuoi, guarda i blocchi occupati e non la dimensione dichiarata.
- **I conti che non tornano.** Se lo spazio occupato supera di molto quello misurato, la differenza sta di solito in aree protette, non in un errore. Dillo. Se è il misurato a superare l'occupato, stai contando delle copie doppie.

## Cose che sembrano cache e non lo sono

- **Cache con programmi vivi dentro.** `~/.npm/_npx` contiene programmi in esecuzione, per esempio i connettori degli assistenti AI: toglierla li può rompere mentre lavorano. Lo stesso vale per i programmi lanciati da `~/.cache/uv`. Di npm si tocca solo `~/.npm/_cacache`. Controlla sempre i processi attivi.
- **Modelli AI.** `~/.ollama`, `~/.lmstudio` e `~/.cache/huggingface` si riscaricano, ma pesano molti GB e riscaricarli costa tempo. Non sono rifiuti: vanno nel Gruppo 2, salvo che la persona non dica di non usarli.
- **Cartelle di compilazione.** Si rigenerano, ma la più recente fa risparmiare ore. Tieni le ultime di ogni progetto.
- **Nomi che sembrano cache.** `Mobile Downloads.lrdata` di Lightroom ha il nome di una cache e contiene foto originali. Davanti a un nome che sembra sacrificabile, guarda cosa c'è dentro prima di classificarlo.
- **Comandi senza ritorno.** `ollama rm`, `xcrun simctl delete`, `npm cache clean`, `brew cleanup` e simili cancellano davvero, senza Cestino. Non proporli come scorciatoia: possono togliere anche dati personali.
- **Backup di iPhone.** In `~/Library/Application Support/MobileSync/Backup` c'è spesso l'unica copia di chat e foto. Si spostano, non si cancellano, e solo se la persona sa cosa sono.

## Spostare può fare danni

- **iCloud.** Spostare un file da Documenti o Scrivania sincronizzati verso un disco esterno lo toglie da iCloud e da tutti i dispositivi. Per liberare spazio basta togliere la copia locale: Gruppo 3. Prima verifica che ogni file sia davvero caricato.
- **Un controllo muto non è un sì.** Conta i "sì" espliciti, non l'assenza di "no". Cercare la parola `false` su uno stato iCloud vuoto dà zero problemi anche quando non si sa nulla: è già successo su migliaia di file. Dentro i pacchetti lo stato non esiste file per file: si legge sul pacchetto intero. Vale per ogni verifica, non solo per iCloud.
- **Pacchetti che sembrano file.** Librerie Foto, progetti Final Cut o Camtasia e cataloghi Lightroom sono cartelle travestite. Non spostarne pezzi e non toccare mai l'interno. Alcuni non si lasciano togliere da iCloud via comando: serve "Rimuovi download" dal Finder.
- **Programmi che ricordano il percorso.** Lightroom, Final Cut e altri trovano i file per indirizzo. Dopo lo spostamento risultano mancanti finché non vengono ricollegati. Se trovi uno di questi programmi, avvisa prima.
- **Copia unica.** Dopo lo spostamento, il disco esterno può essere l'unica copia. Dillo chiaramente, voce per voce. Un disco esterno non è un backup.
- **Formato del disco esterno.** Un disco exFAT o FAT non ha i permessi del Mac, crea file che iniziano con `._` e non accetta file sopra i 4 GB se è FAT32. Controlla prima di copiare.

## Il momento conta

- **La situazione cambia.** Tra perizia ed esecuzione possono partire compilazioni o aprirsi app. Ripeti il controllo d'uso subito prima di agire.
- **Cestino pieno, disco pieno.** Le cose nel Cestino occupano ancora spazio: i numeri migliorano solo quando viene svuotato. Se dopo la pulizia il Mac non migliora, parti da lì.
- **Spazio che macOS si riprende.** Istantanee di Time Machine e spazio "eliminabile" fanno oscillare i numeri tra il Finder e il terminale. Se la scansione trova istantanee locali, lo spazio torna libero solo quando scadono. Non promettere cifre al singolo GB.
- **Fermo non vuol dire inutile.** La data di modifica dice quando un file è cambiato, non quando è stato letto. Un archivio consultato ogni giorno può risultare fermo da anni.
- **Il terminale non vede tutto.** Senza "Accesso completo al disco" Mail, Messaggi, Foto e dati delle app risultano vuoti: quello zero non significa "niente".

## Cose da non proporre

- Cartelle di sistema: `/System`, `/usr`, `/bin`, `/sbin`, `/private/var/db`.
- Svuotare `/private/var/folders` a mano: i file temporanei di sistema si puliscono al riavvio, e un riavvio è la prima cosa da provare.
- Disattivare protezioni di sistema, memoria virtuale o la sospensione per guadagnare spazio.
- Programmi di pulizia a pagamento o trovati in rete.
