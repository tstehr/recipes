.PHONY: all filenames images pdfs clean

MDS = $(shell fd -I -t f '.*\.md')
PDFS := $(patsubst %.md,pdfs/%.pdf,$(MDS))

all: filenames images pdfs

filenames: 
	python _filenames.py

images:
	python _images.py

pdfs: 
	$(MAKE) -j12 $(PDFS)

pdfs/%.pdf : %.md
	@mkdir -p "$(@D)"
	./_typst.sh $< $@

clean:
	$(RM) -r pdfs
