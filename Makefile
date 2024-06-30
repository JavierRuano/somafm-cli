.DEFAULT_GOAL := stub
#### Installation directories 
bindir ?= ./build/bin
logdir ?= ./build/var/log

uname := $(shell uname -s)
coreutils := $(shell brew list coreutils 2>/dev/null)

clean: | uninstall

install: | stub
	@rsync -a src/ ${bindir}/


ifeq (${uname}, Darwin)	
ifndef coreutils
	$(error The 'coreutils' package is required for this operation. https://www.gnu.org/software/coreutils/. \
                 Please install it. brew install coretutils));
endif
	@$(eval _bindir := $(shell greadlink -f ${bindir}))
	@$(eval _logdir := $(shell greadlink -f ${logdir}))
	@sed -i ''  "s|bindir=|bindir=${_bindir}|g" ${bindir}/somafm
	@sed -i ''  "s|logdir=|logdir=${_logdir}|g" ${bindir}/somafm
else ifeq (${uname}, Linux)
	@$(eval _bindir := $(shell readlink -f ${bindir}))
	@$(eval _logdir := $(shell readlink -f ${logdir}))
	@sed -i "s|bindir=|bindir=${_bindir}|g" ${bindir}/somafm
	@sed -i "s|logdir=|logdir=${_logdir}|g" ${bindir}/somafm
endif

stub:
	@mkdir -p ${bindir}
	@mkdir -p ${logdir}

test: | test-unit test-integration

test-integration: | install
	@bats test/integration

test-unit: | install
	@bats test/unit

uninstall:
	@if test -f ${bindir}/somafm; then rm ${bindir}/somafm; fi
	@if test -f ${logdir}/somafm.bats.logs; then rm ${logdir}/somafm.bats.logs; fi
	@if [ "$(ls -A $bindir)" ]; then rm -rf ${bindir}; fi
	@if [ "$(ls -A $logdir)" ]; then rm -rf ${logdir}; fi

.PHONY: clean install stub test test-integration test-unit uninstall
