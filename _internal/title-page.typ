#import "@preview/bullseye:0.1.0": *

#let title-page(
  title: none
) = {
  assert(title != none, message: "title is required")

  set text(
    // font: sans-font,
    size: 12pt,
    lang: "en",
  )
  set par(leading: 0.5em)
  set par.line(numbering: none)

  context on-target(paged: {
    set page(margin: (left: 20mm, right: 20mm, top: 20mm, bottom: 30mm))
    align(center + horizon, text(2.5em, strong(title)))
  })
  
}