#import "state.typ": get-all-requirements, ics-key, req-label-key, req-level-key
#import "glossary.typ": gls
#import "helper/referenceable-element.typ": _plain-text
#import "@preview/bullseye:0.1.0": *


#let _get-ics-map() = {
  // load all known requirements
  let requirement-data = get-all-requirements()

  // group requirements by their ics roles
  let grouped-by-ics = (:)

  for (key, value) in requirement-data.pairs() {
    let ics-roles = value.at(ics-key)

    for ics-role in ics-roles {
      if (grouped-by-ics.at(ics-role, default: none) == none) {
        grouped-by-ics.insert(ics-role, ())
      }

      if (value.at(req-label-key, default: none) == none) {
        panic(value)
      }

      grouped-by-ics.at(ics-role).push(
        (
          "req-id": key,
          (req-label-key): value.at(req-label-key),
          (req-level-key): value.at(req-level-key)
        )
      )
    }

  }

  // assign an index or id to every entry
  let return-value = grouped-by-ics.pairs()
    // sort entries alphabetically first for stability, give them an index afterwards
    .sorted(key: it => it.at(0))
    .enumerate()
    .map(it => {
      let (counter, entries) = it
      let (ics, requirements) = entries

      // entries are sorted by requirement number; the ics id corresponds to it, e.g. TR0090 -> ICS-90
      let mapped-entries = requirements
        .sorted(key: req-data => int(req-data.at("req-id")))
        .map(req-data => (
          "ics-id": "ICS-" + req-data.at("req-id"),
          "entry": req-data
        ))
      (
        (ics),
        (
          "ics": ics,
          "index": counter + 1,
          "entries": mapped-entries,
        )
      )
    }).to-dict()

  assert(type(return-value) == dictionary, message: "invalid return type")

  return-value
}

#let _render-ics-tables-paged(ics-map, feature) = {
  // sort names for document stability

  let ics-role = ics-map.at(feature)

  [== #feature]

  figure(
    table(
      columns: (0.6fr, 0.7fr, 0.9fr, 0.5fr, auto),
      align: top + left,
      table.header([*Index*], [*Reference*], [*Support*], [*Status*], [*Comment*]),
      ..(
        ics-role.at("entries")
          .map(entry-dict => {
            let ics-id = entry-dict.ics-id
            let entry = entry-dict.entry
          (
            [#ics-id],
            [#ref(entry.at(req-label-key))],
            [#entry.at(req-level-key)],
            [],
            [],
          )
        })
      ).flatten(),
    ),
    caption: [(normative) #gls("ICS") table for #feature]
  )
}

#let _render-ics-tables-html(html, ics-map, feature) = {

  // panic(ics-map)
  let ics-role = ics-map.at(feature)

  assert(ics-role != none, message: "ICS map does not contain entry for " + feature)

  html.elem("ics-role", attrs: (
    "role-name": feature
  ))[#{
    html.elem("ics-header")[
      #html.elem("span")[Index]
      #html.elem("span")[Reference]
      #html.elem("span")[Support]
    ]

    for entry-dict in ics-role.at("entries") {
      // panic(entry-dict)

      let ics-id = entry-dict.ics-id
      let entry = entry-dict.entry
      let req-label = entry.at(req-label-key)
      let req-id = str(req-label)

      // resolve the displayed requirement label (e.g. TR0001) from the requirement's supplement
      let found = query(req-label)
      let req-display = if found.len() > 0 {
        _plain-text(found.first().supplement)
      } else {
        req-id
      }

      html.elem("ics-entry", attrs: (
        "ics-id": ics-id,
        "requirement-id": req-id,
        "requirement-label": req-display,
        "level": entry.at(req-level-key)
      ))[#html.elem("a", attrs: ("href": "#" + req-id))[#req-display]]
    }
  }]
}

// todo make public?
#let render-ics-tables() = context {

  let ics-map = _get-ics-map()
  // panic(ics-map)
  let ics-roles = ics-map
    .pairs()
    .map(it => {
      let (role, data) = it

      (role, data.index)
    })
    .sorted(key: it => it.at(1))

  for (role, _) in ics-roles {

    on-target(
        paged: {
          _render-ics-tables-paged(ics-map, role)
        },
        html: {
          _render-ics-tables-html(html, ics-map, role)
        },
    )
  }
}


/// Renders the ICS table for a single feature/role.
/// - feature (str): The ICS role name to render a table for.
#let render-ics-table(
  feature: none,
) = context {
  assert(feature != none, message: "feature must be selected")

  let ics-map = _get-ics-map()

  on-target(
    paged: {
      _render-ics-tables-paged(ics-map, feature)
    },
    html: {
      _render-ics-tables-html(html, ics-map, feature)
    },
  )
}