WOLFRAMSCRIPT ?= $(HOME)/Wolfram/Mathematica/14.3/Executables/wolframscript
export WOLFRAMSCRIPT
CONFIG ?= data/configs/07/known.json

.PHONY: sync test test-py test-wl test-all lint fmt verify known hooks

hooks:
	chmod +x .githooks/pre-commit
	git config core.hooksPath .githooks

sync:
	uv sync

test: test-py test-wl

test-py:
	uv run pytest -q -m "not slow"

test-wl:
	$(WOLFRAMSCRIPT) -file wl/tests/run_tests.wls

test-all: test-wl
	uv run pytest -q

lint:
	uv run ruff check src tests

fmt:
	uv run ruff check --fix src tests
	uv run ruff format src tests

verify:
	uv run circovcir verify $(CONFIG) --wolfram

known:
	$(WOLFRAMSCRIPT) -file wl/scripts/make_known_configs.wls
