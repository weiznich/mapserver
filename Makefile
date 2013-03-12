
all:
	ghc ext/parse_map.hs -O2 -fexcess-precision -optc-O3 -optc-ffast-math -fforce-recomp -o parse_map

clean:
	rm ext/*.hi ext/*.o parse_map

