# Reporting

Build the Diatypst deck from the repository root:

```bash
typst compile --root . diatypst/main.typ diatypst/main.pdf
```

`--root .` lets the Diatypst theme read static visual assets from `vis/`.

Render Mermaid diagrams before compiling the deck:

```bash
mmdc -i vis/diagrams/component-flow.mmd -o vis/diagrams/fig/component-flow.svg -c vis/diagrams/mermaid-config.json -p vis/diagrams/puppeteer-config.json -b transparent
mmdc -i vis/diagrams/class-model.mmd -o vis/diagrams/fig/class-model.svg -c vis/diagrams/mermaid-config.json -p vis/diagrams/puppeteer-config.json -b transparent
mmdc -i vis/diagrams/render-sequence.mmd -o vis/diagrams/fig/render-sequence.svg -c vis/diagrams/mermaid-config.json -p vis/diagrams/puppeteer-config.json -b transparent
```

Typst controls slide layout through `mermaid-diagram` in `diatypst/diagrams.typ`; the SVG export should stay content-focused.
