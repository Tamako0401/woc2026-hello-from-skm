# SPDX-License-Identifier: GPL-2.0

KDIR ?= ./linux
BDIR ?= ./busybox
SUBMODULE_DEPTH ?= 1
TARGET ?=

.PHONY: all run build setup clean

all: run

run: build
	scripts/run.sh 

build: setup
	scripts/build.sh -b $(BDIR) -k $(KDIR) -t "$(TARGET)"

setup:
	SUBMODULE_DEPTH=$(SUBMODULE_DEPTH) scripts/setup.sh
	$(MAKE) -C $(KDIR)/rust M=$$PWD rust-analyzer

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean
