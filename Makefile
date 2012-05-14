PDF=pdflatex
BIB=bibtex
OPEN=open

NAME=paper
ALL=open

all: $(ALL)

build: clean
	$(PDF) $(NAME).tex
	$(PDF) $(NAME).tex
	$(BIB) $(NAME)
	$(PDF) $(NAME).tex
	$(BIB) $(NAME)
	$(PDF) $(NAME).tex
	$(PDF) $(NAME).tex

open: build
	$(OPEN) $(NAME).pdf

clean:
	@rm -f *.aux *.bbl *.blg *.dvi *.log *.lof *.toc *.lot

clobber: clean
	@rm -f $(NAME).pdf
