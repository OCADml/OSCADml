(** Build scad models with well-typed dimensional system (3d / 2d) aware
    functions mapping down onto the similarly named operations made available
    by the OpenSCAD language.

    OpenSCAD objects and the operations upon them are represented by the
    recursive type {!type:t}, which can then finally be translated into a scad
    script. As this transpiles down to OpenSCAD, the
    {{:https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language}
    User Manual} can be referred to for additional information about most of the
    functions (and examples of output) made available here. *)

open OCADml

(** The scad type is kept abstract, as the available constructor functions
    provide much less cumbersome means of building up models. *)
type scad

(** This GADT allows scads to be tagged as 2D or 3D, restricting usage of functions
    that should only apply to one or the other, and preventing mixing during
    boolean operations.
    - The ['space] parameter can be {!V2.t} or {!V3.t}, corresponding to
      dimensions over which the scad can be transformed.
    - The ['rot] parameter corresponds to the axes rotation available to the
      scad. For 2d shapes, this is a [float] representing z-axis rotation, and
      for 3d shapes, xyz axes are available through {!V3.t}.
    - The ['affine] parameter can be {!Affine2.t} or {!Affine3.t}, specifying
      the affine transformation matrix to use for the {!affine} function (which
      maps down to {{:https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#multmatrix}
      multmatrix} in OpenSCAD). *)
type ('space, 'rot, 'affine) t

(** Two-dimensional shape *)
type d2 = (V2.t, float, Affine2.t) t

(** Three-dimensional shape *)
type d3 = (V3.t, V3.t, Affine3.t) t

(** {1 A note on special facet parameters}

    The optional parameters ?fa, ?fs, and ?fn correspond to the OpenSCAD
    "special parameters" governing the number of facets used to generate arcs
    ({b $fa}, {b $fs}, and {b $fn} respectively). Where present, they govern the
    following:

    - [?fa] is the minimum angle for a fragment. Note that this should be given
      in radians here (as opposed to degrees in the OpenSCAD language).
      Default is [pi /. 15.] radians (12°).
    - [?fs] is the minimum size/length of a fragment. Even if ?fa is given, and
      very small, this parameter will limit how small the generated fragments
      can be (default = [2.]).
    - [?fn] will set the absolute number of fragments to be used (causing the
      previous two parameters to be ignored if non-zero). *)

(** {1 3d shape primitives} *)

(** [cube ?center dimensions]

    Creates a cube in the first octant, with the given xyz [dimensions]. When
    [center] is true, the cube is centered on the origin. *)
val cube : ?center:bool -> V3.t -> d3

(** [sphere ?fa ?fs ?fn radius]

    Creates a sphere with given [radius] at the origin of the coordinate system. *)
val sphere : ?fa:float -> ?fs:float -> ?fn:int -> float -> d3

(** [cylinder ?center ?fa ?fs ?fn ~height radius]

     Creates a cylinder centered about the z axis. When center is true, it will
     also be centered vertically, otherwise the base will sit upon the XY
     plane. *)
val cylinder
  :  ?center:bool
  -> ?fa:float
  -> ?fs:float
  -> ?fn:int
  -> height:float
  -> float
  -> d3

(** [cone ?center ?fa ?fs ?fn ~height r1 r2 ]

    Creates a cone (using the cylinder primitive) with bottom radius [r1] and
    top radius [r2]. *)
val cone
  :  ?center:bool
  -> ?fa:float
  -> ?fs:float
  -> ?fn:int
  -> height:float
  -> float
  -> float
  -> d3

(** [polyhedron points faces]

    A polyhedron is the most general 3D primitive solid. It can be used to
    create any regular or irregular shape including those with concave as well
    as convex features. Curved surfaces are approximated by a series of flat

    The {!V3.t} list of coordinate [points] represents the vertices of the
    shape. How these points define the surface of the generated shape is
    specified by the [faces] (0-based) index lists. Each element of [faces]
    should define a face in the same order (from the perspective of viewing the
    drawn shape from the outside, OpenSCAD prefers clockwise ordering) face
    using the points at the indices in [points]. These may be defined in any
    order, as long as enough are provided to fully enclose the shape.

    The optional [?convexity] parameter specifies the maximum number of faces a
    ray intersecting the object might penetrate. This parameter is needed only
    for correct display of the object in OpenCSG preview mode. It has no effect
    on the polyhedron rendering. For display problems, setting it to 10 should
    work fine for most cases.

    If you are having trouble, please see the
    {{:https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#Debugging_polyhedra}
    debugging polyhedra} section of the OpenSCAD user manual. *)
val polyhedron : ?convexity:int -> V3.t list -> int list list -> d3

(** An empty 3d non-shape (union of nothing). *)
val empty3 : d3

(** {1 2d shape primitives} *)

(** [square ?center dimensions]

    Creates a square or rectangle in the first quadrant, with given xyz
    [dimensions]. When [?center] is true the square is centered on the
    origin. *)
val square : ?center:bool -> V2.t -> d2

(** [circle ?fa ?fs ?fn radius]

    Creates a circle with given [radius] at the origin. *)
val circle : ?fa:float -> ?fs:float -> ?fn:int -> float -> d2

(** [polygon ?convexity ?paths points]

    Creates a multiple sided shape from a list of xy [points]. If [?paths] is
    not specified, then all points will be used in the order that they appear. A
    single path list specifies the order to traverse the [points] to draw the
    outline of the polygon. Any additional lists of indices will describe
    secondary shapes to be subtracted from the first. In this way, holes can be
    placed in the shape without a subsequent boolean {!difference} operation.

    For information on the [?convexity], please see the documentation for
    {!polyhedron}. *)
val polygon : ?convexity:int -> ?paths:int list list -> V2.t list -> d2

(** [text ?size ?font ?halign ?valign ?spacing ?direction ?language ?script ?fn str]

    Creates 2D geometric text object with contents [str], using a named font
    installed on the local system or provided as a separate font file.
    - [?size] specifies the ascent (height above baseline). Default is 10.
    - [?font] is the name of the font that should be used. This is not the name
      of the font file, but the logical font name (internally handled by the
      fontconfig library).
    - [?halign] and [?valign] set the horizontal and vertical alignments of the text.
      Defaults are [Left] and [Baseline] respectively.
    - [?spacing] gives a factor by which to increase/decrease the character spacing.
      A value of 1.0 would result in normal spacing.
    - [?direction] sets the text flow. Default is [LeftToRight].
    - [?language] sets the language of the text. Default is "en".
    - [?script] sets the script of the text. Default is "latin". *)
val text
  :  ?size:float
  -> ?font:string
  -> ?halign:Text.h_align
  -> ?valign:Text.v_align
  -> ?spacing:float
  -> ?direction:Text.direction
  -> ?language:string
  -> ?script:string
  -> ?fn:int
  -> string
  -> d2

(** An empty 2d non-shape (union of nothing). *)
val empty2 : d2

(** {1 Basic Transformations}

    These functions can be applied to both 2d and 3d shapes. Relevant vector and
    rotational parameters are tied to the dimensionality of the input shape,
    preventing transformations that could result in 2d shapes escaping the xy
    plane. {i e.g.} Translation vectors of 2d shapes are given as {!V2.t}, and
    rotation is given as a single [float] angle about the z-axis. *)

(** [translate p t]

    Moves [t] along the vector [p]. *)
val translate : 's -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [xtrans x t]

    Moves [t] by the distance [x] along the x-axis. *)
val xtrans : float -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [ytrans y t]

    Moves [t] by the distance [y] along the y-axis. *)
val ytrans : float -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [ztrans y t]

    Moves the 3d shape [t] by the distance [z] along the z-axis. *)
val ztrans : float -> d3 -> d3

(** [rotate ?about r t]

    Performs an Euler rotation (zyx) if operating in 3d ([(r : V3.t) (t : d3)]),
    otherwise ([(r : float) (t : d2)]), a single rotation around the z-axis is
    performed. If it is provided, rotations are performed around the point [about],
    otherwise rotation is about the origin. Angle(s) [r] are in radians. *)
val rotate : ?about:'s -> 'r -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [xrot ?about r t]

    Rotate the 3d shape [t] around the x-axis through the origin (or the point
    [about] if provided) by [r] (in radians). *)
val xrot : ?about:V3.t -> float -> d3 -> d3

(** [yrot ?about r t]

    Rotate the 3d shape [t] around the y-axis through the origin (or the point
    [about] if provided) by [r] (in radians). *)
val yrot : ?about:V3.t -> float -> d3 -> d3

(** [zrot ?about r t]

    Rotate the shape [t] (2d or 3d) around the z-axis through the origin (or the
    point [about] if provided) by [r] (in radians). For 2d shapes, this is
    equivalent to {!rotate}. *)
val zrot : ?about:'s -> float -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [affine mat t]

    Transforms the geometry [t] with the given affine transformation matrix
    [mat] ({!Affine2.t} for 2d, {!Affine3.t} for 3d shapes) via the
    {{:https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#multmatrix}
    multmatrix} operation in OpenSCAD. *)
val affine : 'a -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [mirror ax t]

    Mirrors [t] on a plane through the origin, defined by the normal vector
    [ax]. *)
val mirror : 's -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [scale factors t]

    Scales [t] by the given [factors] in xyz. *)
val scale : 's -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [resize dimensions t]

    Adjusts the size of [t] to match the given [dimensions]. *)
val resize : 's -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [color ?alpha color t]

    Displays [t] with the specified [color] and [?alpha] value. This is only
    used for the F5 preview as CGAL and STL (F6, render) do not currently
    support color. Defaults to opaque (alpha = 1.0). *)
val color : ?alpha:float -> Color.t -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [render ?convexity t]

    Forces OpenSCAD to render and cache the mesh produced by the given [t]. This
    can help to speed up previewing {b (F5)} when the cached shape is used many times.
    Note that this does however remove any colouration applied previously with
    {!color}, or resulting from boolean operations such as {!difference}.
    Output rendering {b (F6)} performance is unaffected. *)
val render : ?convexity:int -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** {1 3d Only Transformations}

    Each of these transformations cannot be restricted to the 2-dimensional xy
    plane, thus they are restricted to 3d shapes. *)

(** [axis_rotate ?about ax r t]

    Rotates [t] about the arbitrary axis [ax] through the origin (or the point
    [about] if provided) by the angle [r] (in radians). *)
val axis_rotate : ?about:V3.t -> V3.t -> float -> d3 -> d3

(** [quaternion ?about q t]

    Applys the quaternion rotation [q] around the origin (or the point [about]
    if provided) to [t]. *)
val quaternion : ?about:V3.t -> Quaternion.t -> d3 -> d3

(** {1 2d Only Transformations} *)

(** [offset ?mode d t]

    Generates a new 2D interior or exterior outline shifted a distance [d] from
    the original 2d shape [t]. The [mode] governs how [d] is used to create the
    new corners (default = [`Delta]).
    - [`Delta] will create a new outline whose sides are a fixed distance [d]
      (+ve out, -ve in) from the original outline.
    - [`Chamfer] fixed distance offset by [d] as with delta, but with corners
      chamfered.
    - [`Radius] creates a new outline as if a circle of some radius [d] is
      rotated around the exterior ([d > 0]) or interior ([d < 0]) original
      outline.

    Helpful diagrams of what each of these offset styles and chamfering look
    like can be found
    {{:https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#offset}
    here}. *)
val offset : ?mode:[ `Delta | `Radius | `Chamfer ] -> float -> d2 -> d2

(** {1 Boolean Combination}

    Perform boolean operations between shapes of the same dimension (non-mixing
    of 2d and 3d shapes is enforced by the the GADT {!type:t}. Note that the
    polymorphic versions of {!union}, {!minkowski}, {!hull}, and
    {!intersection}, throw exceptions when the input list is empty. If empty
    list inputs are expected, then use the appropriate [2] or [3]
    variant. *)

(** [union ts]

    Creates the union/sum (logical {b or }) [ts]. Throws an exception if [ts] is
    empty, use {!union2} or {!union3} if you would like empty unions to pass
    silently.

    {b Note: } It is mandatory for all unions, explicit or implicit, that
    external faces to be merged not be coincident. Failure to follow this rule
    results in a design with undefined behavior, and can result in a render
    which is not manifold (with zero volume portions, or portions inside out),
    which typically leads to a warning and sometimes removal of a portion of the
    design from the rendered output. (This can also result in flickering effects
    during the preview.) This requirement is not a bug, but an intrinsic
    property of floating point comparisons and the fundamental inability to
    exactly represent irrational numbers such as those resulting from most
    rotations.

    The solution to this is to use a small value called an epsilon when
    merging adjacent faces to guarantee that they overlap, like so:
   {[
     let scad =
       let eps = 0.01 in
       let p = { x = 1. -. eps; y = 0.; z = 0. } in
       union [ cube { x = 1.; y = 1.; z = 1. }
             ; translate p (cube { x = 2. +. eps; y = 2.; z = 2. })
             ]
   ]} *)
val union : ('s, 'r, 'a) t list -> ('s, 'r, 'a) t

val union2 : d2 list -> d2
val union3 : d3 list -> d3

(** [add a b]

    Union the shapes [a] and [b]. Equivalent to [union [a; b]]. *)
val add : ('s, 'r, 'a) t -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [difference t sub]

    Subracts the shapes of [sub] from [t] (logical {b and not }).

    {b Note: } It is mandatory that surfaces that are to be removed by a
    difference operation have an overlap, and that the negative piece being
    removed extends fully outside of the volume it is removing that surface
    from. Failure to follow this rule can cause preview artifacts and can result
    in non-manifold render warnings or the removal of pieces from the render
    output. See the description above in union for why this is required and an
    example of how to do this by this using a small epsilon value. *)
val difference : ('s, 'r, 'a) t -> ('s, 'r, 'a) t list -> ('s, 'r, 'a) t

(** [sub a b]

    Subtract the shape [b] from [a]. Equivalent to [difference a [b]]. *)
val sub : ('s, 'r, 'a) t -> ('s, 'r, 'a) t -> ('s, 'r, 'a) t

(** [intersection ts]

    Creates an in intersection of [ts]. This keeps the overlapping portion
    (logical {b and }). Only the area which is common or shared by {b all } shapes
    are retained. Throws an exception if [ts] is empty, use {!intersection2}
    or {!intersection3} if you would like empty intersections to pass
    silently. *)
val intersection : ('s, 'r, 'a) t list -> ('s, 'r, 'a) t

val intersection2 : d2 list -> d2
val intersection3 : d3 list -> d3

(** [minkowski ts]

    Displays the minkowski sum of [ts]. Throws an exception if [ts] is empty,
    use {!minkowski2} or {!minkowski3} if you would like empty minkowski
    sums to pass silently. *)
val minkowski : ('s, 'r, 'a) t list -> ('s, 'r, 'a) t

val minkowski2 : d2 list -> d2
val minkowski3 : d3 list -> d3

(** [hull ts]

    Displays the convex hull of [ts]. Throws an exception if [ts] is empty, use
    {!hull2} or {!hull3} if you would like empty hulls to pass silently. *)
val hull : ('s, 'r, 'a) t list -> ('s, 'r, 'a) t

val hull2 : d2 list -> d2
val hull3 : d3 list -> d3

(** {1 3d to 2d} *)

(** [projection ?cut t]

    Project a 3D model [t] to the XY plane, resulting in an infinitely thin 2D
    shape, which can then be extruded back into 3D, or rendered and exported as
    a [.dxf]. If [?cut] is true, only points with z=0 (a slice of [t] where it
    intersects with the XY plane) are considered. When [?cut] is false (the
    default when not specified), then points above and below the XY plane will
    be considered in forming the projection. *)
val projection : ?cut:bool -> d3 -> d2

(** {1 2d to 3d extrusions} *)

(** [extrude ?height ?center ?convexity ?twist ?slices ?scale ?fn t]

    Takes a 2D object [t], and extrudes it upwards from the XY plane to
    [?height]. If [?center] is true, the resulting 3D object is centered around
    the XY plane, rather than resting on top of it.
    - [?twist] rotates the shape by the specified angle as it is extruded
      upwards
    - [?slices] specifies the number of intermediate points along the Z axis of
      the extrusion. By default this increases with the value of [?twist],
      though manual refinement my improve results.
    - [?scale] expands or contracts the shape in X and Y as it is extruded
      upward. Default is (1., 1.), no scaling.
    - [?convexity]: see {!polyhedron} documentation. *)
val extrude
  :  ?height:float
  -> ?center:bool
  -> ?convexity:int
  -> ?twist:int
  -> ?slices:int
  -> ?scale:V2.t
  -> ?fn:int
  -> d2
  -> d3

(** [revolve ?angle ?convexity ?fa ?fs ?fn t]

    Spins a 2D shape [t] around the Z-axis in an arc of [?angle] (default = 2π)
    to form a solid which has rotational symmetry. Since [t] is actually 2D (and
    does not really exist in Z), it is more like it is spun around the Y-axis to
    form the solid, which is then placed so that its axis of rotation lies along
    the Z-axis. For this reason, [t] {b must } lie completely on either the
    right (recommended) or the left side of the Y-axis. Further explanation and
    examples can be found
    {{:https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#Rotate_Extrude}
    here}. *)
val revolve
  :  ?angle:float
  -> ?convexity:int
  -> ?fa:float
  -> ?fs:float
  -> ?fn:int
  -> d2
  -> d3

(** {1 External (non-SCAD) Format Import} *)

(** [import2 ?dxf_layer ?convexity file]

    Imports a [file] for use in the current OpenSCAD model. The file extension
    is used to determine which type. If [file] is a [.dxf], [?dxf_layer] can be
    used to indicate a specific layer for import. Throws exception if the
    extension does not match (case insensitive) one of the following 2D formats:
    - DXF
    - SVG ({i Requires version 2019.05 of OpenSCAD}) *)
val import2 : ?dxf_layer:string -> ?convexity:int -> string -> d2

(** [import3 ?convexity file]

    Imports [file] for use in the current OpenSCAD model. The file extension is
    used to determine which type. Throws exception if the extension does not
    match (case insensitive) one of the following 3D formats:
    - STL ({i both ASCII and Binary})
    - OFF
    - AMF ({i Requires version 2019.05 of OpenSCAD })
    - 3MF ({i Requires version 2019.05 of OpenSCAD }) *)
val import3 : ?convexity:int -> string -> d3

(** [surface ?convexity ?center ?invert file]

    Read {{:https://en.wikipedia.org/wiki/Heightmap} heightmap} information
    from a text (with [.dat] extension) or image ([.png] only) [file] into a 3D
    shape. When [?center] is true the imported surface is centered on the origin,
    otherwise it will be placed in the positive quadrant (like {!square}).

    - [.dat] {b format:} a matrix of numbers (delimited by spaces or tabs) that
      represent the height for a specific point. Rows are mapped to the y-axis,
      columns to the x-axis. Empty lines and those that begin with [#] are ignored.
    - [.png] {b format:} alpha channel information of the image is ignored, and
      the height for each pixel is deterimend by converting the colour value to
      {{:https://en.wikipedia.org/wiki/Grayscale} grayscale} using the linear
      luminance for the sRGB colour space.
      {[let y = 0.2126 *. r +. 0.7152 *. g +. 0.0722 *. b]}
      The greyscale values are scaled to be in the range of 0 to 100. Setting
      [invert] to [true] inverts the translation of colour to height values
      (defaults to [false], and has no effect on text [.dat] files)

    Further explanation and examples can be found
    {{:https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#Surface}
    here}. *)
val surface : ?convexity:int -> ?center:bool -> ?invert:bool -> string -> d3

(** {1 Output} *)

(** [to_string t]

    Convert the scad [t] to a string in the OpenSCAD language. *)
val to_string : ('s, 'r, 'a) t -> string

(** [to_file path t]

    Write the scad [t] to a file at the given [path], as an OpenSCAD script
    (using {!to_string}). *)
val to_file : string -> ('s, 'r, 'a) t -> unit

(** [export path t]

    Export the scad [t] to a file at the given [path], in a format dictated by
    the extension of [path]. If export through OpenSCAD fails, an error
    containing captured Stderr output from OpenSCAD is returned (usually CGAL
    errors). Compatible extensions:
    - {b 2D}: [.dxf], [.svg], [.csg]
    - {b 3D}: [.stl], [.off], [.amf], [.3mf], [.csg], [.wrl] *)
val export : string -> ('s, 'r, 'a) t -> (unit, string) result

(** [snapshot ?render ?colorscheme ?projection ?size ?camera path t]

    Save an image ({b PNG} only at this time) of [size] pixels
    (default = [(500, 500)]) to [path] of the scad [t] using the OpenSCAD
    CLI. By default, the [camera] is positioned automatically to point at the
    centre of the object, and far enough away such for it to all be in frame. See
    {!Export.camera} and its {!Export.gimbal} and {!Export.eye} constructors for
    details on manual control. If export fails, an error containing captured
    Stderr output from OpenSCAD is returned (usually CGAL errors).

    - if [render] is [true], the object will be rendered before the snapshot is
      taken, otherwise preview mode is used (default = [false]).
    - [projection] sets the view style as in the GUI (default = [Perspective])
    - [colorscheme] selects the OpenSCAD colour palette (default = [Cornfield]) *)
val snapshot
  :  ?render:bool
  -> ?colorscheme:Export.colorscheme
  -> ?projection:Export.projection
  -> ?size:int * int
  -> ?camera:Export.camera
  -> string
  -> ('s, 'r, 'a) t
  -> (unit, string) result

(** {1 Infix Operators} *)

(** [t |>> p]

    Infix {!translate} *)
val ( |>> ) : ('s, 'r, 'a) t -> 's -> ('s, 'r, 'a) t

(** [t |@> r]

    Infix {!rotate} *)
val ( |@> ) : ('s, 'r, 'a) t -> 'r -> ('s, 'r, 'a) t
