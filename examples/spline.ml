(** {0 Cublic Spline} *)

open OCADml
open OSCADml

(** Control points that our
    {{:https://mathworld.wolfram.com/CubicSpline.html}cubic spline} will pass
    through. *)
let control = [ v2 0. 10.; v2 10. 40.; v2 20. 40.; v2 30. (-20.); v2 40. (-40.) ]

(** Mark our [control] points with the debugging helper
    {{!OSCADml.Debug.show_path2} [Debug.show_path2]} for reference. We don't
    really need to number these, so we'll ignore the index parameter and use
    the same sphere for each point. *)
let marks = Debug.show_path2 Scad.(fun _ -> color Color.Magenta @@ sphere 2.) control

(** Fit a cubic spline to the [control] points, and interpolate [fn] points
    along it using the helper {{!OCADml.Path2.cubic_spline}
    [Path2.cubic_spline]} (lower level functions available in the
    {{!OCADml.CubicSpline} [CubicSpline]} module), then sweep a [rectangle]
    along it. *)
let line =
  let rectangle = Poly2.square ~center:true (v2 2. 5.)
  and path = Path3.of_path2 @@ Path2.cubic_spline ~fn:100 control in
  Scad.of_mesh @@ Mesh.path_extrude ~path rectangle

(** Union our control point [marks] and [line] sweep shapes and output to file. *)
let () = Scad.to_file "spline.scad" (Scad.union [ line; marks ])

(** {%html:
    <p style="text-align:center;">
    <img src="_assets/spline.png" style="width:150mm;"/>
    </p> %}
    *)
