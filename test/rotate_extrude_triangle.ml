open OSCADml

let triangle_polygon = Scad.polygon [ v2 (-0.5) 0.; v2 0. 1.; v2 0.5 0. ]
let rotate_extrude_triangle = Scad.revolve (Scad.translate (v2 3. 0.) triangle_polygon)
let () = print_string (Scad.to_string rotate_extrude_triangle)
