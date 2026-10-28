// Within a role, entries are sorted numerically by requirement number and get
// ids matching their requirement number; roles are sorted case-sensitively (uppercase first).
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
  assert.eq(beta.map(e => e.ics-id), ("ICS-1", "ICS-3", "ICS-4"))
  assert.eq(beta.map(e => e.entry.req-id), ("1", "3", "4"))
}
