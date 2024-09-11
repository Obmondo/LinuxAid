##################################################################################
# Makefile - Configuration file for GNU make (http://www.gnu.org/software/make/)
# Time-stamp: <Tue 2019-01-29 21:55 svarrette>
#
# Copyright (c) 2018 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#
############################## Variables Declarations ############################

CURDIR = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

MODULES_DIR   = modules
MANIFESTS_DIR = manifests
HIERADATA_DIR = hieradata

MODULES = $(sort $(dir $(wildcard $(MODULES_DIR)/*/)))

# all: setup

# .PHONY: setup
# setup:
# 	r10k puppetfile install -v
# 	$(MAKE) check

# check:
# 	puppet module --modulepath $(CURDIR)/modules --color true list --tree

print:
	@echo "MODULES = $(MODULES)"

clean:
	@if [ -f "$(HIERADATA_DIR)/custom.yaml" ]; then \
		echo "=> remove custom hiera"; \
		rm -f $(HIERADATA_DIR)/custom.yaml;\
	fi

distclean: clean
	@if [ -n "$(MODULES)" ]; then \
		echo "=> remove puppet modules"; \
		echo "(simulating) rm -rf $(MODULES)";\
	fi
