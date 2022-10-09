include OCADml.Poly2

let to_scad ?convexity { outer; holes } =
  match holes with
  | []    -> Scad.polygon ?convexity outer
  | holes ->
    let _, points, paths =
      let f (i, points, paths) h =
        let i, points, path =
          let g (i, points, path) p = i + 1, p :: points, i :: path in
          List.fold_left g (i, points, []) h
        in
        i, points, path :: paths
      in
      List.fold_left f (0, [], []) (outer :: holes)
    in
    Scad.polygon ?convexity ~paths:(List.rev paths) (List.rev points)
