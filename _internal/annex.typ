#import "@preview/bullseye:0.1.0": *
#import "helper/html-util.typ": wrap-html


#let annex-informative = "informative-annex"
#let annex-normative = "normative-annex" 


#let _check-no-h1(body) = {
  if body.func() == heading and body.depth == 1 {
    panic("Level-1 headings are not allowed in annex chapters!")
  }
  if body.has("children") {
    for child in body.children {
      _check-no-h1(child)
    }
  }
}

/// Creates an annex definition dict to be rendered by the IEEE template.
/// - title (str): The annex title (required).
/// - reference (str): Optional label for cross-referencing the annex.
/// - body (content): The annex content. Must not contain level-1 headings.
#let annex(
  title: none,
  reference: none,
  body
) = {
  assert(title != none, message: "annex needs a title")

  // check body doesn't contain top level heading
  _check-no-h1(body)

  (
    "title": title,
    "label": reference,
    "body": body,
  )
}

#let render-annex(
  annex: none,
  tag: none,
) = {

  assert(annex != none, message: "annex required")
  assert(tag != none, message: "tag required")

  context on-target(
    paged: [
      = #annex.title
      #if (annex.label != none) {
        label(annex.label)
      }
      #annex.body
    ],
    html: {

      let attrs = ("title": annex.title)

      if (annex.label != none) {
        attrs.insert("label", annex.label)
      }

      wrap-html(tag, attrs: attrs)[
        // add annex title heading so the heading counter is in sync with paged output
        = #annex.title
        #if (annex.label != none) {
          label(annex.label)
        }
        #annex.body
      ]
    }
  )
}