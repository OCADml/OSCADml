open OCADml

let show_path2 f path =
  Scad.union (List.mapi (fun i p -> Scad.translate (V3.of_v2 p) (f i)) path)

let show_path3 f path = Scad.union (List.mapi (fun i p -> Scad.translate p (f i)) path)
let[@inline] show_mesh f mesh = show_path3 f @@ Mesh.points mesh
