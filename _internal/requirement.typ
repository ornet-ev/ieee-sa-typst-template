#import "state.typ": add-requirement, requirement-numbers, update-requirement
#import "helper/referenceable-element.typ": referencable-element, ghost-html-elem
#import "@preview/bullseye:0.1.0": *

#let _requirement-anchor-prefix = "req"
#let _requirement-figure-kind = "requirement"

#let _pad-number(number: int, padding: int) = {
  let value = str(number)

  while value.len() < padding {
    value = "0" + value
  }

  value
}

#let _pad-requirement(number: int) = _pad-number(number: number, padding: 4)

/// Enum of requirement categories. Each variant carries a `kind` string and a
/// display `prefix` used to label requirements (e.g. `TR0001`).
/// Use `requirement-category.technical`, `.risk`, or `.process` for
/// `requirement.category`.
#let requirement-category = (
  technical: (kind: "technical", prefix: "TR"),
  risk: (kind: "risk", prefix: "RR"),
  process: (kind: "process", prefix: "PR")
)

/// Enum of requirement obligation levels, corresponding to IEEE word usage.
/// Use `requirement-level.shall`, `.should`, or `.may` for 
/// `requirement.level`.
#let requirement-level = (
  shall: "shall",
  should: "should",
  may: "may"
)

/// Renders a numbered, referenceable requirement paraggraph.
/// - category (dict): Requirement category; one of `requirement-category.technical`, `.risk`, or `.process`.
/// - number (int): Unique requirement number. Must not collide with any other requirement in the document.
/// - ics-assignment (str, array): One or more ICS role names this requirement is assigned to.
/// - level (str): Obligation level; one of `requirement-level.shall`, `.should`, or `.may`.
/// - body (content): The requirement text, which may also contain a `notes` object.
#let requirement(
  category: none,
  number: none,
  ics-assignment: none,
  level: none,
  body
) = {
  assert(
    category in (requirement-category.technical, requirement-category.risk, requirement-category.process),
    message: "category must be requirement-category.technical, requirement-category.risk, requirement-category.process"
  )

  assert(number != none, message: "Number passed is none")
  assert(level != none, message: "level passed is none")
  assert(ics-assignment != none, message: "requirements must be assigned at least one ics role")

  // Place the update and the invisible content in the document and check for collisions first
  add-requirement(number: number)

  let ics-assignments-array = if (type(ics-assignment) == str) {
    (ics-assignment, )
  } else {
    ics-assignment
  }

  let padded-number = _pad-requirement(number: number)
  let req-label-str = _requirement-anchor-prefix + ":" + str(number)

  [
    #counter(
      figure.where(kind: _requirement-figure-kind)
    ).update(number - 1)

    #context on-target(
      paged: {
        let req-label = label(req-label-str)
        show figure: set align(left)
        show figure: set block(breakable: true)
        [
          #figure(
            [#category.prefix#padded-number: #body],
            kind: _requirement-figure-kind,
            supplement: [#category.prefix#padded-number],
            numbering: (a) => [#h(-measure(" ").width)#padded-number],
          ) #req-label
        ]
        update-requirement(number: number, label: req-label, ics-assignment: ics-assignments-array, level: level)
      },
      html: {
        let ics-assignments = ics-assignments-array
          .enumerate()
          .map(it => { 
            let (counter, role) = it
            ("ics-assignment-" + str(counter), role) 
          }).to-dict()

        let (req-label, content) = ghost-html-elem(
          tag: _requirement-figure-kind,
          attrs: (
            "category": category.kind,
            "id": req-label-str,
            "number": str(number),
            "level": level,
          ) + ics-assignments,
          reference: req-label-str,
          supplement: [#category.prefix#padded-number],
          body: body,
        )
        
        [#content]
        update-requirement(number: number, label: req-label, ics-assignment: ics-assignments-array, level: level)
      },
    )
  ]
}

