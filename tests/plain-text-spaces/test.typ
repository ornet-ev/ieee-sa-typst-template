// Spaces between differently styled pieces must survive.
// KNOWN FAILING: `space` elements have no children/body/text and fall through
// to "", so this currently yields "boldandit".
#import "/_internal/helper/referenceable-element.typ": _plain-text

#assert.eq(_plain-text([*bold* and _it_]), "bold and it")
#assert.eq(_plain-text([a #emph[b] c]), "a b c")
