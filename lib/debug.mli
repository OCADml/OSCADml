open OCADml

(** [show_path2 f path]

    Return a union of 3d shapes provided by placing shapes (computed by applying
    [f] to the index) at each point along [path]. *)
val show_path2 : (int -> Scad.d3) -> Path2.t -> Scad.d3

(** [show_path3 f path]

    Return a union of 3d shapes provided by placing shapes (computed by applying
    [f] to the index) at each point along [path]. *)
val show_path3 : (int -> Scad.d3) -> Path3.t -> Scad.d3

(** [show_mesh f mesh]

    Return a union of 3d shapes provided by placing shapes (computed by applying
    [f] to the index) at each point in [mesh]. *)
val show_mesh : (int -> Scad.d3) -> Mesh.t -> Scad.d3
