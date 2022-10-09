(** Exporting [.scad] scripts through the OpenSCAD command line interface. *)

(** {1 2D/3D formats} *)

(** [script out_path in_path]

    Export the [.scad] script at [in_path] to a file at the given [out_path], in
    a format dictated by the extension of [out_path]. See documentation for the
    [-o] argument in the
    {{:https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment}
    OpenSCAD CLI docs} for available output formats. If export fails, an error
    containing captured Stderr output from OpenSCAD is returned (usually CGAL
    errors). *)
val script : string -> string -> (unit, string) result

(** {1 Images (PNG)} *)

(** OpenSCAD colour palettes *)
type colorscheme =
  | Cornfield
  | Metallic
  | Sunset
  | Starnight
  | BeforeDawn
  | Nature
  | DeepOcean
  | Solarized
  | Tomorrow
  | TomorrowNight
  | Monotone

(** View projection (as in OpenSCAD GUI) *)
type projection =
  | Perspective
  | Orthogonal

(** View options (as in OpenSCAD GUI) *)
type view =
  | Axes
  | Crosshairs
  | Edges
  | Scales
  | Wireframe

open OCADml

(** Camera position and orientation configuration *)
type camera =
  | Auto (** Automatically positon to view all of the object, and point at it's centre. *)
  | Gimbal of
      { translation : v3 (** origin shift vector *)
      ; rotation : v3 (** euler rotation vector (about translated origin) *)
      ; distance : [ `Auto | `D of float ]
            (** vertical distance of camera above shifted origin before rotation
                   (auto moves far enough away to bring object fully into frame) *)
      }
  | Eye of
      { lens : v3 (** lens position vector *)
      ; center : v3 (** center position vector (which lens points towards) *)
      ; view_all : bool (** override vector distance to ensure all object is visible *)
      }

(** Position camera such that object is centred and fully in view. *)
val auto : camera

(** [gimbal ?translation ?rotation d]

    Position and orient the camera as in the OpenSCAD GUI with [translation], and
    euler [rotation] vectors a (defaulting to {!V3.zero}). The focal point is
    moved from the origin by [translation], then the camera is positioned the
    distance [d] (manually, or far enough back to get the whole object into
    frame) straight upward in z before applying the euler [rotation]. *)
val gimbal : ?translation:v3 -> ?rotation:v3 -> [ `Auto | `D of float ] -> camera

(** [eye ?view_all ?center lens]

    Position the camera at [lens], and point it at [center]. If [view_all] is
    [true], then the camera will be moved along the difference vector to bring
    the whole object into the frame. *)
val eye : ?view_all:bool -> ?center:v3 -> v3 -> camera

(** [snapshot ?render ?colorscheme ?view ?projection ?size ?camera out_path in_path]

    Save an image ({b PNG} only at this time) of [size] pixels
    (default = [(500, 500)]) to [out_path] of the object defined by the [.scad]
    script located at [in_path] using the OpenSCAD CLI. By default, the [camera]
    is positioned automatically to point at the centre of the object, and far
    enough away such for it to all be in frame. See {!camera} and its {!gimbal}
    and {!eye} constructors for details on manual control. If export fails, an
    error containing captured Stderr output from OpenSCAD is returned (usually
    CGAL errors).

    - if [render] is [true], the object will be rendered before the snapshot is
      taken, otherwise preview mode is used (default = [false]).
    - [view] toggles on various viewport elements such as axes and scale ticks
    - [projection] sets the view style as in the GUI (default = [Perspective])
    - [colorscheme] selects the OpenSCAD colour palette (default = [Cornfield]) *)
val snapshot
  :  ?render:bool
  -> ?colorscheme:colorscheme
  -> ?view:view list
  -> ?projection:projection
  -> ?size:int * int
  -> ?camera:camera
  -> string
  -> string
  -> (unit, string) result

(** {1 File extension helpers} *)

module ExtSet : Set.S with type elt = string

(** Set of 2D output format file extensions: [".dxf"], [".svg"], [".csg"] *)
val d2_exts : ExtSet.t

(** Set of 3D output format file extensions: [".stl"], [".off"], [".amf"],
   [".3mf"], [".csg"], [".wrl"] *)
val d3_exts : ExtSet.t

(** [legal_ext allowed path]

    Check whether the extention of the file at [path] is in the [allowed],
    returning it as the error string if not. *)
val legal_ext : ExtSet.t -> string -> (unit, string) result
