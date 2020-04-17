THIS_FILE := $(lastword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))


# do not change this order
SHELL_LIBS = lib/foo/foo.sh 
SHELL_LIBS += lib/bar/bar.sh 

SHELL_FLATTENED_NAME=baz-lib

SHELL_BINS:=$(call get_dirs,cmd)
SHELL_BUILD_TARGETS = $(SHELL_BINS:%=shell-build-%)
SHELL_FLATTEN_TARGETS = $(SHELL_BINS:%=shell-flatten-%)
SHELL_CLEAN_TARGETS = $(SHELL_BINS:%=shell-clean-%)

.PHONY: shell-build shell-clean shell-lib shell-targets $(SHELL_BINS) $(SHELL_BUILD_TARGETS) $(SHELL_FLATTEN_TARGETS) $(SHELL_CLEAN_TARGETS)
.SILENT: shell-build shell-clean shell-lib shell-targets $(SHELL_BINS) $(SHELL_BUILD_TARGETS) $(SHELL_FLATTEN_TARGETS) $(SHELL_CLEAN_TARGETS)

shell-build: shell-clean 
	- $(call print_running_target)
	- $(MKDIR) flattened
	- $(MKDIR) bin
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) lib
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(SHELL_BUILD_TARGETS)
	- $(RM) flattened
	- $(call print_completed_target)
shell-clean: 
	- $(call print_running_target)
	- $(RM) flattened
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(SHELL_CLEAN_TARGETS)
	- $(call print_completed_target)
shell-lib:
	- $(call print_running_target)
	- $(eval output_temp=$(PWD)/flattened/${SHELL_FLATTENED_NAME}_temp.sh)
	- $(foreach O,\
			$(SHELL_LIBS),\
			$(call append_to_file,\
				$(output_temp),$(call read_file_content,$O)\
			)\
		)
	- $(call print_completed_target,flattened makefiles)
	- $(call remove_matching_lines,#!, $(output_temp))
	- $(call print_completed_target,removed script shebangs)
	- $(call remove_matching_lines,# shellcheck, $(output_temp))
	- $(call print_completed_target,removed script shellcheck)
	- $(call remove_matching_lines,dirname "${SHELL_SOURCE[0]}" , $(output_temp))
	- $(call print_completed_target,removed individual script source)
	- $(call remove_empty_lines, $(output_temp))
	- $(call print_completed_target,removed empty lines)
	- $(call print_completed_target)

$(SHELL_BUILD_TARGETS):$(SHELL_FLATTEN_TARGETS)
	- $(call print_running_target)
	- $(eval name=$(@:shell-build-%=%))
	- $(eval output=$(PWD)/bin/$(name))
	- $(call append_to_file,$(output),#!/usr/bin/env shell)
	- $(call append_to_file,$(output),# Flattened ... do not modify )
	- $(call print_completed_target,created main flattened script and added shebang)
	- $(eval base = $(PWD)/flattened/${SHELL_FLATTENED_NAME}_temp.sh)
	- $(call append_to_file,$(output),$(call read_file_content,$(base)))	
	- $(eval curr_file = $(PWD)/flattened/$(name)_temp.sh)
	- $(call append_to_file,$(output),$(call read_file_content,$(curr_file)))	
	- $(RM) flattened/$(name)_temp.sh
	- chmod +x $(output)
	- $(call print_completed_target)
$(SHELL_FLATTEN_TARGETS): 
	- $(call print_running_target)
	- $(eval name=$(@:shell-flatten-%=%))
	- $(eval output_temp=$(PWD)/flattened/$(name)_temp.sh)
	- $(foreach O,\
			$(PWD)/cmd/$(name)/$(name).sh,\
			$(call append_to_file,\
				$(output_temp),$(call read_file_content,$O)\
			)\
		)
	- $(call print_completed_target,flattened libraries)
	- $(call remove_matching_lines,#!, $(output_temp))
	- $(call print_completed_target,removed script shebangs)
	- $(call remove_matching_lines,# shellcheck, $(output_temp))
	- $(call print_completed_target,removed script shellcheck)
	- $(call remove_matching_lines,dirname "${SHELL_SOURCE[0]}" , $(output_temp))
	- $(call print_completed_target,removed individual script source)
	- $(call remove_empty_lines, $(output_temp))
	- $(call print_completed_target,removed empty lines)
	- $(call print_completed_target)

$(SHELL_CLEAN_TARGETS):
	- $(call print_running_target)
	- $(eval name=$(@:shell-clean-%=%))
	- $(RM) bin/$(name)
	- $(call print_completed_target)
shell-targets: 
	- $(call print_running_target)
	- $(info $(SHELL_LIBS))

