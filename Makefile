SHELL := /usr/bin/env bash
PROFILE ?= standard

.PHONY: help check-device bootstrap configure verify verify-strict validate

help:
	@printf '%s\n' \
	  'make check-device             Validate the attached device identity' \
	  'make bootstrap PROFILE=dual-screen' \
	  '                              Install Obtainium and stage its import' \
	  'make configure                Create the non-sensitive device layout' \
	  'make verify                   Report provisioned and manual state' \
	  'make verify-strict            Fail unless every selected app is present' \
	  'make validate                 Validate repository files locally'

check-device:
	@./scripts/check-device.sh

bootstrap:
	@./scripts/bootstrap.sh --profile "$(PROFILE)"

configure:
	@./scripts/configure.sh

verify:
	@./scripts/verify.sh --profile "$(PROFILE)"

verify-strict:
	@./scripts/verify.sh --profile "$(PROFILE)" --strict

validate:
	@./scripts/validate.sh
