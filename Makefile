DXF_SOURCES = $(wildcard _build/default/test/e2e/dxf/*.scad)
DXF_TARGETS = $(patsubst %.scad,%.dxf,$(DXF_SOURCES))
STL_SOURCES = $(wildcard _build/default/test/e2e/stl/*.scad)
STL_TARGETS = $(patsubst %.scad,%.stl,$(STL_SOURCES))

.PHONY: all
all:
	dune build @all

.PHONY: build
build:
	dune build

.PHONY: test-ocaml
test-ocaml:
	dune runtest

.PHONY: test-e2e
test-e2e: $(DXF_TARGETS) $(STL_TARGETS)
%.dxf: %.scad
	openscad $< -o $@
%.stl: %.scad
	openscad $< -o $@

.PHONY: test
test: test-ocaml test-e2e

.PHONY: clean
clean:
	dune clean

.PHONY: fmt
fmt:
	dune build @fmt --auto-promote
