include OCADml.Poly3

let[@inline] to_scad ?convexity t = Mesh.to_scad ?convexity @@ OCADml.Mesh.of_poly3 t
