(** 3d path generation (including arcs and basic shapes), manipulation
   (including roundovers (see {!module:Round}), and conversion to sweeping
   transformations with {!to_transforms}), and measurement. *)

include module type of struct
  include OCADml.Path3
end

(** {1 Debugging helpers} *)

val show_points : (int -> Scad.d3) -> t -> Scad.d3
