// _plain-text unwraps the leaf cases: str, text and single-body elements.
#import "/_internal/helper/referenceable-element.typ": _plain-text

#assert.eq(_plain-text("plain"), "plain")
#assert.eq(_plain-text([hello world]), "hello world")
#assert.eq(_plain-text(strong[bold]), "bold")
#assert.eq(_plain-text(emph[it]), "it")
#assert.eq(_plain-text(smallcaps[Sc]), "Sc")
#assert.eq(_plain-text(raw("code")), "code")
