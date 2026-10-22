// _plain-text recurses through sequences and nested styling, dropping all formatting.
#import "/_internal/helper/referenceable-element.typ": _plain-text

#assert.eq(_plain-text(strong(emph[deep])), "deep")
#assert.eq(_plain-text([a#emph[b#strong[c]]d]), "abcd")
#assert.eq(_plain-text([*x*#[y]]), "xy")
