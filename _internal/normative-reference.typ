#import "@preview/bullseye:0.1.0": *
#import "helper/referenceable-element.typ": referencable-element, ghost-html-elem

/// Renders a single normative reference, referenceable by its `reference` id.
/// - reference (str): Unique identifier used for cross-referencing this entry.
/// - label (str): Short display label shown in brackets (e.g. `"IEEE Std 11073-10207"`).
/// - text (content): Full bibliographic description of the referenced work.
#let normative-reference(
  reference: str,
  label: str,
  text: content
) = {
  context on-target(
    paged: {
      referencable-element(kind: "ref-normative-reference", displayed: label, reference: reference, appendix: text, brackets: true).at(1)
    },
    html: {[
      #ghost-html-elem(
        tag: "normative-reference",
        attrs: ("id": reference, "label": label),
        reference: reference,
        supplement: [\[#label\]],
        body: [#label #text],
      ).at(1)
    ]})
}