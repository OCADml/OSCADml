include OCADml.Path3

let show_points f t = Scad.union (List.mapi (fun i p -> Scad.translate p (f i)) t)
