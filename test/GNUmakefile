#
# aconfmgr test suite
#
# Main targets:
# - check - run all checks
# - coverage - create coverage report in tmp/coverage/index.html
# - clean - delete temporary/intermediate files
#
# Other targets:
# - shellcheck - lint source code only
# - testsuite - run test suite only
#
# Options:
# - BUILD_BASH=1 - build/use bash and coreutils from source
#                  (useful for testing on old / non-Arch systems)
#

# Common macros

SRC=../aconfmgr $(wildcard ../src/*.bash)
TMP=tmp

# Entry point targets

check : shellcheck testsuite
ci : check coverage

# Create temporary directory

$(TMP) :
	mkdir -p $@

# Download shellcheck

SHELLCHECK_VERSION=0.5.0
SHELLCHECK_TAR_SHA1=1af9177bd0698335c640831e8664313a0c4a4bb0
SHELLCHECK_TAR_DIR=shellcheck-v$(SHELLCHECK_VERSION)
SHELLCHECK_TAR_FN=$(SHELLCHECK_TAR_DIR).linux.x86_64.tar.xz
SHELLCHECK_TAR_URL_BASE=https://shellcheck.storage.googleapis.com/
SHELLCHECK_TAR_URL=$(SHELLCHECK_TAR_URL_BASE)$(SHELLCHECK_TAR_FN)
SHELLCHECK_TAR=$(TMP)/$(SHELLCHECK_TAR_FN)
SHELLCHECK=$(TMP)/$(SHELLCHECK_TAR_DIR)/shellcheck
SHELLCHECK_ARGS=

$(SHELLCHECK_TAR) : | $(TMP)
	curl --fail --output $@.tmp $(SHELLCHECK_TAR_URL)
	printf "%s %s\n" $(SHELLCHECK_TAR_SHA1) $@.tmp | sha1sum -c
	mv $@.tmp $@

$(SHELLCHECK) : | $(SHELLCHECK_TAR)
	tar Jxf $(SHELLCHECK_TAR) -C $(TMP) $(SHELLCHECK_TAR_DIR)/shellcheck

# Download multishellcheck

MULTISHELLCHECK_SHA1=b5348a91c7a325c588fc0c6b827b38fcd5be3d64
MULTISHELLCHECK_URL=https://raw.githubusercontent.com/CyberShadow/multishellcheck/$(MULTISHELLCHECK_SHA1)/multishellcheck
MULTISHELLCHECK=$(TMP)/multishellcheck-$(MULTISHELLCHECK_SHA1)
$(MULTISHELLCHECK) : | $(TMP)
	curl --output $@ $(MULTISHELLCHECK_URL)

# Download and build bash (for CI)

BASH_VERSION=4.4.18
BASH_TAR_SHA1=6cf9b3c23930ba8a721fee177d1558e5b7cb6104
BASH_TAR_DIR=bash-$(BASH_VERSION)
BASH_TAR_FN=$(BASH_TAR_DIR).tar.gz
BASH_TAR_URL_BASE=https://ftp.gnu.org/gnu/bash/
BASH_TAR_URL=$(BASH_TAR_URL_BASE)$(BASH_TAR_FN)
BASH_TAR=$(TMP)/$(BASH_TAR_FN)
BASH_BIN=$(TMP)/bash/bin/bash

$(BASH_TAR) : | $(TMP)
	curl --fail --output $@.tmp $(BASH_TAR_URL)
	printf "%s %s\n" $(BASH_TAR_SHA1) $@.tmp | sha1sum -c
	mv $@.tmp $@

$(BASH_BIN) : $(BASH_TAR)
	rm -rf $(TMP)/$(BASH_TAR_DIR)
	tar zxf $(BASH_TAR) -C $(TMP)
	cd $(TMP)/$(BASH_TAR_DIR) && ./configure --prefix=$(realpath $(TMP))/bash
	make -C $(TMP)/$(BASH_TAR_DIR) install

# Download and build coreutils (for CI)

COREUTILS_VERSION=8.29
COREUTILS_TAR_SHA1=63d522f430f0f9fceca71e4b52b414999531915c
COREUTILS_TAR_DIR=coreutils-$(COREUTILS_VERSION)
COREUTILS_TAR_FN=$(COREUTILS_TAR_DIR).tar.xz
COREUTILS_TAR_URL_BASE=https://ftp.gnu.org/gnu/coreutils/
COREUTILS_TAR_URL=$(COREUTILS_TAR_URL_BASE)$(COREUTILS_TAR_FN)
COREUTILS_TAR=$(TMP)/$(COREUTILS_TAR_FN)
COREUTILS_BIN_DIR=$(TMP)/coreutils/bin

$(COREUTILS_TAR) : | $(TMP)
	curl --fail --output $@.tmp $(COREUTILS_TAR_URL)
	printf "%s %s\n" $(COREUTILS_TAR_SHA1) $@.tmp | sha1sum -c
	mv $@.tmp $@

$(COREUTILS_BIN_DIR) : $(COREUTILS_TAR)
	rm -rf $(TMP)/$(COREUTILS_TAR_DIR)
	tar Jxf $(COREUTILS_TAR) -C $(TMP)
	cd $(TMP)/$(COREUTILS_TAR_DIR) && ./configure --prefix=$(realpath $(TMP))/coreutils
	make -C $(TMP)/$(COREUTILS_TAR_DIR) install

# Use built bash/coreutils with BUILD_BASH=1 (on Travis CI)

ifeq (,$(BUILD_BASH))
 BASH=$(shell command -v bash 2> /dev/null)
 BASH_DEP=
 PATH_PREFIX=
else
 BASH=$(realpath $(BASH_BIN))
 BASH_DEP=$(BASH_BIN) $(COREUTILS_BIN_DIR)
 PATH_PREFIX=$(realpath $(COREUTILS_BIN_DIR)):
endif

# ShellCheck rule

SHELLCHECK_OK=$(TMP)/.shellcheck-ok
shellcheck : $(SHELLCHECK_OK)
$(SHELLCHECK_OK) : $(SRC) $(SHELLCHECK) $(MULTISHELLCHECK)
	SHELLCHECK=$(SHELLCHECK) bash $(MULTISHELLCHECK) ../aconfmgr $(SHELLCHECK_ARGS)
	touch "$@"

# Test suite

TESTSUITE_LIB=$(wildcard t/lib*.bash t/mocks/*)
TESTSUITE_TESTS=$(wildcard t/t-*.sh)
TESTSUITE_TESTS_OK=$(patsubst t/%.sh,tmp/test/%/.ok,$(TESTSUITE_TESTS))
TESTSUITE=$(TESTSUITE_LIB) $(TESTSUITE_TESTS)

tmp/test/%/.ok : t/%.sh $(SRC) $(TESTSUITE_LIB) $(BASH_DEP)
	cd t && PATH=$(PATH_PREFIX)$(PATH) $(BASH) $(<:t/%=%)
	touch "$@"

testsuite : $(TESTSUITE_TESTS_OK)

# Coverage

COVERAGE_REPORT=$(TMP)/coverage/index.html
coverage : $(COVERAGE_REPORT)
$(COVERAGE_REPORT) : $(SRC) $(TESTSUITE) $(BASH_DEP) .simplecov
	PATH=$(PATH_PREFIX)$(PATH) bashcov --bash-path $(BASH) --root=.. t/all.sh

# Clean-up

clean :
	rm -rf $(TMP)

# GNU make directives

.PHONY: check ci shellcheck testsuite coverage clean
