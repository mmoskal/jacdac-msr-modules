.SECONDARY: # this prevents object files from being removed
.DEFAULT_GOAL := all

JD_CORE = jacdac-c
JD_STM = jacdac-stm32x0

_IGNORE0 := $(shell test -f Makefile.user || cp sample-Makefile.user Makefile.user)
_IGNORE1 := $(shell test -f $(JD_STM)/stm32/cmsis_device_g0/README.md || git submodule update --init --recursive 1>&2)

include Makefile.user

DROP_TARGETS ?= jm-v2.0 jm-v2.0i jm-v2.0p jm-v2.1 jm-temp-humidity-18-1.0A jm-rotary-control-26-1.0A jm-v3.1

include $(JD_STM)/build.mk

check-release:
	if [ "X`git describe --exact --tags --match 'v[0-9]*' 2>/dev/null`" != "X" ]; then $(MAKE) build-release ; fi

build-release: drop
	# avoid re-computing FW_VERSION many times
	$(MAKE) do-build-release FW_VERSION=$(FW_VERSION)

do-build-release:
	cp built/drop.uf2 dist/fw-$(FW_VERSION).uf2
	git add dist/fw-$(FW_VERSION).uf2
	if [ "X$$GITHUB_WORKFLOW" != "X" ] ; then git config user.email "<>" && git config user.name "GitHub Bot" ; fi
	git commit -m "[skip ci] firmware $(FW_VERSION) built"
	git push
