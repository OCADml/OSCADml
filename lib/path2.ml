include OCADml.Path2

let show_points f t =
  Scad.union (List.mapi (fun i p -> Scad.translate (OCADml.V3.of_v2 p) (f i)) t)

let to_scad ?convexity t = Scad.polygon ?convexity t
