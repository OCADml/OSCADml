open OCADml

type scad =
  | Cylinder of
      { r1 : float
      ; r2 : float
      ; h : float
      ; center : bool
      ; fa : float option
      ; fs : float option
      ; fn : int option
      }
  | Cube of
      { size : V3.t
      ; center : bool
      }
  | Sphere of
      { r : float
      ; fa : float option
      ; fs : float option
      ; fn : int option
      }
  | Square of
      { size : V2.t
      ; center : bool
      }
  | Circle of
      { r : float
      ; fa : float option
      ; fs : float option
      ; fn : int option
      }
  | Polygon of
      { points : V2.t list
      ; paths : int list list option
      ; convexity : int
      }
  | Text of Text0.t
  | Color of
      { scad : scad
      ; color : Color.t
      ; alpha : float option
      }
  | Translate of V3.t * scad
  | Rotate of V3.t * scad
  | AxisRotate of V3.t * float * scad
  | MultMatrix of Affine3.t * scad
  | Union of scad list
  | Intersection of scad list
  | Difference of scad * scad list
  | Minkowski of scad list
  | Hull of scad list
  | Polyhedron of
      { points : V3.t list
      ; faces : int list list
      ; convexity : int
      }
  | Mirror of V3.t * scad
  | Projection of
      { scad : scad
      ; cut : bool
      }
  | LinearExtrude of
      { scad : scad
      ; height : float
      ; center : bool
      ; convexity : int
      ; twist : int option
      ; slices : int
      ; scale : V2.t
      ; fn : int
      }
  | RotateExtrude of
      { scad : scad
      ; angle : float option
      ; convexity : int
      ; fa : float option
      ; fs : float option
      ; fn : int option
      }
  | Scale of V3.t * scad
  | Resize of V3.t * scad
  | Offset of
      { scad : scad
      ; mode : [ `Radius | `Delta | `Chamfer ]
      ; d : float
      }
  | Import of
      { file : string
      ; convexity : int
      ; dxf_layer : string option
      }
  | Surface of
      { file : string
      ; center : bool
      ; invert : bool
      ; convexity : int
      }
  | Render of
      { scad : scad
      ; convexity : int
      }

type ('space, 'rot, 'affine) t =
  | D2 : scad -> (V2.t, float, Affine2.t) t
  | D3 : scad -> (V3.t, V3.t, Affine3.t) t

type d2 = (V2.t, float, Affine2.t) t
type d3 = (V3.t, V3.t, Affine3.t) t

let d2 scad = D2 scad
let d3 scad = D3 scad
let empty2 = D2 (Union [])
let empty3 = D3 (Union [])

let unpack : type s r a. (s, r, a) t -> scad = function
  | D2 scad -> scad
  | D3 scad -> scad

let map : type s r a. (scad -> scad) -> (s, r, a) t -> (s, r, a) t =
 fun f -> function
  | D2 scad -> D2 (f scad)
  | D3 scad -> D3 (f scad)

let cylinder ?(center = false) ?fa ?fs ?fn ~height:h r =
  d3 @@ Cylinder { r1 = r; r2 = r; h; center; fa; fs; fn }

let cone ?(center = false) ?fa ?fs ?fn ~height r1 r2 =
  d3 @@ Cylinder { r1; r2; h = height; center; fa; fs; fn }

let cube ?(center = false) size = d3 @@ Cube { size; center }
let sphere ?fa ?fs ?fn r = d3 @@ Sphere { r; fa; fs; fn }
let square ?(center = false) size = d2 @@ Square { size; center }
let circle ?fa ?fs ?fn r = d2 @@ Circle { r; fa; fs; fn }
let polygon ?(convexity = 10) ?paths points = d2 @@ Polygon { points; paths; convexity }

let text ?size ?font ?halign ?valign ?spacing ?direction ?language ?script ?fn str =
  d2
  @@ Text
       { text = str
       ; size
       ; font
       ; halign
       ; valign
       ; spacing
       ; direction
       ; language
       ; script
       ; fn
       }

let translate (type s r a) (p : s) : (s, r, a) t -> (s, r, a) t = function
  | D2 scad -> d2 @@ Translate (V3.of_v2 p, scad)
  | D3 scad -> d3 @@ Translate (p, scad)

let xtrans (type s r a) x : (s, r, a) t -> (s, r, a) t = function
  | D2 scad -> d2 @@ Translate (v3 x 0. 0., scad)
  | D3 scad -> d3 @@ Translate (v3 x 0. 0., scad)

let ytrans (type s r a) y : (s, r, a) t -> (s, r, a) t = function
  | D2 scad -> d2 @@ Translate (v3 0. y 0., scad)
  | D3 scad -> d3 @@ Translate (v3 0. y 0., scad)

let[@inline] ztrans z t = translate (v3 0. 0. z) t

let rotate : type s r a. ?about:s -> r -> (s, r, a) t -> (s, r, a) t =
 fun ?about r t ->
  let aux : (s, r, a) t -> (s, r, a) t = function
    | D2 scad -> d2 @@ Rotate ({ x = 0.; y = 0.; z = r }, scad)
    | D3 scad -> d3 @@ Rotate (r, scad)
  in
  match about with
  | Some p ->
    let p' : s =
      match t with
      | D2 _ -> V2.neg p
      | D3 _ -> V3.neg p
    in
    translate p' t |> aux |> translate p
  | None   -> aux t

let[@inline] xrot ?about x t = rotate ?about (v3 x 0. 0.) t
let[@inline] yrot ?about y t = rotate ?about (v3 0. y 0.) t

let zrot : type s r a. ?about:s -> float -> (s, r, a) t -> (s, r, a) t =
 fun ?about z t ->
  match t with
  | D2 _ -> rotate ?about z t
  | D3 _ -> rotate ?about (v3 0. 0. z) t

let axis_rotate ?about ax r t =
  let aux (D3 scad) = d3 @@ AxisRotate (ax, r, scad) in
  match about with
  | Some p -> translate (V3.neg p) t |> aux |> translate p
  | None   -> aux t

let affine (type s r a) (m : a) : (s, r, a) t -> (s, r, a) t = function
  | D2 scad -> d2 @@ MultMatrix (Affine2.lift m, scad)
  | D3 scad -> d3 @@ MultMatrix (m, scad)

let quaternion ?about q t =
  let aux (D3 scad) = d3 @@ MultMatrix (Quaternion.to_affine q, scad) in
  match about with
  | Some p -> translate (V3.neg p) t |> aux |> translate p
  | None   -> aux t

let union2 ts = d2 @@ Union (List.map unpack ts)
let union3 ts = d3 @@ Union (List.map unpack ts)

let empty_exn n =
  invalid_arg
    (Printf.sprintf
       "List must be non-empty. Use %s2 or %s3 if empty lists are expected."
       n
       n )

let union : type s r a. (s, r, a) t list -> (s, r, a) t =
 fun ts ->
  match ts with
  | D2 _ :: _ -> union2 ts
  | D3 _ :: _ -> union3 ts
  | []        -> empty_exn "union"

let add a b = union [ a; b ]

let difference (type s r a) (t : (s, r, a) t) (sub : (s, r, a) t list) =
  map (fun scad -> Difference (scad, List.map unpack sub)) t

let sub a b = difference a [ b ]
let intersection2 ts = d2 @@ Intersection (List.map unpack ts)
let intersection3 ts = d3 @@ Intersection (List.map unpack ts)

let intersection : type s r a. (s, r, a) t list -> (s, r, a) t =
 fun ts ->
  match ts with
  | D2 _ :: _ -> intersection2 ts
  | D3 _ :: _ -> intersection3 ts
  | []        -> empty_exn "intersection"

let hull2 ts = d2 @@ Hull (List.map unpack ts)
let hull3 ts = d3 @@ Hull (List.map unpack ts)

let hull : type s r a. (s, r, a) t list -> (s, r, a) t =
 fun ts ->
  match ts with
  | D2 _ :: _ -> hull2 ts
  | D3 _ :: _ -> hull3 ts
  | []        -> empty_exn "hull"

let minkowski2 ts = d2 @@ Minkowski (List.map unpack ts)
let minkowski3 ts = d3 @@ Minkowski (List.map unpack ts)

let minkowski : type s r a. (s, r, a) t list -> (s, r, a) t =
 fun ts ->
  match ts with
  | D2 _ :: _ -> minkowski2 ts
  | D3 _ :: _ -> minkowski3 ts
  | []        -> empty_exn "minkowski"

let polyhedron ?(convexity = 10) points faces =
  d3 @@ Polyhedron { points; faces; convexity }

let mirror (type s r a) (ax : s) : (s, r, a) t -> (s, r, a) t = function
  | D2 scad -> d2 @@ Mirror (V3.of_v2 ax, scad)
  | D3 scad -> d3 @@ Mirror (ax, scad)

let projection ?(cut = false) (D3 scad) = d2 @@ Projection { scad; cut }

let extrude
    ?(height = 10.)
    ?(center = false)
    ?(convexity = 10)
    ?twist
    ?(slices = 20)
    ?(scale = v2 1. 1.)
    ?(fn = 16)
    (D2 scad)
  =
  if height <= 0. then invalid_arg "Extrusion height must be positive.";
  d3 @@ LinearExtrude { scad; height; center; convexity; twist; slices; scale; fn }

let revolve ?angle ?(convexity = 10) ?fa ?fs ?fn (D2 scad) =
  d3 @@ RotateExtrude { scad; angle; convexity; fa; fs; fn }

let scale (type s r a) (factors : s) : (s, r, a) t -> (s, r, a) t = function
  | D2 scad -> d2 @@ Scale (V3.of_v2 factors, scad)
  | D3 scad -> d3 @@ Scale (factors, scad)

let resize (type s r a) (new_dims : s) : (s, r, a) t -> (s, r, a) t = function
  | D2 scad -> d2 @@ Resize (V3.of_v2 new_dims, scad)
  | D3 scad -> d3 @@ Resize (new_dims, scad)

let offset ?(mode = `Delta) d (D2 scad) = d2 @@ Offset { scad; mode; d }
let import ?dxf_layer ?(convexity = 10) file = Import { file; convexity; dxf_layer }
let d2_import_exts = Export.ExtSet.of_list [ ".dxf"; ".svg" ]
let d3_import_exts = Export.ExtSet.of_list [ ".stl"; ".off"; ".amf"; ".3mf" ]

let import2 ?dxf_layer ?convexity file =
  match Export.legal_ext d2_import_exts file with
  | Ok ()     -> d2 @@ import ?dxf_layer ?convexity file
  | Error ext ->
    invalid_arg
      (Printf.sprintf "Input file extension %s is not supported for 2D import." ext)

let import3 ?convexity file =
  match Export.legal_ext d3_import_exts file with
  | Ok ()     -> d3 @@ import ?convexity file
  | Error ext ->
    invalid_arg
      (Printf.sprintf "Input file extension %s is not supported for 3D import." ext)

let surface ?(convexity = 10) ?(center = false) ?(invert = false) file =
  match Filename.extension file with
  | ".dat" | ".png" -> d3 @@ Surface { file; center; invert; convexity }
  | ext             ->
    invalid_arg
    @@ (Printf.sprintf "Input file extension %s is not supported for surface import.") ext

let color ?alpha color = map (fun scad -> Color { scad; color; alpha })
let render ?(convexity = 10) = map (fun scad -> Render { scad; convexity })
let of_path2 ?convexity t = polygon ?convexity t

let of_poly2 ?convexity Poly2.{ outer; holes } =
  match holes with
  | []    -> polygon ?convexity outer
  | holes ->
    let _, points, paths =
      let f (i, points, paths) h =
        let i, points, path =
          let g (i, points, path) p = i + 1, p :: points, i :: path in
          List.fold_left g (i, points, []) h
        in
        i, points, path :: paths
      in
      List.fold_left f (0, [], []) (outer :: holes)
    in
    polygon ?convexity ~paths:(List.rev paths) (List.rev points)

let of_mesh ?convexity Mesh.{ points; faces; _ } = polyhedron ?convexity points faces
let[@inline] of_poly3 ?convexity t = of_mesh ?convexity @@ Mesh.of_poly3 t

let to_string t =
  let buf_add_list b f = function
    | h :: t ->
      let append a =
        Buffer.add_char b ',';
        f b a
      in
      Buffer.add_char b '[';
      f b h;
      List.iter append t;
      Buffer.add_char b ']'
    | []     ->
      let b = Buffer.create 2 in
      Buffer.add_char b '[';
      Buffer.add_char b ']'
  in
  let buf_of_list f l =
    let b = Buffer.create 512 in
    buf_add_list b f l;
    b
  and buf_add_idxs b = buf_add_list b (fun b' i -> Buffer.add_string b' (Int.to_string i))
  and buf_add_vec2 b { x; y } =
    Buffer.add_char b '[';
    Buffer.add_string b (Float.to_string x);
    Buffer.add_char b ',';
    Buffer.add_string b (Float.to_string y);
    Buffer.add_char b ']'
  and buf_add_vec3 b { x; y; z } =
    Buffer.add_char b '[';
    Buffer.add_string b (Float.to_string x);
    Buffer.add_char b ',';
    Buffer.add_string b (Float.to_string y);
    Buffer.add_char b ',';
    Buffer.add_string b (Float.to_string z);
    Buffer.add_char b ']'
  and maybe_fmt fmt opt = Util.value_map_opt (Printf.sprintf fmt) ~default:"" opt
  and string_of_f_ fa fs (fn : int option) =
    let fa_to_string a = Float.to_string @@ Math.deg_of_rad a in
    Printf.sprintf
      ", $fa=%s, $fs=%s, $fn=%i"
      (Util.value_map_opt ~default:"12" fa_to_string fa)
      (Util.value_map_opt ~default:"2" Float.to_string fs)
      (Option.value ~default:0 fn)
  in
  let rec arrange_elms indent scads =
    let buf = Buffer.create 100 in
    List.iter (fun scad -> Buffer.add_string buf (print indent scad)) scads;
    Buffer.contents buf
  and print indent = function
    | Cylinder { r1; r2; h; center; fa; fs; fn } ->
      Printf.sprintf
        "%scylinder(h=%f, r1=%f, r2=%f, center=%B%s);\n"
        indent
        h
        r1
        r2
        center
        (string_of_f_ fa fs fn)
    | Cube { size = { x; y; z }; center } ->
      Printf.sprintf "%scube(size=[%f, %f, %f], center=%B);\n" indent x y z center
    | Sphere { r; fa; fs; fn } ->
      Printf.sprintf "%ssphere(%f%s);\n" indent r (string_of_f_ fa fs fn)
    | Square { size = { x; y }; center } ->
      Printf.sprintf "%ssquare(size=[%f, %f], center=%B);\n" indent x y center
    | Circle { r; fa; fs; fn } ->
      Printf.sprintf "%scircle(%f%s);\n" indent r (string_of_f_ fa fs fn)
    | Polygon { points; paths; convexity } ->
      Printf.sprintf
        "%spolygon(points=%s%s, convexity=%d);\n"
        indent
        (Buffer.contents @@ buf_of_list buf_add_vec2 points)
        ( Option.map (fun ps -> Buffer.contents @@ buf_of_list buf_add_idxs ps) paths
        |> maybe_fmt ", paths=%s" )
        convexity
    | Text { text; size; font; halign; valign; spacing; direction; language; script; fn }
      ->
      Printf.sprintf
        "%stext(\"%s\"%s%s%s%s%s%s%s%s%s);\n"
        indent
        text
        (maybe_fmt ", size=%f" size)
        (maybe_fmt ", font=\"%s\"" font)
        (maybe_fmt ", halign=\"%s\"" @@ Option.map Text0.h_align_to_string halign)
        (maybe_fmt ", valign=\"%s\"" @@ Option.map Text0.v_align_to_string valign)
        (maybe_fmt ", spacing=%f" spacing)
        (maybe_fmt ", direction=\"%s\"" @@ Option.map Text0.direction_to_string direction)
        (maybe_fmt ", language=\"%s\"" language)
        (maybe_fmt ", script=\"%s\"" script)
        (maybe_fmt ", $fn=\"%i\"" fn)
    | Translate (p, scad) ->
      Printf.sprintf
        "%stranslate(%s)\n%s"
        indent
        (V3.to_string p)
        (print (Printf.sprintf "%s\t" indent) scad)
    | Rotate (r, scad) ->
      Printf.sprintf
        "%srotate(%s)\n%s"
        indent
        (V3.to_string @@ V3.deg_of_rad r)
        (print (Printf.sprintf "%s\t" indent) scad)
    | AxisRotate (axis, r, scad) ->
      Printf.sprintf
        "%srotate(a=%f, v=%s)\n%s"
        indent
        (Math.deg_of_rad r)
        (V3.to_string axis)
        (print (Printf.sprintf "%s\t" indent) scad)
    | MultMatrix (mat, scad) ->
      Printf.sprintf
        "%smultmatrix(%s)\n%s"
        indent
        (Affine3.to_string mat)
        (print (Printf.sprintf "%s\t" indent) scad)
    | Union elements ->
      Printf.sprintf
        "%sunion(){\n%s%s}\n"
        indent
        (arrange_elms (Printf.sprintf "%s\t" indent) elements)
        indent
    | Intersection elements ->
      Printf.sprintf
        "%sintersection(){\n%s%s}\n"
        indent
        (arrange_elms (Printf.sprintf "%s\t" indent) elements)
        indent
    | Difference (minuend, subtrahend) ->
      Printf.sprintf
        "%sdifference(){\n%s%s%s}\n"
        indent
        (print (Printf.sprintf "%s\t" indent) minuend)
        (arrange_elms (Printf.sprintf "%s\t" indent) subtrahend)
        indent
    | Minkowski elements ->
      Printf.sprintf
        "%sminkowski(){\n%s%s}\n"
        indent
        (arrange_elms (Printf.sprintf "%s\t" indent) elements)
        indent
    | Hull elements ->
      Printf.sprintf
        "%shull(){\n%s%s}\n"
        indent
        (arrange_elms (Printf.sprintf "%s\t" indent) elements)
        indent
    | Polyhedron { points; faces; convexity } ->
      Printf.sprintf
        "%spolyhedron(points=%s, faces=%s, convexity=%i);\n"
        indent
        (Buffer.contents @@ buf_of_list buf_add_vec3 points)
        (Buffer.contents @@ buf_of_list buf_add_idxs faces)
        convexity
    | Mirror ({ x; y; z }, scad) ->
      Printf.sprintf
        "%smirror(v=[%f, %f, %f])\n%s"
        indent
        x
        y
        z
        (print (Printf.sprintf "%s\t" indent) scad)
    | Projection { scad; cut } ->
      Printf.sprintf
        "%sprojection(cut=%B){\n%s%s}\n"
        indent
        cut
        (print (Printf.sprintf "%s\t" indent) scad)
        indent
    | LinearExtrude
        { scad; height; center; convexity; twist; slices; scale = { x; y }; fn } ->
      Printf.sprintf
        "%slinear_extrude(height=%f, center=%B, convexity=%d, %sslices=%d, scale=[%f, \
         %f], $fn=%d)\n\
         %s"
        indent
        height
        center
        convexity
        (maybe_fmt "twist=%d, " twist)
        slices
        x
        y
        fn
        (print (Printf.sprintf "%s\t" indent) scad)
    | RotateExtrude { scad; angle; convexity; fa; fs; fn } ->
      Printf.sprintf
        "%srotate_extrude(%sconvexity=%d%s)\n%s"
        indent
        (maybe_fmt "angle=%f," @@ Option.map Math.deg_of_rad angle)
        convexity
        (string_of_f_ fa fs fn)
        (print (Printf.sprintf "%s\t" indent) scad)
    | Scale (p, scad) ->
      Printf.sprintf
        "%sscale(%s)\n%s"
        indent
        (V3.to_string p)
        (print (Printf.sprintf "%s\t" indent) scad)
    | Resize (p, scad) ->
      Printf.sprintf
        "%sresize(%s)\n%s"
        indent
        (V3.to_string p)
        (print (Printf.sprintf "%s\t" indent) scad)
    | Offset { scad; mode; d } ->
      Printf.sprintf
        "%soffset(%s)\n%s"
        indent
        ( match mode with
        | `Radius  -> Printf.sprintf "r = %f" d
        | `Delta   -> Printf.sprintf "delta = %f" d
        | `Chamfer -> Printf.sprintf "delta = %f, chamfer=true" d )
        (print (Printf.sprintf "%s\t" indent) scad)
    | Import { file; convexity; dxf_layer } ->
      Printf.sprintf
        "%simport(\"%s\", convexity=%i%s);\n"
        indent
        file
        convexity
        (maybe_fmt ", layer=%s" dxf_layer)
    | Surface { file; center; invert; convexity } ->
      Printf.sprintf
        "%ssurface(\"%s\", center=%B, invert=%B, convexity=%i);\n"
        indent
        file
        center
        invert
        convexity
    | Color { scad; color; alpha } ->
      Printf.sprintf
        "%scolor(%s%s)\n%s"
        indent
        (Color.to_string color)
        (maybe_fmt ", alpha=%f" alpha)
        (print (Printf.sprintf "%s\t" indent) scad)
    | Render { scad; convexity } ->
      Printf.sprintf
        "%srender(convexity=%i)\n%s"
        indent
        convexity
        (print (Printf.sprintf "%s\t" indent) scad)
  in
  print "" (unpack t)

let to_file path t =
  let oc = open_out path in
  Printf.fprintf oc "%s" (to_string t);
  close_out oc

let export (type s r a) path (t : (s, r, a) t) =
  let space, allowed =
    match t with
    | D2 _ -> "2D", Export.d2_exts
    | D3 _ -> "3D", Export.d3_exts
  in
  match Export.legal_ext allowed path with
  | Ok ()     ->
    let temp = Filename.temp_file "scad_export_" ".scad" in
    to_file temp t;
    Export.script path temp
  | Error ext ->
    invalid_arg (Printf.sprintf "%s files are not supported for %s export." ext space)

let snapshot ?render ?colorscheme ?projection ?size ?camera out_path t =
  let temp = Filename.temp_file "out" ".scad" in
  to_file temp t;
  Export.snapshot ?render ?colorscheme ?projection ?size ?camera out_path temp

let ( |>> ) t p = translate p t
let ( |@> ) t r = rotate r t
