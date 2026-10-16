#import "@preview/bullseye:0.1.0": *
#import "helper/referenceable-element.typ": referencable-element, ghost-html-elem

#import "helper/plural.typ": plural-for, plural-ref-for
#import "helper/make-reference.typ": make-reference

/// Renders a referenceable definition entry.
/// - reference (str): Unique identifier used for cross-referencing this definition.
/// - term (str): The term being defined.
/// - description (content): The definition text.
#let definition(
  reference: none,
  term: none,
  term-plural: none,
  description: none,
) = {
  assert(term != none, message: "term can't be none")
  assert(description != none, message: "description can't be none")

  let actual-plural = if term-plural == none {
    plural-for(term)
  } else {
    term-plural
  }

  let actual-reference = if reference == none {
    make-reference(term)
  } else {
    reference
  }

  context on-target(
    paged: {[
      #place(referencable-element(
        kind: "ref-definition",
        displayed: [#term],
        reference: actual-reference,
        render-text: false
      ).at(1))
      #place(referencable-element(
        kind: "ref-definition-plural",
        reference: plural-ref-for(actual-reference),
        displayed: [#actual-plural],
        render-text: false
      ).at(1))
      *#term:* #description
    ]},
    html: {[
      #ghost-html-elem(
        tag: "definition-plural",
        attrs: ("id": plural-ref-for(actual-reference), "term": actual-plural, "plural-for": actual-reference),
        reference: plural-ref-for(actual-reference),
        supplement: [#actual-plural]
      ).at(1)
      #ghost-html-elem(
        tag: "definition",
        attrs: ("id": actual-reference, "term": term),
        reference: actual-reference,
        supplement: [#term],
        body: [#description],
      ).at(1)
  ]})
}