open OSCADml

let quat_cube =
  (* NOTE: These cubes should be equivalent if quaternion is working correctly. *)
  let box = Scad.cube ~center:true (v3 10. 10. 10.)
  and angle = Float.pi /. 4.
  and ax = v3 1. 1. 0. in
  let a = Scad.axis_rotate ax angle box
  and b = Scad.affine Quaternion.(to_affine (make ax angle)) box in
  Scad.union3 [ a; b ]

let () = print_string (Scad.to_string quat_cube)
