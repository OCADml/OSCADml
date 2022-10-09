open OCADml

let show_path2 f t =
  Scad.union (List.mapi (fun i p -> Scad.translate (V3.of_v2 p) (f i)) t)

let show_path3 f t = Scad.union (List.mapi (fun i p -> Scad.translate p (f i)) t)
let[@inline] show_mesh f t = show_path3 f t.Mesh.points
