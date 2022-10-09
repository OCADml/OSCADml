open OSCADml

let vertical_text =
  Scad.text "Tall Text" ~spacing:5. ~valign:Text.Top ~direction:Text.TopToBottom

let () = print_string (Scad.to_string vertical_text)
