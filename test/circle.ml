open OSCADml

let circle = Scad.circle 10.
let () = print_string (Scad.to_string circle)
