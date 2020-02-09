# Definitions and Configurations Variables
CONTENT_DIR=content
BUILD_DIR=build
SITE_DIR=site
ASSETS_DIR=assets
METADATA_DIR=metadata
PANDOC_FROM=markdown+emoji
# Find all markdown files
MARKDOWN=$(shell find $(CONTENT_DIR) -iname "*.md")
# Find all associated mardkown metadata files
MARKDOWN_META=$(shell find $(METADATA_DIR) -iname "*.meta.yaml")
# Form all 'meta.yaml' counterparts
META=$(MARKDOWN:.md=.meta.yaml)
# Form all 'html' counterparts
HTML=$(META:.meta.yaml=.html)
# For removing built meta files
BUILT=$(META:.meta.yaml=.del.meta.yaml)
#.PHONY = all $(META) $(HTML) $(BUILT) ASSETS
all: $(META) $(HTML) $(BUILT) CP_ASSETS local
# process markdown files through select-meta into $(BUILD_DIR)
%.meta.yaml: %.md
	$(shell mkdir -pv $(shell dirname $(BUILD_DIR)/$(@:$(CONTENT_DIR)/%=%)))
	pandoc --data-dir . -ddefaults -s -f markdown -t markdown -L select-meta.lua $(METADATA_DIR)/$(@:$(CONTENT_DIR)/%=%) $< -o $(BUILD_DIR)/$(@:$(CONTENT_DIR)/%=%)
# pandocify composed .meta.yaml md files to html into $(SITE_DIR)
%.html: %.meta.yaml
	$(shell mkdir -pv $(shell dirname $(SITE_DIR)/$(@:$(CONTENT_DIR)/%=%)))
	pandoc --data-dir . -ddefaults -s --from $(PANDOC_FROM) --to html --toc $(BUILD_DIR)/$(<:$(CONTENT_DIR)/%=%) -o $(SITE_DIR)/$(@:$(CONTENT_DIR)/%=%)
# delete metedata yaml build files
%.del.meta.yaml: %.meta.yaml
	rm -v $(BUILD_DIR)/$(<:$(CONTENT_DIR)/%=%)
# copy assets to $(SITE_DIR)
CP_ASSETS:
	@echo Copying assets
	@cp -apv $(ASSETS_DIR) $(SITE_DIR)
# local web server via python3
SERVER:
	@echo Starting local web server:
	@python3 -m http.server 8000 --bind 127.0.0.1 --directory $(SITE_DIR)
OPEN:
	@sleep 1
	@echo Opening site:
	@open http://127.0.0.1:8000

local:
	@make -j 2 SERVER OPEN
