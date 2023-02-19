(** {0 Bespoke Sweeps} *)

open OCADml
open OSCADml

(** Sometimes one may need more control than what
    {{!OCADml.Path3.to_transforms} [Path3.to_transforms]} (and by extension
    {{!OCADml.Mesh.path_extrude} [Mesh.path_extrude]}) provide. For instance, as
    demonstrated below with the {{!wavey} wavey cylinder}, when non-monotonic
    scaling throughout a sweep is desired. In those scenarios,
    generating/composing lists of {{!OCADml.Affine3.t} [Affine3.t]} by
    other means and giving those to {{!OCADml.Mesh.sweep} [Mesh.sweep]} is an
    option. *)

(** {1 Flat Spiral} *)

(** A plain, centred square with which to draw our spiral. *)
let square = Poly2.square ~center:true (v2 10. 10.)

(** A series of affine transformation matrices describing a spiral. *)
let transforms =
  let step = 0.001 in
  let f i =
    let t = Float.of_int i *. step in
    Affine3.(
      mul
        (axis_rotate (v3 0. 0. 1.) (t *. Float.pi *. 40.))
        (translate (v3 (10. +. (500. *. t)) 0. 0.)) )
  in
  List.init (Int.of_float (1. /. step) + 1) f

(** {{!OCADml.Mesh.sweep} [Mesh.sweep]} applies each of the transforms to
    [square] in its {i original} state, linking up each resulting loop of
    points with the next to form a mesh that we can convert into an OpenSCAD polyhedron. *)
let () = Scad.to_file "spiral.scad" @@ Scad.of_mesh @@ Mesh.sweep ~transforms square

(** {%html:
    <p style="text-align:center;">
    <img src="_assets/spiral.png" style="width:150mm;"/>
    </p> %}
    *)

(** {1:wavey Wavey Hollow Cylinder} *)

let () =
  let r = 10.
  and h = 20.
  and s = 2.
  and step = 4.
  and rad d = d *. Float.pi /. 180. in
  let f i =
    let t = Float.of_int i *. step in
    Affine3.(
      mul
        (mul (rotate (v3 (rad 90.) 0. (rad t))) (translate (v3 r 0. 0.)))
        (scale (v3 1. (h +. (s *. Float.sin (rad (t *. 6.)))) 1.)) )
  in
  Mesh.sweep ~transforms:(List.init ((360 / 4) + 1) f) (Poly2.square (v2 2. 1.))
  |> Scad.of_mesh
  |> Scad.to_file "wave_cylinder.scad"

(** {%html:
    <p style="text-align:center;">
    <img src="_assets/wave_cylinder.png" style="width:150mm;"/>
    </p> %}
    *)
