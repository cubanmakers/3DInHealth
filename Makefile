.DEFAULT_GOAL := help
.PHONY: cubantech_fuenlabrada cubantech_fuenlabrada_headmount cubantech_fuenlabrada_visor help

cubantech_fuenlabrada: cubantech_fuenlabrada_headmount cubantech_fuenlabrada_visor ## INSST-certified visor with Franklin mechanism

visor/cubantech_fuenlabrada/files/DIADEMA.stl: visor/cubantech_fuenlabrada/scripts/build.scad
	openscad -D 'part="headmount"' -o visor/cubantech_fuenlabrada/files/DIADEMA.stl visor/cubantech_fuenlabrada/scripts/build.scad
	admesh -b visor/cubantech_fuenlabrada/files/DIADEMA.stl visor/cubantech_fuenlabrada/files/DIADEMA.stl

visor/cubantech_fuenlabrada/files/PORTAPANTALLA.stl: visor/cubantech_fuenlabrada/scripts/build.scad
	openscad -D 'part="visor"' -o visor/cubantech_fuenlabrada/files/PORTAPANTALLA.stl visor/cubantech_fuenlabrada/scripts/build.scad
	admesh -b visor/cubantech_fuenlabrada/files/PORTAPANTALLA.stl visor/cubantech_fuenlabrada/files/PORTAPANTALLA.stl

cubantech_fuenlabrada_headmount: visor/cubantech_fuenlabrada/files/DIADEMA.stl ## Head support part of INSST-certified visor with Franklin mechanism

cubantech_fuenlabrada_visor: visor/cubantech_fuenlabrada/files/PORTAPANTALLA.stl ## Transparent film support part of INSST-certified visor with Franklin mechanism

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
