// tracks all requiremens number which were used in the document
#let _requirements-state-name = "requirements"
#let requirement-numbers = state(_requirements-state-name, (:))

// currently unused
#let _has-requirement(number: int) = {
  requirement-numbers.get().contains(number)
}


#let ics-key = "ics-key"
#let req-label-key = "req-label"
#let req-level-key = "req-level"

/// 
///
/// - number (int): requirement number
/// - ics-assignment (array of string): the assigned ics for the requirement 
/// -> 
#let add-requirement(number: none, label: none, ics-assignment: none) = {
  assert(number != none, message: "requirement number cannot be none")

  let number-str = str(number)

  requirement-numbers.update(old => {
    assert(old != none, message: "Old is none, this cannot stand!")

    assert(
      old.at(number-str, default: none) == none,
      message: "Requirement " + str(number) + " is already in use" 
    )
    old.insert(
      number-str,
      (:)
    )
    old
  })
}

#let update-requirement(number: none, label: none, ics-assignment: none, level: none) = {
  assert(number != none, message: "requirement number cannot be none")
  assert(label != none, message: "label cannot be none")
  assert(ics-assignment != none, message: "ics-assignment cannot be none")
  assert(level != none, message: "level cannot be none")

  let number-str = str(number)

  requirement-numbers.update(old => {
    assert(old != none, message: "Old is none, this cannot stand!")

    old.at(number-str).insert(
      (ics-key), ics-assignment
    )
    old.at(number-str).insert(
      (req-label-key), label,
    )
    old.at(number-str).insert(
      (req-level-key), level,
    )

    old
  })
}


/// Returns all known requirements as a dictionary
/// 
///
/// -> dictionary
/// key: requirement number (int)
/// value: dictionary of additional information
///       key: ics-key
///       value: assigned ics
#let get-all-requirements() = {
  requirement-numbers.get()
}