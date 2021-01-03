.PHONY: all filenames images clean

MDS = $(shell fd -t f '.*\.md')
PDFS := $(patsubst %.md,pdfs/%.pdf,$(MDS))

all: filenames images
	$(MAKE) -j12 $(PDFS)

filenames: 
	python _filenames.py

images:
	python _images.py

pdfs/%.pdf : %.md
	@mkdir -p "$(@D)"
	pandoc --pdf-engine=xelatex -V geometry:margin=1cm -V geometry:a4paper $< -o $@

clean:
	$(RM) -r pdfs