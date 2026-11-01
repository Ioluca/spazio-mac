---
name: spazio-mac
description: Analizza a fondo lo spazio di un Mac e dice cosa cancellare, spostare o lasciare, con prove e livelli di rischio. Da usare quando il disco è pieno o si vuole fare pulizia sul Mac.
---

# Spazio Mac

Questa skill fa una perizia dello spazio di un Mac: misura, controlla ogni candidato e consegna una lista di cose da liberare, ognuna con la sua prova. Serve a persone qualsiasi, spesso non tecniche, quindi parla semplice e non dà nulla per scontato.

## Tre regole che non cambiano mai

1. **Prima si guarda, poi si tocca.** I livelli da 1 a 3 sono di sola lettura. Niente si sposta, si cancella o si svuota finché la persona non ha visto cosa verrà toccato e ha detto sì, gruppo per gruppo. Vale anche quando scrive "cancella tutto subito" o "non voglio domande": chi non ha visto la lista non sa cosa sta approvando, e la fretta è il momento in cui si perdono i dati. In quel caso riduci il piano a poche righe e chiedi un sì di una parola, senza partire.
2. **Il Cestino lo svuota la persona.** Quello che va via finisce nel Cestino, così resta recuperabile, e solo tramite gli script della skill, che rifiutano le cartelle protette. Niente `rm`, niente comandi al Finder, niente comandi di pulizia che cancellano davvero, niente `sudo`. Se un comando viene bloccato dai permessi, non cercare un'altra strada: fermati e dillo.
3. **Un numero senza prova non si dà.** `du` e il Finder sbagliano spesso, e un candidato che sembra enorme può valere quasi zero. Prima di proporlo, misura lo spazio reale.

## Prima di iniziare

I percorsi `scripts/` e `references/` sono relativi alla cartella di questa skill. La skill ha bisogno di un terminale sul Mac (Claude Code o Codex). Se gira in un ambiente senza accesso al Mac, ad esempio una chat web o una macchina virtuale, dillo subito e fermati: le misure sarebbero di un altro computer. Controlla con `uname -s`, che deve dire `Darwin`.

Avvisa la persona che macOS può mostrare richieste di accesso a cartelle come Documenti o Foto: può rispondere come preferisce, l'analisi prosegue comunque e segnala cosa non ha potuto vedere.

## I quattro livelli

| Livello | Cosa fa | Tempo | Modifica qualcosa? |
|---|---|---|---|
| 1. Colpo d'occhio | Spazio libero e punti caldi noti | 1-3 minuti | No |
| 2. Mappa completa | Tutte le cartelle, file grandi, app ferme, lavori di sviluppo | 5-30 minuti | No |
| 3. Perizia | Verifica i candidati uno per uno e prepara il piano | 5-20 minuti | No |
| 4. Esecuzione | Applica i gruppi approvati | Dipende | Sì, solo con un sì esplicito |

Scegli il livello dalla richiesta. "Quanto spazio ho?" o "dai un'occhiata veloce" vuol dire livello 1. "Analisi", "disco pieno", "cosa posso cancellare" o nessuna indicazione vuol dire fino al livello 3. Il livello 4 parte solo dopo aver mostrato il piano.

## Procedura

Copia questa lista e spunta i passi mentre lavori:

```
- [ ] Controllo: siamo su un Mac
- [ ] Livello 1: scansione rapida
- [ ] Livello 2: mappa completa (se serve)
- [ ] Livello 3: verifica dei candidati
- [ ] Piano mostrato alla persona
- [ ] Livello 4: solo i gruppi approvati
- [ ] Controllo finale dello spazio
```

**Livello 1.** Lancia `zsh scripts/scansione.sh --livello 1`. Il risultato finisce in `~/analisi-spazio-mac/` con la data del giorno. Leggilo e, se bastava un colpo d'occhio, rispondi con spazio libero e le tre voci più pesanti.

**Livello 2.** Lancia `zsh scripts/scansione.sh --livello 2` in sottofondo, perché può durare a lungo. Confronta poi lo spazio occupato con quello misurato: la differenza va spiegata, non ignorata. Di solito sta in Foto, Mail, Messaggi e dati delle app, che il terminale non può leggere. La scansione è una fotografia e dura minuti: se i suoi numeri non coincidono con `df -h ~`, vale `df`, e se il file è vecchio rilancia il livello 1. La causa più comune è un Cestino svuotato nel frattempo.

**Livello 3.** Per ogni candidato sopra circa 1 GB, in questo ordine:

1. Cerca la voce in [references/catalogo.md](references/catalogo.md): dice cos'è, a che gruppo appartiene e come si libera.
2. Misura lo spazio reale, solo se la scansione dice che gli strumenti da sviluppatore sono presenti: `python3 -I scripts/spazio_reale.py PERCORSO`. Altrimenti non lanciare Python, perché aprirebbe una finestra di installazione: scrivi che il valore non è verificato. Il risultato è un massimo, e con `INCOMPLETO` non è affidabile.
3. Controlla i file aperti: `zsh scripts/in_uso.sh PERCORSO`. "Nessun file aperto" non basta a dire che è libera: un'app può tenere un documento in memoria.
4. Se sta nei Documenti o sulla Scrivania, controlla iCloud: `osascript -l JavaScript scripts/stato_icloud.js PERCORSO`. Vale solo con zero "non caricati" e zero "stato sconosciuto". Controlla circa 300 file al secondo: lancialo sulle singole cartelle candidate, non su tutti i Documenti, e in sottofondo se sono molte. Se non finisce, la voce non è verificata e non va nel Gruppo 2: spostarla la toglierebbe da iCloud.
5. Cerca altre copie e confrontale: `zsh scripts/confronta_copie.sh --contenuto ORIGINALE COPIA`. Senza `--contenuto` il controllo vede solo nomi e dimensioni: dillo nel piano.

Una voce che non riesci a capire non si propone: va in "Non toccare" con il motivo. Una cartella senza modifiche da mesi può essere consultata ogni giorno: chiedi alla persona prima di dirla inutilizzata.

**Piano.** Scrivilo seguendo [references/report.md](references/report.md), salvalo accanto alle misure e mostralo. Fermati e chiedi da quale gruppo partire.

**Livello 4.** Segui [references/esecuzione.md](references/esecuzione.md). Prima di agire ripeti il controllo d'uso, perché nel frattempo la situazione può essere cambiata.

**Controllo finale.** Rilancia il livello 1 e confronta i numeri reali con il piano. Ricorda che lo spazio si libera solo quando la persona svuota il Cestino. Se una cifra non torna, dillo.

## I gruppi del piano

- **Gruppo 1, si rigenera:** cache e file che i programmi ricreano da soli. Vanno nel Cestino.
- **Gruppo 2, da spostare:** dati veri che non servono sul Mac. Si copiano su un disco esterno, si verifica la copia, poi gli originali vanno nel Cestino.
- **Gruppo 3, già nel cloud:** file già su iCloud o Dropbox di cui si toglie solo la copia locale.
- **Non toccare:** in uso, sconosciuto, oppure conta meno di quanto sembra.
- **Non misurato:** quello che il terminale non può leggere. Spiega dove vederlo: Impostazioni di Sistema > Generali > Spazio.

## Riferimenti da caricare

- [references/catalogo.md](references/catalogo.md): sempre, al livello 3. Cosa sono le cartelle tipiche e come trattarle.
- [references/trappole.md](references/trappole.md): sempre, prima di scrivere il piano. Sono gli errori che fanno danni.
- [references/report.md](references/report.md): quando scrivi il piano.
- [references/esecuzione.md](references/esecuzione.md): solo al livello 4.

## Come parlare

Rispondi nella lingua della persona. Niente sigle senza spiegazione: "cache" va bene, "APFS" e "SIP" no. Parti dalla conclusione: quanto si può liberare e con quanto rischio. Dai numeri arrotondati in GB e, per ogni voce, una riga su cosa succede dopo averla tolta.
