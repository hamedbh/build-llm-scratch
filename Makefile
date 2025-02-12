.PHONY: all data clean lint format requirements environment test help

## Build the whole pipeline
all: data test clean lint requirements 

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_NAME = build-llm-scratch

###############################################################################
# COMMANDS                                                                    #
###############################################################################

# Use phony targets to group together multiple steps for the same aim. Here 
# `data` is a phony target that depends on `data/dataset.csv`, which in turn 
# is created by calling the script at `src/data/make_dataset.py`. If there were
# multiple datasets to create these could all be listed as dependencies of 
# `data`, e.g.:
#
# data: data/dataset1.csv data/dataset2.csv
#
# The comment after the double `##` becomes the description of the target when
# running `make` or `make help` at the command line.

## Chapter 2 files
chapter_02: data/external/the_verdict_edith_wharton.txt

data/external/the_verdict_edith_wharton.txt: src/data/download_the_verdict.py
	python3 -m src.data.download_the_verdict -o $@
## Make datasets
data: data/raw/dataset.csv

data/raw/dataset.csv:
	python3 -m src.data.make_dataset

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using ruff
lint:
	ruff check

## Format source code with ruff
format:
	ruff format

## Install required packages, including local/project source code	
requirements: requirements.txt dev_requirements.txt
	uv pip sync $^

requirements.txt: pyproject.toml
	uv pip compile $< -o $@

dev_requirements.txt: pyproject.toml
	uv pip compile $< --all-extras -o $@

## Set up the Python environment
environment:
	uv venv --seed
	./.venv/bin/pip install -U pip setuptools

## Run the tests
test:
	pytest tests

###############################################################################
# Self Documenting Commands                                                   #
###############################################################################

.DEFAULT_GOAL := help

# Inspired by 
# <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')

