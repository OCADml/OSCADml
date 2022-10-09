(** Planar 3d polygons (made up of an outer, and zero or more inner {!Path3.t}s) that map into
   {!Scad.d2}. Includes basic shape creation helpers, manipulations, (including
    offset and basic transformations), measurement, and validation. *)

include module type of struct
  include OCADml.Poly3
end

(** {1 Output}

    Mapping from {!t} into a {!Scad.d3} can be done via {!Mesh.to_scad}, by way
    of {!Mesh.of_poly3}. *)

val to_scad : ?convexity:int -> t -> Scad.d3
