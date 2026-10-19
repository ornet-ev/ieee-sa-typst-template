// Split a string at a regex pattern and return the parts with the separator.
// From: https://github.com/typst/typst/issues/1710#issuecomment-1657263342
#let split-with-sep(s, pattern) = {
  let prev = 0
  for m in s.matches(pattern) {
    (s.slice(prev, m.start), m.text)
    prev = m.end
  }
  (s.slice(prev),)
}

#let hypenation-pattern = regex("([a-z])([A-Z])")

// Hyphenate a string by splitting camel case words at boundaries between lowercase and uppercase letters and inserting a zero-width space.
// This allows the text to be hyphenated at these points, as needed by typst.
#let hyphenate-camel-case(text) = {
  // Use regex to split camel case words at boundaries between lowercase and uppercase letters.
  let parts = split-with-sep(text, hypenation-pattern)

  // we've separated the parts, but due to our pattern, we still need to split those parts and join them with a zero-width joiner
  parts = parts
    .map(part => {
      if part.find(hypenation-pattern) != none {
        part.at(0) + "\u{200B}" + part.at(1)
      } else {
        part
      }
    })
    .join()

  parts
}

// regex pattern to find periods that are directly preceeded and followed by a letter
// these are typically used in package names
#let hypenation-pattern-periods = regex("([a-zA-Z])\.([a-zA-Z])")

// Hyphenate a string by inserting zero-width spaces preceeding an underscore.
// This allows the text to be hyphenated at these points, as needed by typst.
#let hypenate-underscores(text) = {
  text.replace("_", "\u{200B}_")
}

// Hyphenate a string by inserting zero-width spaces preceeding a period, if the period is immediately followed by a letter. This is usually the case for package names.
#let hyphenate-period(text) = {
  let parts = split-with-sep(text, hypenation-pattern-periods)

  // we've separated the parts, but due to our pattern, we still need to split those parts and join them with a zero-width joiner
  parts = parts
    .map(part => {
      if part.find(hypenation-pattern-periods) != none {
        part.replace(".", "\u{200B}.")
      } else {
        part
      }
    })
    .join()

  parts
}

// Hyphenate a plain string using camel case, period and underscore rules.
#let hyphenate-string(text) = {
  hyphenate-camel-case(hypenate-underscores(hyphenate-period(text)))
}

// Hyphenate using camel case, period and underscore rules.
// Accepts strings as well as content; for content, the text elements are processed recursively.
#let hyphenate(it) = {
  if type(it) == str {
    hyphenate-string(it)
  } else if type(it) == content {
    if it.has("text") {
      // a text element, e.g. [my_test]
      [#hyphenate-string(it.text)]
    } else if it.has("children") {
      // a sequence of elements
      it.children.map(hyphenate).join()
    } else if it.has("body") {
      // wrapper elements like strong, emph, link, ...; keep all other fields
      let fields = it.fields()
      let body = fields.remove("body")
      (it.func())(..fields, hyphenate(body))
    } else {
      it
    }
  } else {
    it
  }
}