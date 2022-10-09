(** {0 Path extrusions (standard and euler)} *)
open OSCADml

let () =
  let step = 0.005 in
  let path =
    let f i =
      let t = Float.of_int i *. step in
      let x =
        ((t /. 1.5) +. 0.5) *. 100. *. Float.cos (6. *. 360. *. t *. Float.pi /. 180.)
      and y =
        ((t /. 1.5) +. 0.5) *. 100. *. Float.sin (6. *. 360. *. t *. Float.pi /. 180.)
      and z = 200. *. (1. -. t) in
      v3 x y z
    in
    List.init (Int.of_float (1. /. step)) f
  and poly =
    [ -10., -1.; -10., 6.; -7., 6.; -7., 1.; 7., 1.; 7., 6.; 10., 6.; 10., -1. ]
    |> Path2.of_tups
    |> Poly2.make
  in
  Scad.to_file "sweep_path.scad" Mesh.(to_scad @@ path_extrude ~path poly);
  Scad.to_file
    "sweep_path_euler.scad"
    Mesh.(to_scad @@ path_extrude ~euler:true ~path poly)
