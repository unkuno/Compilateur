DOCS = Conception.pdf Validation.pdf Charte.pdf Manuel-Utilisateur.pdf Bilan.pdf Man-Decac.pdf Man-Decac.txt Man-Lanceur.pdf Man-Lanceur.txt

.PHONY: all $(DOCS) clean

all: $(DOCS)
	cp $^ ../

Bilan.pdf: Bilan.tex 
	pdflatex Bilan.tex

Charte.pdf: Charte.tex 
	pdflatex Charte.tex

Conception.pdf: Conception.tex Conception_A.tex Conception_B.tex Conception_C.tex
	pdflatex Conception.tex

Manuel-Utilisateur.pdf: Manuel-Utilisateur.tex Man-Decac.pdf 
	pdflatex Manuel-Utilisateur.tex

Validation.pdf: Validation.tex Man-Lanceur.pdf
	pdflatex Validation.tex

Man-Decac.pdf: Man-Decac.ps
	ps2pdf $<

Man-Decac.ps: Man-Decac.1
	groff -k -K UTF-8 -T ps -man $< > $@

Man-Decac.txt: Man-Decac.1
	groff -k -K UTF-8 -T utf8 -man $< > $@

Man-Lanceur.pdf: Man-Lanceur.ps
	ps2pdf $<

Man-Lanceur.ps: Man-Lanceur.1
	groff -k -K UTF-8 -T ps -man $< > $@

Man-Lanceur.txt: Man-Lanceur.1
	groff -k -K UTF-8 -T utf8 -man $< > $@

%.pdf: %.tex
	pdflatex $<

clean:
	rm -f *.aux *.log *.pdf
