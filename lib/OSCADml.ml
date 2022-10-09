module Scad = Scad
module Color = Color
module Text = Text

type v3 = OCADml.v3 =
  { x : float
  ; y : float
  ; z : float
  }

type v2 = OCADml.v2 =
  { x : float
  ; y : float
  }

let[@inline] v2 x y = OCADml.v2 x y
let[@inline] v3 x y z = OCADml.v3 x y z

module V2 = OCADml.V2
module V3 = OCADml.V3
module Affine2 = OCADml.Affine2
module Affine3 = OCADml.Affine3
module Quaternion = OCADml.Quaternion
module Plane = OCADml.Plane
module Path2 = Path2
module Bezier2 = OCADml.Bezier2
module CubicSpline = OCADml.CubicSpline
module Poly2 = Poly2
module PolyText = OCADml.PolyText
module Path3 = Path3
module Bezier3 = OCADml.Bezier3
module Poly3 = Poly3
module Mesh = Mesh
module Math = OCADml.Math
module Easing = OCADml.Easing
module Export = Export
module BallTree2 = OCADml.BallTree2
module BallTree3 = OCADml.BallTree3
