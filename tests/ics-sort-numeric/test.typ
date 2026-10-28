// Entries within a role are sorted numerically by requirement number, not
// lexicographically (10 must come after 9).
#import "/_internal/state.typ": add-requirement, update-requirement
#import "/_internal/ics.typ": _get-ics-map

#let register(number, roles) = {
  add-requirement(number: number)
  update-requirement(number: number, label: label("req-" + str(number)), ics-assignment: roles, level: "shall")
}

#register(10, ("Producer",))
#register(9, ("Producer",))
#register(100, ("Producer",))

#context {
  let ics-map = _get-ics-map()

  let entries = ics-map.at("Producer").entries
  assert.eq(entries.map(e => e.ics-id), ("ICS-9", "ICS-10", "ICS-100"))
}
