all: help

.PHONY : help
help : Makefile
	@sed -n 's/^##\s//p' $<

DOCKER_PIPELINE_NAME="docker_cut"
PIPELINE_CONTAINER_NAME="docker_cut"
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
GPU_PIPELINE_DF_PATH := $(ROOT_DIR)/Dockerfile
GPU_ID="${GPU_ID:-0}"

## Build docker image
build:
	@DOCKER_BUILDKIT=1 docker build -t ${DOCKER_PIPELINE_NAME} -f ${GPU_PIPELINE_DF_PATH} .

## Run bash terminal
bash:
	@if [ -z "${DATA_DIR}" ]; then \
		echo "DATA_DIR not found. Please set environment variable or pass as argument"; \
	elif [ -z "${OUT_DIR}" ]; then \
		echo "OUT_DIR not found. Please set environment variable or pass as argument"; \
	else \
		make build; \
		docker run --name ${PIPELINE_CONTAINER_NAME} --network=host --shm-size 8G \
		--gpus all -e NVIDIA_DRIVER_CAPABILITIES=all \
		-v ${ROOT_DIR}:/home/docker_cut \
		-v ${DATA_DIR}:/dataset \
		-v ${OUT_DIR}:/output \
		-it ${DOCKER_PIPELINE_NAME} bash; \
		make rm; \
	fi	
# GPU constraints (from Sergio's script)
# @docker run --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=${GPU_ID} \
# --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 \

## Remove container
rm:
	@docker rm ${PIPELINE_CONTAINER_NAME}

## Remove image
clean:
	@docker image rm ${DOCKER_PIPELINE_NAME}

