open OSCADml

let quat_slerp =
  let cyl = Scad.cylinder ~center:true ~height:20. 2.5 in
  let q0 = Quaternion.make (v3 0. 1. 0.) 0. in
  let q1 = Quaternion.make (v3 0. 1. 0.) (Float.pi /. 2.) in
  let slerp = Quaternion.slerp q0 q1 in
  let step t scad =
    Scad.quaternion (slerp t) scad |> Scad.translate (v3 0. (30. *. t) 0.)
  in
  Scad.union3
    [ cyl; step 0.1 cyl; step 0.5 cyl; step 0.7 cyl; step 0.90 cyl; step 1. cyl ]

let () = print_string (Scad.to_string quat_slerp)
