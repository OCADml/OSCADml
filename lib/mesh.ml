include OCADml.Mesh

let show_points f t = Scad.union (List.mapi (fun i p -> Scad.translate p (f i)) t.points)
let to_scad ?convexity { points; faces; _ } = Scad.polyhedron ?convexity points faces
