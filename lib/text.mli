(** {!Scad.text} configuration parameter types *)

(** Horizontal alignment *)
type h_align = Text0.h_align =
  | Left
  | Center
  | Right

(** Vertical alignment *)
type v_align = Text0.v_align =
  | Top
  | Center
  | Baseline

(** Reading direction *)
type direction = Text0.direction =
  | LeftToRight
  | RightToLeft
  | TopToBottom
  | BottomToTop
