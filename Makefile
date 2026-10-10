# make sync      copy core/ into the Quarto extension, the Typst package and the R package
# make check     fail if the copies are out of date (what CI runs)
# make gallery   build every example into gallery/ (needs xelatex, typst, quarto, R)
# make install   link the LaTeX class and Typst package into your local TeX/Typst paths
.PHONY: sync check gallery install
sync:
	./scripts/sync.sh
check: sync
	git diff --exit-code -- _extensions typst r/inst
gallery: sync
	./scripts/gallery.sh
install:
	./install.sh
