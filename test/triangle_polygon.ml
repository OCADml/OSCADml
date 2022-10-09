open OCADml
open OSCADml

let triangle_polygon = Scad.polygon [ v2 (-0.5) 0.; v2 0. 1.; v2 0.5 0. ]
let () = print_string (Scad.to_string triangle_polygon)
