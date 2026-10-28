// A requirement assigned to several roles appears once in each role.
#import "/_internal/state.typ": add-requirement, update-requirement
#import "/_internal/ics.typ": _get-ics-map

#add-requirement(number: 1)
#update-requirement(number: 1, label: <req-1>, ics-assignment: ("Producer", "Consumer"), level: "shall")
#add-requirement(number: 2)
#update-requirement(number: 2, label: <req-2>, ics-assignment: ("Consumer",), level: "should")

#context {
  let ics-map = _get-ics-map()

  assert.eq(ics-map.keys(), ("Consumer", "Producer"))
  assert.eq(ics-map.at("Consumer").entries.map(e => e.ics-id), ("ICS-1", "ICS-2"))
  assert.eq(ics-map.at("Producer").entries.map(e => e.ics-id), ("ICS-1",))
  assert.eq(ics-map.at("Consumer").entries.at(1).entry.req-level, "should")
}
