open OSCADml

let hello = Scad.text "Hello, world!"
let () = print_string (Scad.to_string hello)
