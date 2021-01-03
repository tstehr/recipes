.PHONY: all filenames images clean

PDFS := $(patsubst %.md,pdfs/%.pdf,$(wildcard *.md))

all: filenames images pdfs
	$(MAKE) -j12 $(PDFS)

filenames: 
	python _filenames.py

images:
	python _images.py

pdfs: 
	mkdir pdfs

pdfs/%.pdf : %.md
	pandoc --pdf-engine=xelatex -V geometry:margin=1cm -V geometry:a4paper $< -o $@

clean:
	$(RM) -r pdfs