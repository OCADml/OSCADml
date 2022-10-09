(** Generation, and manipulation of 3-dimensional meshes (points and faces)
    that can be mapped into {!Scad.d3} as polyhedrons.

    This data type and its constructors / transformers is based on the
    the {{:https://github.com/revarbat/BOSL2/blob/master/vnf.scad} vnf
    structure module} of
    the {{:https://github.com/revarbat/BOSL2/} BOSL2 OpenSCAD library}. *)

include module type of struct
  include OCADml.Mesh
end

(** {1 Debugging helpers} *)

val show_points : (int -> Scad.d3) -> t -> Scad.d3

(** {1 Output} *)

val to_scad : ?convexity:int -> t -> Scad.d3
