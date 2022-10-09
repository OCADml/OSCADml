(** {!Scad.color} specification type

   A selection of hardcoded colours are available, along with aribtrary colours
   by way of with the [RGB of float * float * float] and [Hex of string]
   constructors.

   - As in OpenSCAD, [RGB (r, g, b)] values are given as floats in the range of
     [0.] to [1.], rather than the more traditional integers.
   - [Hex v] values can be given in four formats: ["#rgb"], ["#rgba"],
     ["#rgba"], and ["#rrggbbaa"]. If alpha is given both in the hex value, and
     in the [?alpha] parameter to {!Scad.color}, the parameter will take
     precedence. *)

type t =
  | RGB of float * float * float
  | Hex of string
  | Lavender
  | Thistle
  | Plum
  | Violet
  | Orchid
  | Fuchsia
  | Magenta
  | MediumOrchid
  | MediumPurple
  | BlueViolet
  | DarkViolet
  | DarkOrchid
  | DarkMagenta
  | Purple
  | Indigo
  | DarkSlateBlue
  | SlateBlue
  | MediumSlateBlue
  | Pink
  | LightPink
  | HotPink
  | DeepPink
  | MediumVioletRed
  | PaleVioletRed
  | Aqua
  | Cyan
  | LightCyan
  | PaleTurquoise
  | Aquamarine
  | Turquoise
  | MediumTurquoise
  | DarkTurquoise
  | CadetBlue
  | SteelBlue
  | LightSteelBlue
  | PowderBlue
  | LightBlue
  | SkyBlue
  | LightSkyBlue
  | DeepSkyBlue
  | DodgerBlue
  | CornflowerBlue
  | RoyalBlue
  | Blue
  | MediumBlue
  | DarkBlue
  | Navy
  | MidnightBlue
  | IndianRed
  | LightCoral
  | Salmon
  | DarkSalmon
  | LightSalmon
  | Red
  | Crimson
  | FireBrick
  | DarkRed
  | GreenYellow
  | Chartreuse
  | LawnGreen
  | Lime
  | LimeGreen
  | PaleGreen
  | LightGreen
  | MediumSpringGreen
  | SpringGreen
  | MediumSeaGreen
  | SeaGreen
  | ForestGreen
  | Green
  | DarkGreen
  | YellowGreen
  | OliveDrab
  | Olive
  | DarkOliveGreen
  | MediumAquamarine
  | DarkSeaGreen
  | LightSeaGreen
  | DarkCyan
  | Teal
  | Coral
  | Tomato
  | OrangeRed
  | DarkOrange
  | Orange
  | Gold
  | Yellow
  | LightYellow
  | LemonChiffon
  | LightGoldenrodYellow
  | PapayaWhip
  | Moccasin
  | PeachPuff
  | PaleGoldenrod
  | Khaki
  | DarkKhaki
  | Cornsilk
  | BlanchedAlmond
  | Bisque
  | NavajoWhite
  | Wheat
  | BurlyWood
  | Tan
  | RosyBrown
  | SandyBrown
  | Goldenrod
  | DarkGoldenrod
  | Peru
  | Chocolate
  | SaddleBrown
  | Sienna
  | Brown
  | Maroon
  | White
  | Snow
  | Honeydew
  | MintCream
  | Azure
  | AliceBlue
  | GhostWhite
  | WhiteSmoke
  | Seashell
  | Beige
  | OldLace
  | FloralWhite
  | Ivory
  | AntiqueWhite
  | Linen
  | LavenderBlush
  | MistyRose
  | Gainsboro
  | LightGrey
  | Silver
  | DarkGray
  | Gray
  | DimGray
  | LightSlateGray
  | SlateGray
  | DarkSlateGray
  | Black

val to_string : t -> string
