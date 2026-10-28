// ICS roles must be indexed alphabetically, independent of the order in which
// requirements (and thus roles) were registered.
#import "/_internal/state.typ": add-requirement, update-requirement
#import "/_internal/ics.typ": _get-ics-map

#let register(number, roles) = {
  add-requirement(number: number)
  update-requirement(number: number, label: label("req-" + str(number)), ics-assignment: roles, level: "shall")
}

// deliberately registered out of alphabetical order
#register(1, ("Producer",))
#register(2, ("Consumer",))
#register(3, ("Alpha",))

#context {
  let ics-map = _get-ics-map()

  assert.eq(ics-map.keys(), ("Alpha", "Consumer", "Producer"))
  assert.eq(ics-map.at("Alpha").index, 1)
  assert.eq(ics-map.at("Consumer").index, 2)
  assert.eq(ics-map.at("Producer").index, 3)
  assert.eq(ics-map.at("Alpha").entries.first().ics-id, "ICS-3")
  assert.eq(ics-map.at("Producer").entries.first().ics-id, "ICS-1")
}
