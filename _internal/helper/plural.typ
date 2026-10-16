
#let plural-for(singular) = {
  if singular != none { singular + "s" } else { none }
}

#let plural-ref-for(reference) = {
  return reference + ":s"
}