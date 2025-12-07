.PHONY: all filenames images pdfs pdfs-flattened clean

MDS = $(shell fd -I -t f '.*\.md')
PDFS := $(patsubst %.md,pdfs/%.pdf,$(MDS))
PDFS_FLATTENED := $(patsubst %.md,pdfs-flattened/%.pdf,$(MDS))

all: filenames images
	$(MAKE) pdfs
	$(MAKE) pdfs-flattened

filenames: 
	python _filenames.py

images:
	python _images.py

pdfs: 
	$(MAKE) -j12 $(PDFS)

pdfs/%.pdf : %.md
	@mkdir -p "$(@D)"
	./_typst.sh $< $@

pdfs-flattened:
	$(MAKE) -j12 $(PDFS_FLATTENED)

pdfs-flattened/%.pdf: %.md
	@mkdir -p "$(@D)" .temp
	@tmpfile=$$(mktemp -p .temp); \
	trap 'rm -f "$$tmpfile"' EXIT; \
	recipemd --flatten "$<" > "$$tmpfile"; \
	./_typst.sh "$$tmpfile" "$@" "$<" true

clean:
	$(RM) -r pdfs pdfs-flattened
