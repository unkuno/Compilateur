all:

gcov: cleanexec

%::
	cd Outils/Src  && $(MAKE) $@
	cd Syntaxe/Src && $(MAKE) $@
	cd Verif/Src   && $(MAKE) $@
	cd Gencode/Src && $(MAKE) $@
	cd Decac/Src   && $(MAKE) $@

realclean: gcovclean
	cd Decac/Src && $(MAKE) realclean

clean:
	cd Decac/Src && $(MAKE) clean

gcovreport:
	cd Outils/Src  && for f in *.adb; do gcov "$$f"; done
	cd Syntaxe/Src && for f in *.adb; do gcov "$$f"; done
	cd Verif/Src   && for f in *.adb; do gcov "$$f"; done
	cd Gencode/Src && for f in *.adb; do gcov "$$f"; done
	cd Decac/Src   && for f in *.adb; do gcov "$$f"; done
# gcov *.adb est censé faire la même chose, mais il semble que la
# boucle for explicite marche sur des cas où "gcov *.adb" renvoie 0
# lignes de code couvertes ! Sans doute un bug de gcov ...
