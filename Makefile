# Latex and graphviz compilation tool
# Copyright (C) 2009-2010. Abel Sinkovics (abel@sinkovics.hu)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# The shell to use
SHELL ?= /bin/bash

# The output directory to use
OUT_DIR ?= .
ifeq ($(wildcard out_dir),out_dir)
	OUT_DIR := $(shell cat out_dir)
endif

# List of options
OPTIONS += SHOW_CMD
OPTIONS += SHOW_FORMAT

OPTIONS += SLIDES_CMD
OPTIONS += SLIDES_FORMAT

OPTIONS += TEMPLATE_NAME

OPTIONS += PROJECT_NAME

OPTIONS += FTP_HOST
OPTIONS += FTP_USERNAME

OPTIONS += OUT_DIR

OPTIONS += SHELL

OPTIONS += REMOVE_OLD_LATEX_MAKEFILE

# The graphviz files
SRC_DOT_FILES = $(wildcard *.dot)
SRC_FILES += SRC_DOT_FILES

DOT_PS_FILES = $(addprefix $(OUT_DIR)/,$(SRC_DOT_FILES:.dot=.ps))
OUT_PS_FILES += $(DOT_PS_FILES)

DOT_PDF_FILES = $(DOT_PS_FILES:.ps=.pdf)
PS_PDF_FILES += $(DOT_PDF_FILES)

DOT_SVG_FILES = $(addprefix $(OUT_DIR)/,$(SRC_DOT_FILES:.dot=.svg))
OUT_SVG_FILES += $(DOT_SVG_FILES)

DOT_SVGZ_FILES = $(addprefix $(OUT_DIR)/,$(SRC_DOT_FILES:.dot=.svgz))
OUT_SVGZ_FILES += $(DOT_SVGZ_FILES)

DOT_FIG_FILES = $(addprefix $(OUT_DIR)/,$(SRC_DOT_FILES:.dot=.fig))
OUT_FIG_FILES += $(DOT_FIG_FILES)

DOT_PNG_FILES = $(addprefix $(OUT_DIR)/,$(SRC_DOT_FILES:.dot=.png))
OUT_PNG_FILES += $(DOT_PNG_FILES)

DOT_GIF_FILES = $(addprefix $(OUT_DIR)/,$(SRC_DOT_FILES:.dot=.gif))
OUT_GIF_FILES += $(DOT_GIF_FILES)

DOT_JPG_FILES = $(addprefix $(OUT_DIR)/,$(SRC_DOT_FILES:.dot=.jpg))
OUT_JPG_FILES += $(DOT_JPG_FILES)

# The latex files
SRC_TEX_FILES = $(wildcard *.tex)
SRC_FILES += SRC_TEX_FILES

TEX_DVI_FILES = $(addprefix $(OUT_DIR)/,$(SRC_TEX_FILES:.tex=.dvi))
OUT_DVI_FILES += $(TEX_DVI_FILES)
DVI_PS_FILES += $(TEX_DVI_FILES:.dvi=.ps)
DVI_PDF_FILES += $(TEX_DVI_FILES:.dvi=.pdf)

TMP_LOG_FILES = $(addprefix $(OUT_DIR)/,$(SRC_TEX_FILES:.tex=.log))
TEMP_FILES += $(TMP_LOG_FILES)

TMP_AUX_FILES = $(addprefix $(OUT_DIR)/,$(SRC_TEX_FILES:.tex=.aux))
TEMP_FILES += $(TMP_AUX_FILES)

TMP_NAV_FILES = $(SRC_TEX_FILES:.tex=.nav)
TEMP_FILES += $(TMP_NAV_FILES)

OUT_FILES = $(SRC_TEX_FILES:.tex=.out)
TEMP_FILES += $(OUT_FILES)

TMP_SNM_FILES = $(SRC_TEX_FILES:.tex=.snm)
TEMP_FILES += $(TMP_SNM_FILES)

TMP_TOC_FILES = $(SRC_TEX_FILES:.tex=.toc)
TEMP_FILES += $(TMP_TOC_FILES)

TMP_VRB_FILES = $(SRC_TEX_FILES:.tex=.vrb)
TEMP_FILES += $(TMP_VRB_FILES)

# Join same file types coming from different source formats
OUT_PS_FILES += $(DVI_PS_FILES)
OUT_PDF_FILES += $(DVI_PDF_FILES) $(PS_PDF_FILES)

# Files that are real targets
TARGET_FILES += $(OUT_DVI_FILES)
TARGET_FILES += $(OUT_PS_FILES)
TARGET_FILES += $(OUT_PDF_FILES)
TARGET_FILES += $(OUT_SVG_FILES)
TARGET_FILES += $(OUT_SVGZ_FILES)
TARGET_FILES += $(OUT_FIG_FILES)
TARGET_FILES += $(OUT_PNG_FILES)
TARGET_FILES += $(OUT_GIF_FILES)
TARGET_FILES += $(OUT_JPG_FILES)

# Files that are archived when an archive is created
FILES_TO_ARCHIVE = $(shell ls $(OUT_DIR)/* | egrep -v '[.]zip$$' $(foreach f,$(TEMP_FILES) $(TARGET_FILES), | grep -vF $(f)))

# Default options
DEFAULT_SLIDES_CMD = xpdf -fullscreen -aa yes -aaVector yes
DEFAULT_SLIDES_FORMAT = pdf

DEFAULT_SHOW_CMD = acroread
DEFAULT_SHOW_FORMAT = pdf

# Options
SHOW_CMD ?= $(DEFAULT_SHOW_CMD)
SHOW_FORMAT ?= $(DEFAULT_SHOW_FORMAT)
SLIDES_CMD ?= $(DEFAULT_SLIDES_CMD)
SLIDES_FORMAT ?= $(DEFAULT_SLIDES_FORMAT)

# Name of the project
PROJECT_NAME ?= $(shell cat projectName.txt 2>/dev/null)

# Postfix for archives
ARCHIVE_NAME = $(PROJECT_NAME)_$(shell date '+%Y_%m_%d')

ZIP_ARCHIVE = $(ARCHIVE_NAME).zip

# Display the name of an option and it's default value
showOptionAndDefault = $(1)=$(DEFAULT_$(strip $(1)))

# Phony target to compile all latex files
all_target : dvi ps pdf svg svgz fig png gif jpg
.PHONY: all_target

# Targets for file formats
dvi : $(OUT_DVI_FILES)
ps  : $(OUT_PS_FILES)
pdf : $(OUT_PDF_FILES)
svg : $(OUT_SVG_FILES)
svgz : $(OUT_SVGZ_FILES)
fig : $(OUT_FIG_FILES)
png : $(OUT_PNG_FILES)
gif : $(OUT_GIF_FILES)
jpg : $(OUT_JPG_FILES)

.PHONY: dvi ps pdf svg svgz fig png gif jpg

# Dependencies between different types of data formats
LATEX_DEPENDENCIES += $(DOT_PS_FILES) $(DOT_PDF_FILES) $(DOT_FIG_FILES)

$(DOT_PS_FILES) : $(OUT_DIR)/%.ps : %.dot $(OUT_DIR)
	dot -Tps $< -o $@

$(DOT_SVG_FILES) : $(OUT_DIR)/%.svg : %.dot
	dot -Tsvg $< -o $@

$(DOT_SVGZ_FILES) : $(OUT_DIR)/%.svgz : %.dot
	dot -Tsvgz $< -o $@

$(DOT_FIG_FILES) : $(OUT_DIR)/%.fig : %.dot
	dot -Tfig $< -o $@

$(DOT_PNG_FILES) : $(OUT_DIR)/%.png : %.dot
	dot -Tpng $< -o $@

$(DOT_GIF_FILES) : $(OUT_DIR)/%.gif : %.dot
	dot -Tgif $< -o $@

$(DOT_JPG_FILES) : $(OUT_DIR)/%.jpg : %.dot
	dot -Tjpg $< -o $@

$(TEX_DVI_FILES) : $(OUT_DIR)/%.dvi : %.tex $(OUT_DIR) $(LATEX_DEPENDENCIES)
	latex -output-directory $(OUT_DIR) $< && latex -output-directory $(OUT_DIR) $<

# Convert dvi files to ps files
$(DVI_PS_FILES) : %.ps : %.dvi
	dvips -o $@ $<

# Convert dvi files to pdf files
$(DVI_PDF_FILES) : %.pdf : %.dvi
	dvipdf $< $@

# Convert ps files to pdf files
$(PS_PDF_FILES) : %.pdf : %.ps
	ps2pdf $< $@

# Remove temporary files
clean_tmp :
	-rm $(TEMP_FILES)

.PHONY: clean_tmp

# Remove every generated file, and the output directory if it's empty
clean : clean_tmp
	-rm $(TARGET_FILES)
	-rmdir $(OUT_DIR)

.PHONY: clean

# Clean & build
all : clean all_latex
.PHONY: all

# Show
show : $(SRC_TEX_FILES:.tex=.$(SHOW_FORMAT))
	$(foreach f,$+, $(SHOW_CMD) $(f) && ) true
.PHONY: show

# Display slideshow
slides : $(SRC_TEX_FILES:.tex=.$(SLIDES_FORMAT))
	$(foreach f,$+, $(SLIDES_CMD) $(f) && ) true

# Display options
options :
	@$(foreach OPT,$(OPTIONS), echo $(OPT)=$($(OPT)) && ) true
.PHONY: options

# Update to the latest version of this template
ifdef REMOVE_OLD_LATEX_MAKEFILE
  REMOVE_OLD_MAKEFILE = rm Makefile
else
  REMOVE_OLD_MAKEFILE = mv Makefile Makefile.old
endif

update :
	-rm Makefile.old
	$(REMOVE_OLD_MAKEFILE)
	wget http://latex.sinkovics.hu/Makefile
.PHONY: update

# Grep all TODOs in the source files
todo :
	@grep TODO $(SRC_TEX_FILES)
.PHONY: todo

# Create an archive
zip : $(ZIP_ARCHIVE)
.PHONY : zip

$(ZIP_ARCHIVE) : $(FILES_TO_ARCHIVE)
	-rm $(ZIP_ARCHIVE)
	zip $(ZIP_ARCHIVE) $(FILES_TO_ARCHIVE)

# Create a backup
backup : $(ZIP_ARCHIVE)
	echo '$(FTP_USERNAME)\nput $(ZIP_ARCHIVE)' | ftp $(FTP_HOST)

# Create a project name file
project :
	echo $(PROJECT_NAME) > projectName.txt
.PHONY: project

# Create a slides template
REDIRECT = >> $(TEMPLATE_NAME).tex

slides_template :
	@echo > $(TEMPLATE_NAME).tex
	@echo '\\documentclass{beamer}' $(REDIRECT)
	@echo '' $(REDIRECT)
	@echo '\\usepackage{beamerthemesplit}' $(REDIRECT)
	@echo '' $(REDIRECT)
	@echo '\\title{Title}' $(REDIRECT)
	@echo '\\author{Author}' $(REDIRECT)
	@echo '\\date{\\today}' $(REDIRECT)
	@echo '' $(REDIRECT)
	@echo '\\begin{document}' $(REDIRECT)
	@echo '' $(REDIRECT)
	@echo '\\frame{\\titlepage}' $(REDIRECT)
	@echo '' $(REDIRECT)
	@echo '\\section[Outline]{}' $(REDIRECT)
	@echo '\\frame{\\tableofcontents}' $(REDIRECT)
	@echo '' $(REDIRECT)
	@echo '\\section{Introduction}' $(REDIRECT)
	@echo '\\subsection{Overview}' $(REDIRECT)
	@echo '\\frame' $(REDIRECT)
	@echo '{' $(REDIRECT)
	@echo '  \\frametitle{Frame1}' $(REDIRECT)
	@echo '}' $(REDIRECT)
	@echo '\\end{document}' $(REDIRECT)
.PHONY: template

# Create output directory
$(OUT_DIR) :
	mkdir -p $(OUT_DIR)

# Help
help_make : help_header
	@echo "    make                 - Compiles everything to every format"
	@echo
	@echo "    make [file format]   - Compiles everything to specified format"
	@echo "                           Supported formats: dvi, ps, pdf, svg, svgz, fig,"
	@echo "                           png, gif, jpg"
	@echo "                           Target files are generated in OUT_DIR which is"
	@echo "                           . by default."
	@echo "                           If a file called out_dir exists, it's content"
	@echo "                           overrides the value of OUT_DIR."
	@echo
HELP_TARGETS += make

help_clean_tmp : help_header
	@echo "    make clean_tmp       - Deletes temporary files"
	@echo
HELP_TARGETS += clean_tmp

help_clean : help_header
	@echo "    make clean           - Deletes temporary files and targets"
	@echo
HELP_TARGETS += clean

help_all : help_header
	@echo "    make all             - Rebuilds everything"
	@echo
HELP_TARGETS += all

help_help : help_header
	@echo "    make help            - Display usage"
	@echo
	@echo "    make help_[target]   - Display usage of the specified target"
	@echo
HELP_TARGETS += help

help_show : help_header
	@echo "    make show            - Compile everything and show them"
	@echo
	@echo "                           Program used for displaying can be overwritten:"
	@echo "                             SHOW_CMD=<command>"
	@echo "                           Preferred file format can be overwritten:"
	@echo "                             SHOW_FORMAT=<format>"
	@echo "                           Example:"
	@echo "                             make show SHOW_CMD=kghostview SHOW_FORMAT=pdf"
	@echo "                           These values can be overwritten by defining"
	@echo "                           environment variables as well, for example:"
	@echo "                             export SHOW_CMD=kghostview"
	@echo "                           Default values:"
	@echo "                             $(call showOptionAndDefault, SHOW_CMD)"
	@echo "                             $(call showOptionAndDefault, SHOW_FORMAT)"
	@echo
HELP_TARGETS += show

help_slides : help_header
	@echo "    make slides          - Display a slideshow"
	@echo "                           Works similarly to \"make show\""
	@echo "                           The environment variables it uses and their"
	@echo "                           default values:"
	@echo "                             $(call showOptionAndDefault, SLIDES_CMD)"
	@echo "                             $(call showOptionAndDefault, SLIDES_FORMAT)"
	@echo
HELP_TARGETS += slides

help_options : help_header
	@echo "    make options         - Display all options"
	@echo
HELP_TARGETS += options

help_slides_template : help_header
	@echo "    make slides_template - Create a slides template latex source to start with"
	@echo "                           The name of the generated template is the"
	@echo "                           value of the TEMPLATE_NAME option."
	@echo
HELP_TARGETS += slides_template

help_update : help_header
	@echo "    update               - Get the latest version of this makefile"
	@echo "                           Internet connection required."
	@echo "                           Unless REMOVE_OLD_LATEX_MAKEFILE is defined, it"
	@echo "                           keeps the old version of this makefile as"
	@echo "                           Makefile.old"
	@echo
HELP_TARGETS += update

help_zip : help_header
	@echo "    zip                  - Cleans the code and creates a zip archive"
	@echo "                           from it. The name of the zip file depends"
	@echo "                           on the value of PROJECT_NAME"
	@echo
HELP_TARGETS += zip

help_project : help_header
	@echo "    project              - Creates a projectName.txt file in which the"
	@echo "                           value of the actual PROJECT_NAME is stored."
	@echo "                           It will be the default value for PROJECT_NAME"
	@echo
HELP_TARGETS += project

help_backup : help_header
	@echo "    backup               - Creates a zip archive and uploads it to"
	@echo "                           a backup server defined by:"
	@echo "                              FTP_HOST and FTP_USERNAME"
	@echo "                           Password has to be typed interactively"
	@echo
HELP_TARGETS += backup

help_todo : help_header
	@echo "    todo                 - Grep for the TODO text in the source files."
	@echo
HELP_TARGETS += todo

help_targets : help_header
	@echo "    targets              - List accepted make targets"
	@echo
HELP_TARGETS += targets

help_header : license
	@echo "  Usage:"
	@echo

license :
	@echo
	@echo "Latex and Graphviz compilation tool."
	@echo "Copyright (C) 2009.  Abel Sinkovics (abel@sinkovics.hu)"
	@echo "This program comes with ABSOLUTELY NO WARRANTY"
	@echo "This is free software, and you are welcome to redistribute it"
	@echo "under certain conditions; see http://www.gnu.org/licenses/ for details."
	@echo

help : help_header $(addprefix help_, $(HELP_TARGETS))

targets : help_header
	@echo " $(foreach t, $(sort $(HELP_TARGETS)),   $(t)\n)"



