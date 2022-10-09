(** 2d path generation (including arcs and basic shapes), manipulation
   (including offset and roundovers (see {!module:Round}), and measurement. *)

include module type of struct
  include OCADml.Path2
end

(** {1 Debugging helpers} *)

val show_points : (int -> Scad.d3) -> t -> Scad.d3

(** {1 Output} *)

(** [to_scad ?convexity t]

    Create a {!Scad.t} from the path [t], via {!Scad.polygon}. *)
val to_scad : ?convexity:int -> t -> Scad.d2
