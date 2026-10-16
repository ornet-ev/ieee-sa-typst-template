
#let make-reference(it) = {
  // transformation rule: replace spaces with underscores
  let normalized = it.replace(" ", "_")

  // check for valid characters (alphanumerics, hyphens, underscores, colons, and dots)
  let allowed = regex("^[a-zA-Z0-9\-_:.]+$")
  if normalized.match(allowed) == none {
    panic("Name: '" + it + "' contains characters not allowed in automatic reference generation, please provide a custom reference")
  }

  normalized
}