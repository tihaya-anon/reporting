#import "@preview/diatypst:0.9.3": slides

#let primary = rgb("#FF7A3D")
#let primary-text = rgb("#B84612")
#let secondary = rgb("#FFEEE5")
#let background = rgb("#FEFDFB")
#let ink = rgb("#171717")
#let muted = rgb("#5F6368")
#let border = rgb("#E6E0DC")
#let fonts = ("Noto Sans CJK SC", "Noto Sans")

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

#let logo-light(width: 2.2cm) = image("../../vis/logo.svg", width: width)
#let logo-dark(width: 2.2cm) = image("../../vis/logo-black.svg", width: width)

#let page-branding() = context {
  if here().page() > 1 {
    place(bottom + right, dx: -0.62cm, dy: -0.88cm, logo-dark(width: 1.55cm))
  }
}

#let _meta(label, value) = {
  if value != none [
    #stack(
      dir: ttb,
      spacing: 0.12cm,
      text(size: 0.58em, fill: muted, weight: "bold", upper(label)),
      text(size: 0.78em, fill: ink, value),
    )
  ]
}

#let title-slide(
  title,
  subtitle: none,
  date: none,
  authors: (),
  ratio: 16 / 9,
  layout: "large",
) = {
  let author-list = _authors(authors)
  let height = _page-height(layout)
  let width = ratio * height

  set page(
    width: width,
    height: height,
    margin: 0cm,
    header: none,
    footer: none,
    fill: background,
  )
  set text(font: fonts, fill: ink)

  block(width: 100%, height: 100%, inset: 0.72cm)[
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      [
        #block(width: 4.2cm, height: 0.18cm, fill: secondary)
        #v(0.12cm)
        #line(length: 1.35cm, stroke: 2pt + primary)
      ],
      logo-dark(width: 1.95cm),
    )

    #v(1.38cm)
    #block(width: 73%)[
      #text(size: 2.36em, weight: "bold", title)
      #if subtitle != none [
        #v(0.38cm)
        #text(size: 1.02em, fill: primary-text, subtitle)
      ]
    ]

    #v(1fr)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.5cm,
      _meta("date", date),
      _meta("authors", if author-list.len() > 0 {
        author-list.join(", ", last: " & ")
      } else {
        none
      }),
    )
  ]

  pagebreak()
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

  title-slide(
    title,
    subtitle: subtitle,
    date: date,
    authors: authors,
    ratio: ratio,
    layout: layout,
  )

  set page(foreground: page-branding())

  show: slides.with(
    title: title,
    subtitle: subtitle,
    date: date,
    authors: authors,
    footer-title: footer-title,
    footer-subtitle: footer-subtitle,
    ratio: ratio,
    layout: layout,
    title-color: primary,
    bg-color: background,
    count: count,
    footer: true,
    toc: toc,
    theme: theme,
    first-slide: false,
  )

  show heading.where(level: 1): it => {
    set page(header: none, footer: none, margin: 0cm, fill: background)
    block(width: 100%, height: 100%, inset: 0.72cm)[
      #grid(
        columns: (0.18cm, 1fr),
        column-gutter: 0.72cm,
        [
          #block(width: 100%, height: 100%, fill: secondary)
        ],
        [
          #align(horizon)[
            #line(length: 1.35cm, stroke: 2pt + primary)
            #v(0.34cm)
            #set text(fill: ink)
            #text(size: 1.72em, weight: "bold", it.body)
          ]
        ],
      )
    ]
  }

  show heading.where(level: 2): set text(fill: ink)

  show terms.item: it => {
    stack(
      spacing: 0pt,
      block(
        width: 100%,
        inset: (x: 0.18cm, y: 0.12cm),
        fill: secondary,
        stroke: (left: 2pt + primary),
        radius: (top: 2pt, bottom: 0pt),
      )[
        #text(fill: ink, weight: "bold", it.term)
      ],
      block(
        width: 100%,
        inset: (x: 0.18cm, y: 0.12cm),
        fill: rgb("#FFF8F4"),
        stroke: (left: 2pt + primary),
        radius: (top: 0pt, bottom: 2pt),
      )[
        #text(fill: ink, it.description)
      ],
    )
  }

  body
}
