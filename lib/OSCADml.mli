(** {1 OpenSCAD DSL} *)

module Scad : module type of Scad

(** {2 Configuration Types}

    These modules are provided at the top-level as convenient namespaces for
    the configuration types taken as parameters to their corresponding model
    building functions in {!module:Scad}. *)

module Color : module type of Color
module Text : module type of Text

(** {1 Vectors}

    Spatial vectors used to transform {!Scad.t} shapes, and compose into
    other types ({i e.g.} {!Path3.t}, {!Poly2.t}, and {!Mesh.t}) contained in
    the modules below, which can in turn used to generate point based shapes to
    be mapped into {!Scad.t}. *)

(** 3-dimensional vector *)
type v3 = OCADml.v3 =
  { x : float
  ; y : float
  ; z : float
  }

(** 2-dimensional vector *)
type v2 = OCADml.v2 =
  { x : float
  ; y : float
  }

(** [v2 x y]

    Construct a 2d vector from [x] and [y] coordinates. *)
val v2 : float -> float -> OCADml.v2

(** [v3 x y z]

    Construct a 3d vector from [x], [y], and [z] coordinates. *)
val v3 : float -> float -> float -> OCADml.v3

(** 2-dimensional vector type, including basic mathematical/geometrical
    operations and transformations mirroring those found in {!module:Scad},
    allowing for points in 2d space, and higher level types composed of them
    ({i e.g.} {!Path2.t} and {!Poly2.t}) to be manipulated in
    similar fashion to 2d OpenSCAD shapes ({!Scad.d2}). *)
module V2 : module type of OCADml.V2

(** 3-dimensional vector type, including basic mathematical/geometrical
    operations and transformations mirroring those found in {!module:Scad},
    allowing for points in 3d space, and higher level types composed of them
    ({i e.g.} {!Path3.t}, {!Poly3.t}, and {!Mesh.t}) to be manipulated in
    similar fashion to 3d OpenSCAD shapes ({!Scad.d3}). *)
module V3 : module type of OCADml.V3

(** {1 Transformations} *)

module Affine2 : module type of OCADml.Affine2
module Affine3 : module type of OCADml.Affine3
module Quaternion : module type of OCADml.Quaternion
module Plane : module type of OCADml.Plane

(** {1 2-dimensional paths and polygons} *)

module Path2 : module type of Path2
module Bezier2 : module type of OCADml.Bezier2
module CubicSpline : module type of OCADml.CubicSpline
module Poly2 : module type of Poly2
module PolyText : module type of OCADml.PolyText

(** {1 3-dimensional paths, coplanar polygons, and meshes} *)

module Path3 : module type of Path3
module Bezier3 : module type of OCADml.Bezier3
module Poly3 : module type of Poly3
module Mesh : module type of Mesh

(** {1 Utilities} *)

module Math : module type of OCADml.Math
module Easing : module type of OCADml.Easing
module Export : module type of Export
module BallTree2 : module type of OCADml.BallTree2
module BallTree3 : module type of OCADml.BallTree3
