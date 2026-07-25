#import "../../diatypst/diagrams.typ": mermaid-diagram

#let slide-body(body, top: 1fr, bottom: 1fr) = [
  #v(top)
  #body
  #v(bottom)
]

#let report-diagram(
  path,
  width: 100%,
  height: 5.6cm,
  inset: 0pt,
  dx: 0pt,
  dy: 0pt,
) = mermaid-diagram(
  path,
  width: width,
  height: height,
  inset: inset,
  dx: dx,
  dy: dy,
)
