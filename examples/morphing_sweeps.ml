(** {0 Morphing Sweeps} *)

open OCADml
open OSCADml

(** While {{!OCADml.Mesh.sweep}
    [Mesh.sweep]} and it's derived functions are useful for sweeping fixed
    polygons with holes, as shown in the {{!page-"rounded_polyhole_sweep"}
    rounded sweeps demo}, the {{!OCADml.Mesh.morphing_sweep} [Mesh.morphing_sweep]} family
    provides a means to do so with different shapes at the beginning and end. *)

let () =
  let path =
    let control =
      V3.[ v 0. 0. 2.; v 0. 20. 20.; v 40. 20. 10.; v 30. 0. 10. ]
      |> Path3.quaternion (Quaternion.make (v3 1. 1. 0.) (Float.pi /. -5.))
    in
    Bezier3.curve ~fn:60 @@ Bezier3.of_path ~size:(`Flat (`Rel 0.3)) control
  and caps =
    Mesh.Cap.(capped ~bot:(round @@ circ (`Radius 0.5)) ~top:(round @@ circ (`Radius 0.5)))
  and a = Poly2.ring ~fn:5 ~thickness:(v2 2.5 2.5) (v2 6. 6.)
  and b = Poly2.ring ~fn:80 ~thickness:(v2 2. 2.) (v2 4. 4.) in
  Mesh.path_morph ~refine:2 ~caps ~path ~outer_map:`Tangent a b
  |> Scad.of_mesh
  |> Scad.to_file "tangent_morph_sweep.scad"

(** {%html:
    <p style="text-align:center;">
    <img src="_assets/tangent_morph_sweep.png" style="width:150mm;"/>
    </p> %}
    *)

(** Similar to the [?scale_ez] and [?twist_ez] parameters on
    {{!OCADml.Path3.to_transforms} [Path3.to_transforms]} and those that make
    use of it, such as {{!OCADml.Mesh.morph} [Mesh.morph]}, the
    morphing sweep functions in the {{!OCADml.Mesh} [Mesh]} module expose [?ez], which offers
    the same style of bezier easing (see {{!OCADml.Easing} [Easing]}) for morphs. *)

let scad =
  let top =
    Mesh.morph
      ~refine:2
      ~ez:(v2 0.42 0., v2 1. 1.)
      ~slices:60
      ~outer_map:`Tangent
      ~height:3.
      (Poly2.ring ~fn:5 ~thickness:(v2 0.5 0.5) (v2 4. 4.))
      (Poly2.ring ~fn:80 ~thickness:(v2 0.2 0.2) (v2 1. 1.))
    |> Scad.of_mesh
  in
  Scad.(add (ztrans 2. top) (ztrans (-2.) @@ xrot Float.pi top))

(** As the generated mesh contains quite a large number of points due to the
    large number of slices and the resolution of the inner ring (and the
   duplication) of the shape (megabytes), we'll take advantage of the [include]
   trick provided by the optional [?incl] parameter to {{!OSCADml.Scad.to_file}
   [Scad.to_file]}. This will produce a pair of [.scad] scripts, one named
   ["incl_eased_morph.scad"], and another named ["eased_morph.scad"] that simply
   includes it. By loading the later into OpenSCAD rather than the former, we
   can avoid the sluggishness that can result when the editor attempts to handle
   large files. *)

let () = Scad.to_file ~incl:true "eased_morph.scad" scad

(** {%html:
    <p style="text-align:center;">
    <img src="_assets/eased_morph.png" style="width:150mm;"/>
    </p> %}
    *)
