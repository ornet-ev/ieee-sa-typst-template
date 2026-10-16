#import "@preview/bullseye:0.1.0": *

#let wrap-html(
  tag,
  attrs: (:),
  body
) = {
  context on-target(
    paged: {
      body
    },
    html: {[
      #html.elem(tag, attrs: attrs, body)
    ]})
}