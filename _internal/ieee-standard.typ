#import "title-page.typ": title-page
#import "ics.typ": render-ics-tables
#import "init.typ": apply-show-rules
#import "helper/html-util.typ": wrap-html
#import "helper/html-extra.typ": add-html-view-mode
#import "glossary.typ": print-glossary, register-glossary
#import "annex.typ": annex-informative, annex-normative, render-annex

#import "@preview/bullseye:0.1.0": *

#let standard-type = (
  standard: "Standard",
  recommended-practice: "Recommended Practice",
  guide: "Guide"
)

#let document-type = (
  revision: "Revision",
  amendment: "Amendment",
  corrigenda: "Corrigenda"
)

/// Creates a metadata dict for an IEEE standard document.
/// The returned dict is passed to `ieee-standard` as the `metadata` parameter.
/// - designation (str): IEEE standard designation number (e.g. `"11073-10207"`).
/// - draft-number (str): Current draft number (e.g. `"05"`).
/// - trial-use (bool): Whether this is a trial-use standard.
/// - standard-type (str): One of `standard-type-standard`, `standard-type-recommended-practice`, or `standard-type-guide`.
/// - par-title (str): The PAR-approved title of the standard.
/// - committee-name (str): Name of the responsible IEEE committee.
/// - society-name (str): Name of the sponsoring IEEE society.
/// - draft-date (datetime): Date of this draft (defaults to today). Use `datetime(year: 2025, month: 6, day: 1)` to set a fixed date.
/// - working-group-name (str): Name of the working group authoring the standard.
/// - chair-name (str): Working group chair's name.
/// - vice-chair-name (str): Working group vice-chair's name.
/// - document-type (str): One of `document-type-revision`, `document-type-amendment`, or `document-type-corrigenda`.
#let document-metadata(
  designation: none,
  draft-number: none,
  trial-use: false,
  standard-type: standard-type.standard,
  par-title: none,
  committee-name: none,
  society-name: none,
  draft-date: datetime.today(),
  working-group-name: none,
  chair-name: "",
  vice-chair-name: "",
  document-type: document-type.revision,
) = {
  let trial-use-label = if trial-use {
    "Trial-Use "
  } else {
    ""
  }

  assert(designation != none, message: "designation is required metadata")
  assert(draft-number != none, message: "draft-number is required metadata")
  assert(par-title != none, message: "par-title is required metadata")
  assert(committee-name != none, message: "committee-name is required metadata")
  assert(society-name != none, message: "society-name is required metadata")
  assert(working-group-name != none, message: "working-group-name is required metadata")

  let title = (
    "P" + designation + "™/D" + draft-number + " — Draft " + trial-use-label + standard-type + " for " + par-title
  )

  (
    "title": title,
    "designation": designation,
    "draft-number": draft-number,
    "trial-use": trial-use,
    "standard-type": standard-type,
    "par-title": par-title,
    "committee-name": committee-name,
    "society-name": society-name,
    "draft-date": draft-date,
    "working-group-name": working-group-name,
    "chair-name": chair-name,
    "vice-chair-name": vice-chair-name,
    "document-type": document-type,
  )
}


#let render-metadata(
  document-metadata,
) = {
  // create html metadata for standard data
  context on-target(html: {
    html.elem("meta", attrs: (name: "full-title", content: document-metadata.title))
    html.elem("meta", attrs: (name: "draft-number", content: document-metadata.draft-number))
    html.elem("meta", attrs: (name: "designation", content: document-metadata.designation))
    html.elem("meta", attrs: (name: "trial-use", content: if document-metadata.trial-use { "true" } else { "false" }))
    html.elem("meta", attrs: (name: "standard-type", content: document-metadata.standard-type))
    html.elem("meta", attrs: (name: "par-title", content: document-metadata.par-title))
    html.elem("meta", attrs: (name: "committee-name", content: document-metadata.committee-name))
    html.elem("meta", attrs: (name: "society-name", content: document-metadata.society-name))
    html.elem("meta", attrs: (name: "draft-date", content: document-metadata.draft-date.display()))
    html.elem("meta", attrs: (name: "working-group-name", content: document-metadata.working-group-name))
    html.elem("meta", attrs: (name: "chair-name", content: document-metadata.chair-name))
    html.elem("meta", attrs: (name: "vice-chair-name", content: document-metadata.vice-chair-name))
    html.elem("meta", attrs: (name: "document-type", content: document-metadata.document-type))
  })
}

/// Template for a standards document with PDF preview an customized, parseable HTML output
///
/// - metadata (dict of metadata): metadata of the standard document, see document-metadata
/// - abstract (content): abstract of the standard document
/// - abbreviations (array): array of structure (short, long(, optional custom plural)?)
/// - introduction (content): introduction section of the standard document
/// - normative-references (array of normative-reference): normative references required for this standard document
/// - notational-conventions (content): notational conventions section for the standard document
/// - informative-bibliography (array of bibliography): informative bibliography entries
/// - definitions (array of definitions): array of definition elements to include in the standard document
/// - normative-annexes (array of content): array of additional annexes to add to the standard document
/// - informative-annexes (array of content): array of additional annexes to add to the standard document
/// - body ():
/// ->
#let ieee-standard(
  metadata: none,
  abstract: none,
  keywords: (),
  abbreviations: none,
  introduction: none,
  normative-references: none,
  definitions: none,
  scope: none,
  additional-overview: none,
  notational-conventions: none,
  informative-bibliography: none,
  normative-annexes: (),
  informative-annexes: (),
  ics-annex: none,
  body,
) = {
  let paged-pagebreak = context on-target(paged: pagebreak())

  // set "draft" background in pdf unless explicitly deactivated
  let show-draft = sys.inputs.at("draft", default: "true") == "true"
  let draft-bg = if show-draft {
    rotate(
      -45deg,
      text(150pt, fill: luma(240), weight: "bold")[DRAFT],
    )
  } else {
    none
  }

  set page(background: draft-bg)



  // validate input
  assert(document-metadata != none, message: "document-metadata is required")
  assert(abstract != none, message: "abstract is required")
  assert(abbreviations != none, message: "abbreviations is required")
  assert(introduction != none, message: "introduction is required")
  assert(normative-references != none, message: "normative-references is required")
  assert(scope != none, message: "scope is required")
  assert(keywords.len() > 0, message: "provide at least one keyword")

  // set document style and settings
  set document(title: metadata.title, date: metadata.draft-date)

  let backmatter(content) = {
    set heading(supplement: "Annex", numbering: (..n) => {
      let nums = n.pos()
      if nums.len() == 1 {
        "Annex " + numbering("A", ..nums)
      } else {
        numbering("A.1", ..nums)
      }
    })
    // explicitly remove "Annex" prefix from level 1 in the backmatter 
    // as it is part of the numbering already
    show heading.where(level: 1): set heading(supplement: "")
    counter(heading).update(0)
    content
  }

  // adjust refs rules
  show: apply-show-rules

  // no numbering for introduction and abstract
  set heading(numbering: none)


  // somewhat align pdf with doc output
  // note that this generates a warning in html mode which cannot be suppressed due to set commands not being allowed
  // in contexts (which is required to dispatch between paged and html).
  set page(
    paper: "us-letter",
    margin: (
      left: 3.17cm,
      right: 3.17cm,
      bottom: 2.54cm,
      top: 2.54cm,
    ),
    header: context {
      if counter(page).get().first() > 1 [
        #set text(8pt)
        #set align(left)
        #grid(
          columns: (3fr, 1fr),
          align(left + top)[#metadata.title], align(right + top)[#metadata.draft-date.display("[day] [month repr:long] [year]")],
        )
        #line(length: 100%)
      ]
    },
    footer: context {
      if counter(page).get().first() > 1 [
        #set align(center)
        #set text(8pt)
        #counter(page).display(
          "1/1",
          both: true,
        )
      ]
    },
  )

  set par.line(numbering: "1", numbering-scope: "page")

  add-html-view-mode

  // render custom metadata into the document before any content
  // customizing <head> currently requires a custom <html> and <body> as well, which
  // currently (0.14) means footnote handling is lost and would need to be customized
  // so this is an easier solution
  render-metadata(metadata)

  // load the abbreviations before doing anything with the document to ensure the references work
  register-glossary(abbreviations)

  title-page(title: metadata.title)

  context on-target(html: { wrap-html("h1", metadata.title) })

  paged-pagebreak

  context on-target(
    html: {
      wrap-html("abstract", abstract)
    },
    paged: {
      [*Abstract:* #abstract]
    },
  )

  parbreak()

  context on-target(
    html: {
      wrap-html("keywords", keywords.join(", "))
    },
    paged: {
      [*Keywords:* #keywords.join(", ")]
    },
  )

  paged-pagebreak
  // preface designates the standard's introduction clause
  [== Introduction <introduction>]
  wrap-html("introduction", introduction)

  paged-pagebreak


  outline(indent: 1em)

  paged-pagebreak

  // start numbering everything until the annex section now
  set heading(supplement: "Clause", numbering: "1.")

  [

    = Overview

    == Scope
    #wrap-html("scope")[
      #scope
    ]

    #if additional-overview != none [
      #wrap-html("additional-overview", additional-overview)
    ]

    == Word usage

    The word *shall* indicates mandatory requirements strictly to be followed in
    order to conform to the standard  and from which no deviation is permitted
    (*shall* equals *is required to*). #footnote[The use of the word
      must is deprecated and cannot be used when stating mandatory requirements; must
      is used only to describe unavoidable situations.]

    The word *should* indicates that among several possibilities one is
    recommended as particularly suitable, without mentioning or excluding others; or
    that a certain course of action is preferred but not necessarily
    required (*should* equals *is recommended that*).

    The word *may* is used to indicate a course of action permissible within the
    limits of the standard (*may* equals is *permitted to*).

    The word *can* is used for statements of possibility and capability, whether
    material, physical, or causal (*can* equals *is able to*).
    #footnote[The use of will is deprecated and cannot be used when
      stating mandatory requirements; will is only used in statements of fact.]

  ]

  [= Normative references <clause:Normative_references>]

  wrap-html("normative-references")[
    #for reference in normative-references {
      reference
    }
  ]

  paged-pagebreak

  [= Definitions, acronyms, and abbreviations <clause:Definitions_acronyms_and_abbreviations>]

  [== Definitions <clause:Definitions>]

  wrap-html("definitions")[
    #for definition in definitions {
      definition
    }
  ]

  [== Acronyms and abbreviations <clause:Acronyms_and_abbreviations>]

  wrap-html("abbreviations")[
    #print-glossary(show-all: true)
  ]

  paged-pagebreak

  notational-conventions

  paged-pagebreak

  wrap-html("main-content")[
    #body
  ]

  paged-pagebreak

  // update numbering for annexes and start from the beginning
  show: backmatter


  for annx in normative-annexes {
    render-annex(annex: annx, tag: annex-normative)
    paged-pagebreak
  }

  for annx in informative-annexes {
    render-annex(annex: annx, tag: annex-informative)
    paged-pagebreak
  }

  if ics-annex != none {
    render-annex(annex: ics-annex, tag: annex-informative)
    paged-pagebreak
  }

  [= Bibliography <annex:Bibliography>]

  wrap-html("informative-bibliography")[
    #for bib in informative-bibliography {
      bib
    }
  ]
}
