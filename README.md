# G.Scacco

Blog personale su programmazione e informatica, realizzato come sito statico con [Hugo](https://gohugo.io/).

Il tema è incluso direttamente nel repository, nei template `layouts/` e nello stile `static/css/site.css`; non sono quindi necessari temi o dipendenze esterne. La tipografia è self-hosted e il flake Nix permette di usare una versione di Hugo sempre coerente, senza installarla nel sistema.

## Requisiti

Puoi scegliere una delle due modalità:

- **Nix** (consigliata): basta avere Nix con il supporto ai flake. Hugo viene fornito dalla dev shell.
- **Hugo locale**: è sufficiente avere `hugo` installato e disponibile nel `PATH`.

## Avvio locale

Con Nix, entra nella dev shell e avvia il server:

```sh
nix develop
hugo server --buildDrafts --port 8080
```

In alternativa, come comando singolo:

```sh
nix develop --command hugo server --buildDrafts --port 8080
```

Il sito sarà disponibile su <http://localhost:8080/>. Hugo ricarica automaticamente le modifiche ai contenuti, ai template e agli stili.

Se Hugo è già installato, puoi eseguire direttamente:

```sh
hugo server --buildDrafts --port 8080
```

`--buildDrafts` include anche gli articoli con `draft = true`. Per vedere soltanto i contenuti pubblicati, ometti questa opzione.

## Generazione del sito

Per creare la versione statica nella cartella `public/`:

```sh
hugo
```

Con Nix, la build riproducibile viene creata nel percorso `result/`:

```sh
nix build
```

Prima di pubblicare, è possibile controllare il flake con:

```sh
nix flake check
```

## Scrivere un nuovo articolo

Crea un nuovo contenuto partendo dall'archetipo incluso nel progetto:

```sh
hugo new content/post/titolo.md
```

Il file viene creato in `content/post/` con `draft = true`. Compila il front matter, scrivi il contenuto in Markdown e imposta `draft = false` quando l'articolo è pronto per la pubblicazione.

Per collegare un articolo a un altro, usa il shortcode `relref` di Hugo invece di un percorso relativo:

```go-html-template
[See also]({{< relref "/post/altro-articolo.md" >}})
```

In questo modo Hugo genera il link corretto anche quando cambiano gli URL permalink.

### Front matter editoriale

L'archetipo include alcuni campi opzionali:

```toml
description = "A concise summary used on the homepage, in search results, and in social metadata."
subtitle = "An optional standfirst shown below the article title."
featured = false
showToc = false
```

- `featured = true` seleziona l'articolo in evidenza in homepage; se nessun articolo è marcato, viene usato il più recente.
- `showToc = true` forza l'indice; per impostazione predefinita viene mostrato negli articoli più lunghi di 700 parole.
- `description` viene usata anche nelle anteprime al posto del summary generato da Hugo.

## Componenti editoriali

I componenti sono shortcode Hugo e funzionano direttamente nel Markdown. Gli esempi principali:

```go-html-template
{{< callout type="note" title="A useful distinction" >}}
Markdown content for the callout.
{{< /callout >}}

{{< pullquote cite="A Reader" >}}
A sentence worth pausing on.
{{< /pullquote >}}

{{< figure src="/images/example.svg" alt="Description" caption="A caption." number="1" >}}

{{< diagram name="edn-views" caption="Description" number="2" wide="true" >}}

{{< terminal title="shell" >}}
$ hugo server --port 8080
{{< /terminal >}}

{{< details summary="Open the details" >}}
Additional explanation or an optional visualisation.
{{< /details >}}

{{< sidenote >}}
A marginal note shown beside the article on wide screens.
{{< /sidenote >}}

{{< split ratio="7-5" >}}
{{< split-col >}}
Markdown for the first column.
{{< /split-col >}}
{{< split-col >}}
Markdown or an image for the second column.
{{< /split-col >}}
{{< /split >}}
```

I diagrammi vanno salvati in `assets/diagrams/` come SVG con `<title>` e `<desc>` per l'accessibilità. Le immagini Markdown normali ricevono automaticamente una figura e una didascalia quando il titolo è presente:

```markdown
![Alternative text](/images/example.svg "Optional caption")
```

## Design e asset

- Palette: carta `#F4F1E9`, inchiostro `#24251F`, accento `#A45C36`, testo secondario `#6B6A63`.
- Font self-hosted in `static/fonts/`: Newsreader per i titoli, IBM Plex Sans per il testo, IBM Plex Mono per codice e annotazioni.
- Illustrazioni originali in `assets/diagrams/`; nessun JavaScript aggiuntivo e nessun framework CSS.

## Progetti

La pagina `/projects/` e la sezione in homepage leggono da `data/projects.yaml`. Ogni voce ha `name`, `kicker`, `description`, `url` e `status`. La pagina è definita in `content/projects/_index.md` e usa `layouts/projects/list.html`.

## Struttura del progetto

- `content/post/`: articoli del blog.
- `content/projects/`: pagina indice dei progetti.
- `data/projects.yaml`: dati mostrati nella pagina progetti e in homepage.
- `assets/diagrams/`: diagrammi SVG elaborati da Hugo.
- `layouts/`: template e partial del tema.
- `layouts/shortcodes/`: componenti editoriali usabili nel Markdown.
- `static/`: CSS, favicon e font serviti senza elaborazione.
- `archetypes/`: modello usato da `hugo new`.
- `config.toml`: configurazione del sito, menu, permalink e parametri.
- `flake.nix`: ambiente di sviluppo e build Nix.
- `.github/workflows/hugo.yml`: build e deploy automatico su GitHub Pages.

## Pubblicazione

Il workflow GitHub Actions pubblica il sito su GitHub Pages a ogni push sul branch `master`. La CI usa Hugo `0.168.0`, la stessa versione fornita dal flake, e carica la cartella `public/` come artifact della pagina.
