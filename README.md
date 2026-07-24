# Reporting

Build the Diatypst deck from the repository root:

```bash
typst compile --root . --font-path assets/fonts diatypst/main.typ diatypst/main.pdf
```

`--root .` lets the Diatypst theme read static visual assets from `assets/` and `diagrams/`.

Install the bundled font assets before compiling:

```bash
scripts/install-fonts.sh
```

By default, fonts are installed into `assets/fonts`. Use `--dir PATH` or `FONT_DIR=PATH` to install them elsewhere, then pass the same directory to `typst compile --font-path`.

Render Mermaid diagrams before compiling the deck:

```bash
mmdc -i diagrams/component-flow.mmd -o diagrams/fig/component-flow.svg -c diagrams/mermaid-config.json -p diagrams/puppeteer-config.json -b transparent
mmdc -i diagrams/class-model.mmd -o diagrams/fig/class-model.svg -c diagrams/mermaid-config.json -p diagrams/puppeteer-config.json -b transparent
mmdc -i diagrams/render-sequence.mmd -o diagrams/fig/render-sequence.svg -c diagrams/mermaid-config.json -p diagrams/puppeteer-config.json -b transparent
```

Typst controls slide layout through `mermaid-diagram` in `diatypst/diagrams.typ`; the SVG export should stay content-focused.
