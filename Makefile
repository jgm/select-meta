DIFF ?= diff --strip-trailing-cr -u

.PHONY: test
test:
	@pandoc --lua-filter=select-meta.lua sample.md -f markdown -t markdown -o expected.md -s
