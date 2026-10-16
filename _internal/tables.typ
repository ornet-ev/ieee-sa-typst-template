#import "@preview/bullseye:0.1.0": *


/// Renders content in landscape orientation.
/// Intended for wide tables or figures that do not fit on a portrait page.
/// - figure (content): The content to render horizontally.
#let horizontal(
  figure
) = {
  context on-target(
    paged: {
      set page(flipped: true)
      figure
      set page(flipped: false)
    },
    html: {
      html.elem("horizontal")[#figure]
    }
  )
}