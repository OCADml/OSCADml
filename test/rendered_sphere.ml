open OSCADml

let rendered_sphere = Scad.sphere ~fn:100 5. |> Scad.render
let () = print_string (Scad.to_string rendered_sphere)
