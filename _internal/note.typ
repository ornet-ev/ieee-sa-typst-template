#import "@preview/bullseye:0.1.0": *
#import "@preview/typsy:0.2.2": safe-counter
#import "helper/referenceable-element.typ": ghost-html-elem, referencable-element

#let _notes-counter = safe-counter(() => {})


/// Renders a group of notes, automatically numbering them (NOTE 1, NOTE 2, …).
/// Each argument must be a dict produced by `note()`.
/// - ..notes (arguments): One or more `note()` dicts to render as a numbered group.
#let notes(
  ..notes,
) = {
  _notes-counter.step()
  context {
    let auto-reference-prefix = "auto:note-label:"
    // attach a number to each passed note
    // entry structure:
    // (index, note, reference, displayed label)
    let numbered-notes = notes
      .pos()
      .enumerate(start: 1)
      .map(pair => {
        let (index, note) = pair

        let auto-reference = auto-reference-prefix + str(_notes-counter.get().at(0)) + "-" + str(index)

        assert(type(note) == dictionary, message: "expected a tuple dictionary for notes, found: ")
        assert("body" in note, message: "missing key: body")
        assert("reference" in note, message: "missing key: reference")

        let effective-reference = if note.reference == none {
          auto-reference
        } else {
          note.reference
        }

        (
          index,
          note.body,
          effective-reference,
          "NOTE " + str(index),
        )
      })

    on-target(
      paged: {
        numbered-notes
          .map(pair => {
            let (index, note, reference, displayed_label) = pair

            referencable-element(
              kind: "ref-note",
              displayed: displayed_label,
              reference: reference,
              appendix: note,
            ).at(1)
          })
          .join()
      },
      html: {
        html.elem(
          "notes",
          numbered-notes
            .map(data => {
              let (index, note, reference, displayed_label) = data

              ghost-html-elem(
                tag: "note",
                attrs: (
                  "id": reference,
                  "index": str(index),
                  "label": displayed_label,
                ),
                reference: reference,
                supplement: [#reference],
                body: [#note],
              ).at(1)
            })
            .join(),
        )
      },
    )
  }
}

/// Creates a note dict to be passed to `notes()`.
/// - reference (str): Identifier for cross-referencing this note. Pass `none` if no reference is needed.
/// - body (content): The note content.
#let note(reference: none, body) = (reference: reference, body: body)
