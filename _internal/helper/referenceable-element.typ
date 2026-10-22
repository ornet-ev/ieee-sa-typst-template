
// used to render displayed texts on references without any formatting
// formatting should only be defined by enclosing structures
#let _plain-text(it) = {
  if type(it) == str {
    it
  } else if it.func() == text {
    it.text
  } else if it.has("children") {
    it.children.map(_plain-text).join()
  } else if it.has("body") {
    _plain-text(it.body)
  } else if it.has("text") {
    it.text
  } else {
    ""
  }
}

// as of typst 0.14, references only support "referenceable elements", we wrap the data in a figure and reference it
#let referencable-element(
  kind: "referencable-element",
  displayed: none,
  reference: none,
  appendix: "",
  brackets: false,
  render-text: true
) = {
  assert(displayed != none, message: "displayed can't be none")
  assert(reference != none, message: "reference can't be none")

  let displayed-text = if brackets {
    "[" + displayed + "]"
  } else {
    displayed
  }

  let spacing = if appendix == [] {
    ""
  } else {
    " "
  }

  let ref-label = label(reference)

  let content = [
    #show figure: set align(start)
    #figure(
      kind: kind,
      supplement: _plain-text(displayed-text),
      numbering: a => none,
      if render-text { displayed-text + spacing + appendix } else { "" },
    )
    #ref-label
  ]

  return (ref-label, content)
}


// Creates a ghost figure that, in HTML, becomes a single custom element
// with the given tag, attributes, and body. Because the show rule produces
// exactly one HTML element, Typst places the label's ID on that element
// directly - no extra <span> appearing in the output.
//
// Parameters:
//   tag:        the HTML element name (e.g. "normative-reference", "requirement")
//   attrs:      dictionary of HTML attributes (should include "id" for unreferenced elements)
//   reference:  the label string (used for @ref resolution)
//   supplement:  the supplement shown when referenced (e.g. [IEEE 11073-10207])
//   body:       the content inside the HTML element
#let ghost-html-elem(
  tag: none,
  attrs: (:),
  reference: none,
  supplement: none,
  body: [],
) = {
  assert(tag != none, message: "tag can't be none")
  assert(reference != none, message: "reference can't be none")

  // Unique kind per tag so show rules don't collide
  let kind = "ghost-" + tag


  let ghost-label = label(reference)
  let content = [
    #show figure.where(kind: kind): it => {
      html.elem(tag, attrs: attrs, body)
    }
    #figure(kind: kind, supplement: supplement, numbering: _ => none, [])
    #ghost-label
  ]

  return (ghost-label, content)
}
