// glossary.typ — minimal dual-target glossary

#import "@preview/bullseye:0.1.0": *
#import "helper/referenceable-element.typ": ghost-html-elem, referencable-element
#import "helper/plural.typ": plural-for, plural-ref-for
#import "helper/make-reference.typ": make-reference

#let _glossary_entries = state("glossary-entries", (:))
#let _glossary_counts = state("glossary-counts", (:))
#let _glossary_label_prefix = ""

// Register entries from a list of dicts with at least (key, short)
// Optional: long, description, group, plural, long-plural
#let register-glossary(entries) = {
  _glossary_entries.update(old => {
    for e in entries {
      let short = e.at("short")
      let key = e.at("key", default: make-reference(short))

      let long = e.at("long", default: none)
      old.insert(
        key,
        e
          + (
            short: short,
            long: long,
            description: e.at("description", default: none),
            group: e.at("group", default: ""),
            plural: e.at("plural", default: plural-for(short)),
            long-plural: e.at("long-plural", default: plural-for(long)),
          ),
      )
    }
    old
  })
}

// Increment usage count and return the entry
#let _use-entry(key) = {
  _glossary_counts.update(c => {
    let n = c.at(key, default: 0)
    c.insert(key, n + 1)
    c
  })
}

// Core gls function — returns first-use or short form
#let gls(key, long: auto, plural: false, capitalize: false) = context {
  let entries = _glossary_entries.get()
  if key not in entries { panic("glossary: unknown key '" + key + "'") }
  let e = entries.at(key)
  let count = _glossary_counts.get().at(key, default: 0)

  let short = if plural { e.at("plural") } else { e.short }
  let long = if plural {
    if long == auto { e.long-plural } else { long-plural }
  } else {
    if long == auto { e.long } else { long }
  }
  if capitalize and type(short) == str { short = upper(short.first()) + short.slice(1) }

  _use-entry(key)

  let body = if count == 0 and long != none [#long (#short)] else [#short]

  link(label(_glossary_label_prefix + key), body)
}

// Convenience shorthands
#let glspl(key) = gls(key, plural: true)
#let Gls(key) = gls(key, capitalize: true)

// Print glossary — branches on target
#let print-glossary(
  render-entry-html: none,
  render-entry-paged: none,
  show-all: false,
) = {
  let default-paged(key, e) = {
    let actual-label = _glossary_label_prefix + key

    [
      #referencable-element(
        kind: "ref-glossary",
        reference: actual-label,
        displayed: [*#e.short*],
        appendix: [
          #if e.long != none [ — #e.long]
          #if e.description != none [: #e.description]
        ],
      ).at(1)
      #place(
        referencable-element(
          kind: "ref-glossary-plural",
          reference: plural-ref-for(actual-label),
          displayed: [#e.plural],
          render-text: false
        ).at(1),
      )
    ]
  }

  let default-html(key, e) = {
    let reference = _glossary_label_prefix + key
    let short = e.at("short", default: key)
    let attrs = ("id": reference, "short": short)

    if (e.description != none) {
      attrs.insert("description", e.description)
    }

    [
      #ghost-html-elem(
        tag: "glossary-plural",
        attrs: ("id": plural-ref-for(reference), "short": e.plural, "plural-for": reference),
        reference: plural-ref-for(reference),
        supplement: [#e.plural],
      ).at(1)
      #ghost-html-elem(
        tag: "glossary",
        attrs: attrs,
        reference: reference,
        supplement: [#short],
        body: [
          #e.long
        ],
      ).at(1)
    ]
  }

  let render-p = if render-entry-paged != none { render-entry-paged } else { default-paged }
  let render-h = if render-entry-html != none { render-entry-html } else { default-html }

  context {
    let entries = _glossary_entries.get()
    let sorted = entries.pairs().sorted(key: ((k, _)) => k)

    on-target(
      html: [
        #for (key, e) in sorted {
          render-h(key, e)
        }
      ],
      paged: [
        #for (key, e) in sorted {
          block(above: 0.6em, below: 0.3em)[
            #render-p(key, e)
          ]
        }
      ],
    )
  }
}
