#let mermaid-diagram(
  path,
  width: 100%,
  height: 5.6cm,
  inset: 0pt,
  dx: 0pt,
  dy: 0pt,
) = align(center)[
  #block(
    width: width,
    height: height,
    inset: inset,
  )[
    #align(center + horizon)[
      #move(dx: dx, dy: dy)[
        #image(path, width: 100%, height: 100%, fit: "contain")
      ]
    ]
  ]
]
