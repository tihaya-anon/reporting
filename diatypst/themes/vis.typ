#import "@preview/diatypst:0.9.3": slides

#let primary = rgb("#FF7A3D")
#let primary-text = rgb("#B84612")
#let secondary = rgb("#FFEEE5")
#let background = rgb("#FEFDFB")
#let code-border = primary
#let ink = rgb("#171717")
#let muted = rgb("#5F6368")
#let border = rgb("#E6E0DC")
#let fonts = ("Noto Sans CJK SC", "Noto Sans")
#let math-fonts = ("Noto Sans Math", "Noto Sans CJK SC", "Noto Sans")
#let mono-fonts = ("Maple Mono NF", "Noto Sans Mono", "Noto Sans CJK SC", "Noto Sans")

#let _layouts = (
  "small": 9cm,
  "medium": 10.5cm,
  "large": 12cm,
)

#let _authors(authors) = {
  if authors == none {
    ()
  } else if type(authors) == array {
    authors
  } else {
    (authors,)
  }
}

#let _page-height(layout) = {
  if layout not in _layouts {
    panic("Unknown layout " + layout)
  }
  _layouts.at(layout)
}

#let _scale(layout) = _page-height(layout) / 12cm

#let logo-light(width: auto) = image("../../assets/logo.svg", width: width)
#let logo-dark(width: auto) = image("../../assets/logo-black.svg", width: width)

#let _meta(label, value, scale: 1) = {
  if value != none [
    #stack(
      dir: ttb,
      spacing: 0.12cm * scale,
      text(size: 0.58em * scale, fill: muted, weight: "bold", upper(label)),
      text(size: 0.78em * scale, fill: ink, value),
    )
  ]
}

#let agenda-item(index, title, destination, scale: 1) = link(destination)[
#block(
  width: 100%,
  inset: (x: 0.18cm * scale, y: 0.16cm * scale),
  fill: background,
  stroke: (top: 1pt + primary, bottom: 0.6pt + border),
  radius: 2pt,
)[
  #stack(
    dir: ttb,
    spacing: 0.18cm * scale,
    block(
      width: 0.58cm * scale,
      height: 0.58cm * scale,
      fill: primary,
      radius: 0.29cm * scale,
    )[
      #align(center + horizon)[
        #text(size: 0.62em * scale, fill: background, weight: "bold", numbering("01", index))
      ]
    ],
    text(size: 0.88em * scale, fill: ink, weight: "bold", title),
  )
]
]

#let agenda-slide(label: "Agenda", scale: 1) = context {
  let sections = query(heading.where(level: 1))
  let slides = query(heading.where(level: 2))

  block(width: 100%, height: 100%)[
    #metadata("agenda") <vis-agenda>
    #set text(font: fonts, fill: ink)
    #text(size: 1.46em * scale, weight: "bold", label)
    #v(0.34cm * scale)
    #line(length: 1.35cm * scale, stroke: 2pt + primary)
    #v(1.1cm * scale)

    #if sections.len() == 0 [
      #text(size: 0.9em * scale, fill: muted, [No sections])
    ] else {
      let column-count = if sections.len() <= 4 { sections.len() } else { 4 }
      let columns = (1fr,) * column-count
      grid(
        columns: columns,
        column-gutter: 0.34cm * scale,
        row-gutter: 0.34cm * scale,
        ..sections.enumerate().map(((i, section)) => agenda-item(
          i + 1,
          section.body,
          {
            let section-page = section.location().page()
            let next-section = if i + 1 < sections.len() { sections.at(i + 1) } else { none }
            let next-section-page = if next-section != none {
              next-section.location().page()
            } else {
              none
            }
            let first-slide = slides.find(slide => {
              let slide-page = slide.location().page()
              slide-page > section-page and (next-section-page == none or slide-page < next-section-page)
            })
            if first-slide != none { first-slide.location() } else { section.location() }
          },
          scale: scale,
        )),
      )
    }
  ]
  pagebreak()
}

#let progress-bar(scale: 1) = context {
  let total = counter(page).final().first()
  let current = here().page()

  if current > 2 and total > 2 {
    let track-width = 2.75cm * scale
    let track-height = 0.055cm * scale
    let progress = (current - 2) / (total - 2)

    place(
      top + right,
      dx: -0.62cm * scale,
      dy: 0.52cm * scale,
      box(width: track-width, height: track-height)[
        #place(left + horizon, rect(
          width: track-width,
          height: track-height,
          fill: secondary,
          radius: track-height / 2,
        ))
        #place(left + horizon, rect(
          width: track-width * progress,
          height: track-height,
          fill: primary,
          radius: track-height / 2,
        ))
      ],
    )
  }
}

#let page-branding(scale: 1, agenda-dest: none) = context {
  progress-bar(scale: scale)

  if here().page() > 1 {
    let logo = logo-dark(width: 1.55cm * scale)
    if agenda-dest != none and here().page() > 2 {
      logo = link(agenda-dest, logo)
    }

    place(
      bottom + right,
      dx: -0.62cm * scale,
      dy: -0.88cm * scale,
      logo,
    )
  }
}

#let current-section-footer(toc: true, agenda-label: "Agenda") = context {
  let sections = query(heading.where(level: 1))
  let current = sections.rev().find(section => section.location().page() <= here().page())

  if current != none {
    current.body
  } else if toc and here().page() > 1 {
    agenda-label
  } else {
    none
  }
}

#let title-slide(
  title,
  subtitle: none,
  date: none,
  authors: (),
  ratio: 16 / 9,
  layout: "large",
  break-after: true,
) = {
  let author-list = _authors(authors)
  let height = _page-height(layout)
  let width = ratio * height
  let scale = _scale(layout)

  set page(
    width: width,
    height: height,
    margin: 0cm,
    header: none,
    footer: none,
    fill: background,
    foreground: place(
      bottom + right,
      dx: -0.62cm * scale,
      dy: -0.88cm * scale,
      logo-dark(width: 1.55cm * scale),
    ),
  )
  set text(font: fonts, fill: ink)

  block(width: 100%, height: 100%, inset: 0.72cm * scale)[
    #block(width: 4.7cm * scale, height: 0.18cm * scale, fill: secondary)
    #v(0.12cm * scale)
    #line(length: 1.35cm * scale, stroke: 2pt + primary)

    #v(1.28cm * scale)
    #block(width: 70%)[
      #text(size: 2.36em * scale, weight: "bold", title)
      #if subtitle != none [
        #v(0.38cm * scale)
        #text(size: 1.02em * scale, fill: primary-text, subtitle)
      ]
    ]

    #v(1fr)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.5cm * scale,
      _meta("date", date, scale: scale),
      _meta("authors", if author-list.len() > 0 {
        author-list.join(", ", last: " & ")
      } else {
        none
      }, scale: scale),
    )
  ]

  if break-after {
    pagebreak()
  }
}

#let vis-slides(
  body,
  title: none,
  subtitle: none,
  date: none,
  authors: (),
  footer-title: none,
  footer-subtitle: none,
  ratio: 16 / 9,
  layout: "large",
  toc: true,
  count: "dot",
  theme: "normal",
) = {
  if title == none {
    panic("A title is required")
  }

  set text(font: fonts, fill: ink)
  show math.equation: set text(font: math-fonts, fill: ink)
  let scale = _scale(layout)
  let agenda-dest = if toc { <vis-agenda> } else { none }

  title-slide(
    title,
    subtitle: subtitle,
    date: date,
    authors: authors,
    ratio: ratio,
    layout: layout,
  )

  set page(foreground: page-branding(scale: scale, agenda-dest: agenda-dest))

  show: slides.with(
    title: title,
    subtitle: subtitle,
    date: date,
    authors: authors,
    footer-title: if footer-title != none {
      footer-title
    } else if toc {
      context {
        if here().page() > 2 {
          link(agenda-dest, title)
        } else {
          title
        }
      }
    } else {
      title
    },
    footer-subtitle: if footer-subtitle != none {
      footer-subtitle
    } else {
      current-section-footer(toc: toc)
    },
    ratio: ratio,
    layout: layout,
    title-color: primary,
    bg-color: background,
    count: none,
    footer: true,
    toc: false,
    theme: theme,
    first-slide: false,
  )

  show raw: set text(font: mono-fonts)

  show raw.where(block: false): it => context {
    let inline-padding-y = 1.2pt
    let body-ascent = measure(
      text(
        font: fonts,
        size: 1em,
        top-edge: "ascender",
        bottom-edge: "baseline",
      )[H],
    ).height
    let body-descent = measure(
      text(
        font: fonts,
        size: 1em,
        top-edge: "baseline",
        bottom-edge: "descender",
      )[g],
    ).height
    let inline-height = body-ascent + body-descent + inline-padding-y * 2
    let inline-baseline = body-descent - inline-padding-y
    let code-text = text(size: 1em, fill: ink, it.text)

    box(
      height: inline-height,
      baseline: inline-baseline,
      stroke: 0.45pt + code-border,
      inset: (x: 2.4pt, y: 0pt),
      radius: 1pt,
      fill: secondary
    )[
      #align(horizon)[#code-text]
    ]
  }

  show raw.where(block: true): it => block(
    width: 100%,
    stroke: 0.6pt + code-border,
    inset: 0pt,
    radius: 4pt,
  )[
    #it
  ]

  show raw.line: it => context {
    set block(spacing: 0em)
    let number-width = measure(numbering("1", it.count)).width
    grid(
      columns: (number-width + 0.16cm * scale, 1fr),
      column-gutter: 0.14cm * scale,
      align: (right + horizon, left + horizon),
      text(size: 0.78em, fill: primary-text, numbering("1", it.number)),
      it.body,
    )
  }

  show heading.where(level: 1): it => {
    set page(header: none, footer: none, margin: 0cm, fill: background)
    block(width: 100%, height: 100%, inset: 0.72cm * scale)[
      #grid(
        columns: (0.18cm * scale, 1fr),
        column-gutter: 0.72cm * scale,
        [
          #block(width: 100%, height: 100%, fill: secondary)
        ],
        [
          #align(horizon)[
            #line(length: 1.35cm * scale, stroke: 2pt + primary)
            #v(0.34cm * scale)
            #set text(fill: ink)
            #text(size: 1.72em * scale, weight: "bold", it.body)
          ]
        ],
      )
    ]
  }

  show heading.where(level: 2): set text(fill: ink)

  show table: set table(
    fill: (x, y) => {
      if y == 0 {
        primary
      } else if calc.odd(y) {
        secondary
      } else {
        background
      }
    },
    stroke: (x, y) => {
      if y == 0 {
        0.6pt + primary
      } else {
        0.6pt + background
      }
    },
  )

  show table.cell.where(y: 0): it => {
    set text(fill: background, weight: "bold")
    it
  }

  show link: it => {
    if type(it.dest) == str {
      underline(stroke: 0.5pt + primary)[
        #text(fill: ink, it)
      ]
    } else {
      it
    }
  }

  show ref: it => {
    if it.element != none {
      let el = it.element
      link(el.location())[
        #underline(stroke: 0.5pt + primary)[
          #text(fill: primary-text, weight: "bold")[
            #if el.func() == heading {
              el.body
            } else if el.func() == figure {
              [#el.supplement #numbering(el.numbering, ..el.counter.at(el.location()))]
            } else {
              it
            }
          ]
        ]
      ]
    } else {
      it
    }
  }

  show terms.item: it => {
    stack(
      spacing: 0pt,
      block(
        width: 100%,
        inset: (x: 0.18cm * scale, y: 0.12cm * scale),
        fill: secondary,
        stroke: (left: 2pt + primary),
        radius: (top: 2pt, bottom: 0pt),
      )[
        #text(fill: ink, weight: "bold", it.term)
      ],
      block(
        width: 100%,
        inset: (x: 0.18cm * scale, y: 0.12cm * scale),
        fill: rgb("#FFF8F4"),
        stroke: (left: 2pt + primary),
        radius: (top: 0pt, bottom: 2pt),
      )[
        #text(fill: ink, it.description)
      ],
    )
  }

  if toc {
    agenda-slide(scale: scale)
  }

  body
}
