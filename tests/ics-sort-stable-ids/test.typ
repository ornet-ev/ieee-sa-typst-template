// Within a role, entries keep requirement registration order and get
// consecutive ids; roles are sorted case-sensitively (uppercase first).
#import "/_internal/state.typ": add-requirement, update-requirement
#import "/_internal/ics.typ": _get-ics-map

#let register(number, roles) = {
  add-requirement(number: number)
  update-requirement(number: number, label: label("req-" + str(number)), ics-assignment: roles, level: "shall")
}

#register(3, ("beta",))
#register(1, ("beta",))
#register(2, ("Zeta",))
#register(4, ("beta",))

#context {
  let ics-map = _get-ics-map()

  assert.eq(ics-map.keys(), ("Zeta", "beta"))

  let beta = ics-map.at("beta").entries
  assert.eq(beta.map(e => e.ics-id), ("ICS-2-1", "ICS-2-2", "ICS-2-3"))
  assert.eq(beta.map(e => e.entry.req-id), ("3", "1", "4"))
}
