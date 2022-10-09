(lang dune 3.3)

(using directory-targets 0.1)

(cram enable)

(name OSCADml)

(generate_opam_files true)

(source
 (github OCADml/OSCADml))

(documentation https://ocadml.github.io/OSCADml)

(license BSL-1.0)

(authors
 "Geoff deRosenroll<geoffderosenroll@gmail.com"
 "Masaki Nakano<namachan10777@gmail.com>")

(maintainers "Geoff deRosenroll<geoffderosenroll@gmail.com")

(package
 (name OSCADml)
 (synopsis "OCaml DSL for 3D solid modelling in OpenSCAD")
 (description
  "OSCADml is an OCaml front-end to the OpenSCAD CAD programming language.")
 (depends
  (ocaml
   (>= 4.08.0))
  (cairo2
   (>= 0.6.2))))
