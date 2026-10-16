#import "@preview/bullseye:0.1.0": *
#import "@preview/tally:0.1.2": tally

/// setup for the document style and logic

// Apply show rules to the document which
// - allows links to ghost elements
// - allows links to definitions
#let apply-show-rules(body) = {
  show: tally.with(color: yellow)

  // split heading numbering and caption into separate spans for better post processing
  show heading: it => {
    context on-target(
      paged: it,
      html: {
        let tag = "h" + str(it.level + 1)
        let num = if it.numbering != none {
          let n = counter(heading).display(it.numbering)
          html.elem("span", attrs: (class: "heading-number"))[#n]
        }
        html.elem(tag)[#num #html.elem("span", attrs: (class: "heading-caption"))[#it.body]]
      },
    )
  }

  let ghost-kinds = (
    "ghost",
    "ghost-requirement",
    "ghost-definition",
    "ghost-definition-plural",
    "ghost-normative-reference",
    "ghost-note",
    "ghost-bibliography",
    "ghost-glossary",
    "ghost-glossary-plural"
  )

  let html-figure(it) = context on-target(
    paged: it,
    html: {
      html.elem("figure")[
        #it.body
        #html.elem("figcaption")[
          #html.elem("span", attrs: (class: "figure-label"))[
            #it.caption.supplement#sym.space.nobreak#it.caption.counter.display(it.caption.numbering):
          ]
          #html.elem("span", attrs: (class: "figure-caption"))[
            #it.caption.body
          ]
        ]
      ]
    },
  )

  show figure.where(kind: table): html-figure
  show figure.where(kind: image): html-figure
  show figure.where(kind: raw): html-figure

  for kind in ghost-kinds {
    // hide ghost references from the document
    show figure.where(kind: kind): it => []
  }

  let use-supplement-kinds = (
    ghost-kinds
      + (
        "requirement",
        "ref-definition",
        "ref-definition-plural",
        "ref-glossary",
        "ref-glossary-plural"
      )
  )

  show ref: it => {
    let key = str(it.target)

    // if it is a kind which is supposed to be referenced using the supplement only
    if it.element != none and it.element.func() == figure and it.element.kind in use-supplement-kinds {
      link(it.target, it.element.supplement)
    } else {
      it
    }
  }
  body
}
