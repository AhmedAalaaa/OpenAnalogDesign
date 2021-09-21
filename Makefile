###########################################################################################
# Makefile to control the Analog Design Environment
###########################################################################################
pdk_link = https://github.com/mabrains/open_pdks.git

OPENAnalog_DIR ?= $(shell pwd)
PDK_ROOT       ?= $(shell pwd)/pdks

CURRENT_TAG    ?= "v0.1"
IMAGE_NAME     ?= mabrains/open-analog-design:$(CURRENT_TAG)

DOCKER_UID_OPTIONS = $(shell python3 ./scripts/get_docker_config.py)
DOCKER_OPTIONS ?= --env=DISPLAY --volume=/tmp/.X11-unix:/tmp/.X11-unix --net=host $(DOCKER_UID_OPTIONS)

.DEFAULT_GOAL := all

.PHONY: all
all: open_Analog pdk

######################################################################## OPEN_PDKS ##################################################################################

$(PDK_ROOT)/open_pdks:
	@git clone $(pdk_link) $(PDK_ROOT)/open_pdks

$(PDK_ROOT)/:
	@mkdir -p $(PDK_ROOT)

.PHONY: pdk
pdk: open_pdks

.PHONY: open_pdks
open_pdks: $(PDK_ROOT)/ $(PDK_ROOT)/open_pdks
	cd $(PDK_ROOT)/open_pdks/ && ./configure prefix=`readlink -f ..` --enable-sky130-pdk
	cd $(PDK_ROOT)/open_pdks/ && make 
	cd $(PDK_ROOT)/open_pdks/ && make install

#####################################################################33### OPEN_ANALOG_DESIN ######################################################################

.PHONY: open_Analog
open_Analog:
	docker pull $(IMAGE_NAME)

.PHONY: mount
mount:
	cd $(OPENAnalog_DIR) && \
	docker run -it --rm --name OpenAnlaog_container -v $(OPENAnalog_DIR):/foundry -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) $(DOCKER_OPTIONS) $(IMAGE_NAME)
