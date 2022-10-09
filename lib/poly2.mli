(** 2d polygons (made up of an outer, and zero or more inner {!Path2.t}s) that map into
   {!Scad.d2}. Includes basic shape creation helpers, manipulations, (including
    offset and basic transformations), measurement, and validation. *)

include module type of struct
  include OCADml.Poly2
end

(** {1 Output} *)

(** [to_scad ?convexity t]

    Create a {!Scad.t} from the polygon [t], via {!Scad.polygon}. *)
val to_scad : ?convexity:int -> t -> Scad.d2
