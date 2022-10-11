open OCADml

let openscad = if Sys.unix then "openscad" else "openscad.com"
let sz = 8192
let bytes = Bytes.create sz

module ExtMap = Map.Make (String)

type ext2 =
  [ `Csg
  | `Dxf
  | `Svg
  ]

type ext3 =
  [ `Amf
  | `Csg
  | `Off
  | `Stl
  | `Wrl
  | `_3mf
  ]

let d2_exts = ExtMap.of_seq @@ List.to_seq [ ".dxf", `Dxf; ".svg", `Svg; ".csg", `Csg ]

let d3_exts =
  ExtMap.of_seq
  @@ List.to_seq
       [ ".stl", `Stl
       ; ".off", `Off
       ; ".amf", `Amf
       ; ".3mf", `_3mf
       ; ".csg", `Csg
       ; ".wrl", `Wrl
       ]

let legal_ext (allowed : [> ext2 | ext3 ] ExtMap.t) file =
  let ext = String.uncapitalize_ascii @@ Filename.extension file in
  match ExtMap.find_opt ext allowed with
  | Some ext -> Ok ext
  | None -> Error ext

let file_to_string path =
  let fd = Unix.openfile path [ O_RDONLY ] 0o777
  and b = Buffer.create sz in
  let rec loop () =
    match Unix.read fd bytes 0 sz with
    | 0 -> ()
    | r when r = sz ->
      Buffer.add_bytes b bytes;
      loop ()
    | r ->
      Buffer.add_bytes b (Bytes.sub bytes 0 r);
      loop ()
  in
  loop ();
  Unix.close fd;
  Buffer.contents b

let script out_path scad_path =
  let format =
    match Filename.extension out_path with
    | ".stl" -> "binstl"
    | ext when not ExtMap.(mem ext d2_exts || mem ext d3_exts) ->
      invalid_arg (Printf.sprintf "Unsupported export file exension: %s" ext)
    | ext -> String.sub ext 1 (String.length ext - 1)
  and err_name = Filename.temp_file "OSCADml_" "_err" in
  let err = Unix.openfile err_name [ O_WRONLY; O_CREAT; O_TRUNC ] 0o777 in
  let pid =
    Unix.create_process
      openscad
      [| openscad; "-q"; "-o"; out_path; "--export-format"; format; scad_path |]
      Unix.stdin
      Unix.stdout
      err
  in
  ignore @@ Unix.waitpid [] pid;
  Unix.close err;
  let e = file_to_string err_name in
  Sys.remove err_name;
  if String.length e > 0 then Error e else Ok ()

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

type view =
  | Axes
  | Crosshairs
  | Edges
  | Scales
  | Wireframe

type projection =
  | Perspective
  | Orthogonal

type camera =
  | Auto
  | Gimbal of
      { translation : V3.t
      ; rotation : V3.t
      ; distance : [ `Auto | `D of float ]
      }
  | Eye of
      { lens : V3.t
      ; center : V3.t
      ; view_all : bool
      }

let auto = Auto

let gimbal ?(translation = V3.zero) ?(rotation = V3.zero) distance =
  Gimbal { translation; rotation; distance }

let eye ?(view_all = false) ?(center = V3.zero) lens = Eye { lens; center; view_all }

let camera_to_args = function
  | Auto -> [| "--autocenter" |]
  | Gimbal { translation = t; rotation = r; distance = `D d } ->
    let r = V3.deg_of_rad r in
    [| "--camera"; Printf.sprintf "%f,%f,%f,%f,%f,%f,%f" t.x t.y t.z r.x r.y r.z d |]
  | Gimbal { translation = t; rotation = r; distance = `Auto } ->
    let r = V3.deg_of_rad r in
    [| "--camera"
     ; Printf.sprintf "%f,%f,%f,%f,%f,%f,%f" t.x t.y t.z r.x r.y r.z 0.
     ; "--viewall"
    |]
  | Eye { lens = l; center = c; view_all = false } ->
    [| "--camera"; Printf.sprintf "%f,%f,%f,%f,%f,%f" l.x l.y l.z c.x c.y c.z |]
  | Eye { lens = l; center = c; view_all = true } ->
    [| "--camera"
     ; Printf.sprintf "%f,%f,%f,%f,%f,%f" l.x l.y l.z c.x c.y c.z
     ; "--viewall"
    |]

let colorscheme_to_string = function
  | Cornfield -> "Cornfield"
  | Metallic -> "Metallic"
  | Sunset -> "Sunset"
  | Starnight -> "Starnight"
  | BeforeDawn -> "BeforeDawn"
  | Nature -> "Nature"
  | DeepOcean -> "DeepOcean"
  | Solarized -> "Solarized"
  | Tomorrow -> "Tomorrow"
  | TomorrowNight -> "Tomorrow Night"
  | Monotone -> "Monotone"

let view_to_string = function
  | Axes -> "axes"
  | Crosshairs -> "crosshairs"
  | Edges -> "edges"
  | Scales -> "scales"
  | Wireframe -> "wireframe"

let view_list_to_args = function
  | [] -> [||]
  | hd :: tl ->
    let f acc a = Printf.sprintf "%s,%s" acc (view_to_string a) in
    [| "--view"; List.fold_left f (view_to_string hd) tl |]

let projection_to_string = function
  | Perspective -> "perspective"
  | Orthogonal -> "orthogonal"

let snapshot
    ?(render = false)
    ?(colorscheme = Cornfield)
    ?(view = [])
    ?(projection = Perspective)
    ?size:(sz_x, sz_y = 500, 500)
    ?(camera = Auto)
    out_path
    scad_path
  =
  let err_name = Filename.temp_file "OSCADml_" "_err" in
  let err = Unix.openfile err_name [ O_WRONLY; O_CREAT; O_TRUNC ] 0o777 in
  let args =
    let base =
      [| openscad
       ; "-q"
       ; "-o"
       ; out_path
       ; "--export-format"
       ; "png"
       ; "--colorscheme"
       ; colorscheme_to_string colorscheme
       ; "--projection"
       ; projection_to_string projection
       ; "--imgsize"
       ; Printf.sprintf "%i,%i" sz_x sz_y
       ; scad_path
      |]
    and render = if render then [| "--render" |] else [||] in
    Array.concat [ base; render; view_list_to_args view; camera_to_args camera ]
  in
  let pid = Unix.create_process openscad args Unix.stdin Unix.stdout err in
  ignore @@ Unix.waitpid [] pid;
  Unix.close err;
  let e = file_to_string err_name in
  Sys.remove err_name;
  if String.length e > 0 then Error e else Ok ()
