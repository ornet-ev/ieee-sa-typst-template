#import "@preview/bullseye:0.1.0": *
#import "helper/referenceable-element.typ": referencable-element, ghost-html-elem

/// Renders a single bibliography entry, referenceable by its `reference` id.
/// - reference (str): Unique identifier used for cross-referencing this entry.
/// - label (str): Short display label shown in brackets (e.g. `"IEEE Std 11073-10207"`).
/// - text (content): Full bibliographic description of the referenced work.
#let bibliography(
  reference: str,
  label: str,
  text: content
) = {
  assert(reference != none, message: "reference can't be none")
  assert(label != none, message: "label can't be none")
  assert(text != none, message: "text can't be none")


  context on-target(
    paged: {[
      #referencable-element(
        kind: "ref-bibliography",
        displayed: label,
        reference: reference,
        brackets: true,
        appendix: text
      ).at(1)
    ]},
    html: {[
      #ghost-html-elem(
        tag: "bibliography",
        attrs: ("id": reference, "label": label),
        reference: reference,
        supplement: [\[#label\]],
        body: [#text],
      ).at(1)
    ]}
  )
}