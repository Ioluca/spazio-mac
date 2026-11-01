# Spazio Mac

Il disco del tuo Mac è pieno e non sai cosa puoi togliere senza fare danni?

Spazio Mac è una skill per Claude Code e Codex che fa una vera perizia del tuo disco: misura, controlla ogni voce e ti consegna una lista di cose da liberare, ognuna con la sua prova. Non tocca niente finché non dici sì.

## Cosa fa

| Livello | Cosa ottieni | Tempo |
|---|---|---|
| 1. Colpo d'occhio | Spazio libero e punti caldi | 1-3 minuti |
| 2. Mappa completa | Tutte le cartelle, i file grandi, le app ferme | 5-30 minuti |
| 3. Perizia | Ogni voce verificata e un piano a gruppi | 5-20 minuti |
| 4. Esecuzione | Applica solo i gruppi che hai approvato | Dipende |

Il piano divide tutto in gruppi chiari: cosa si rigenera da solo, cosa conviene spostare su un disco esterno, cosa è già nel cloud e cosa non va toccato.

## Perché fidarsi

- **Prima guarda, poi tocca.** I primi tre livelli non modificano nulla. Niente parte senza il tuo sì, gruppo per gruppo, nemmeno se scrivi "cancella tutto subito".
- **Il Cestino lo svuoti tu.** Quello che va via finisce nel Cestino, così puoi recuperarlo.
- **Misura lo spazio vero.** I programmi di pulizia spesso sbagliano: una cartella che segna 67 GB può valerne 1,4. La skill lo controlla prima di proporla.
- **Protegge iCloud.** Spostare i Documenti sincronizzati li toglierebbe anche dal cloud: la skill toglie solo la copia locale, dopo aver verificato che i file siano stati caricati.
- **Copie verificate.** Prima di togliere un originale, confronta la copia byte per byte.
- **Non si fida dei controlli muti.** Se una verifica non dà un sì esplicito, la voce resta dov'è.

## Installazione

Serve Claude Code o Codex su un Mac. La skill lavora dal terminale: su claude.ai, nell'app web o in una macchina virtuale non può vedere il tuo disco, e infatti si ferma subito.

**Claude Code.** Incolla queste due righe, una alla volta:

```
/plugin marketplace add https://github.com/Ioluca/spazio-mac.git
/plugin install spazio-mac@spazio-mac
```

**Codex.** Nel terminale, un comando alla volta:

```bash
codex plugin marketplace add https://github.com/Ioluca/spazio-mac.git
```

```bash
codex plugin add spazio-mac@spazio-mac
```

**A mano.** [Scarica lo zip](https://github.com/Ioluca/spazio-mac/raw/main/spazio-mac.zip) e scompattalo in `~/.claude/skills/` oppure in `~/.codex/skills/`. Sono cartelle nascoste: nel Finder le vedi con `Cmd + Shift + .`

## Come si usa

Scrivi semplicemente:

- "Il disco è pieno, analizza il Mac e dimmi cosa posso cancellare"
- "Quanto spazio ho? Dai un'occhiata veloce"
- `/spazio-mac`

macOS può chiederti l'accesso ad alcune cartelle: rispondi come preferisci, l'analisi prosegue comunque e ti dice cosa non ha potuto vedere.

## Cosa non fa

- Non svuota il Cestino e non usa comandi che cancellano in modo definitivo.
- Non chiede la password del Mac e non tocca le cartelle di sistema.
- Non è un backup: dopo uno spostamento, il disco esterno può essere l'unica copia. La skill te lo dice voce per voce.
- Non misura Foto, Mail e Messaggi, che macOS protegge. Ti indica dove guardarli: Impostazioni di Sistema > Generali > Spazio.

## Licenza

MIT. Puoi usarla, modificarla e condividerla liberamente. Il software è fornito così com'è: controlla sempre il piano prima di approvarlo.

Creata da [Luca Cazzaniga](https://github.com/Ioluca).
