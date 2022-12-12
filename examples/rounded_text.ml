(** {0 Rounded text extrusion} *)

open OCADml
open OSCADml

(** Generate a list of {{!OCADml.Poly2.t} [Poly2.t]} spelling out {b Hello
    World!}. At the moment, {{!OCADml.PolyText.text} [PolyText.text]} is not
    as flexible and feature rich as {{!OSCADml.Scad.text} [Scad.text]}
    (OpenSCADs text shape function), but this gives up point representations
    that be can work with directly. *)
let hello = PolyText.text ~center:true ~fn:5 ~size:5. ~font:"Ubuntu" "Hello!"

(** Circular roundovers with [fn] steps, specified by a distance to be [`Cut]
    off of the corners. You can expect some finickiness with applying
    roundovers to the polygons produced by {{!OCADml.PolyText.text}
    [PolyText.text]}, as the paths coming from Cairo may have some points quite
    close together, and sharp corners, leading to illegal paths when further
    roundover operations are applied. *)
let caps =
  let spec = Mesh.Cap.(round ~mode:Delta @@ circ ~fn:5 (`Cut 0.025)) in
  Mesh.Cap.capped ~top:spec ~bot:spec

(** Map over the character polys in [hello] with a rounded extrusion funcion
    specified by [caps], and convert into {{!OSCADml.Scad.t} [Scad.t]}s that we
    can union to create our final model. *)

let extruder poly = Scad.of_mesh @@ Mesh.extrude ~caps ~height:0.5 poly
let () = List.map extruder hello |> Scad.union |> Scad.to_file "rounded_text.scad"

(** {%html:
    <p style="text-align:center;">
    <img src="../assets/rounded_text.png" style="width:150mm;"/>
    </p> %}
    *)
