
THIS_FILE := $(lastword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
JAVA_IMAGE=openjdk:latest
Log_LEVEL = FINE
JDBC_VERSION = 3.30.1

.PHONY: java-vendor java-build java-run java-clean java-print java-sqlite java-add-student-id
.SILENT: java-vendor java-build java-run java-clean java-print java-sqlite java-add-student-id 
JAVA_TARGETS:=$(call get_dirs,projects)
JAVA_BUILD_TARGETS = $(JAVA_TARGETS:%=java-build-%)
JAVA_VENDOR_TARGETS = $(JAVA_TARGETS:%=java-vendor-%)
CLEAN_TARGETS = $(JAVA_TARGETS:%=java-clean-%)
.PHONY: $(JAVA_BUILD_TARGETS) $(JAVA_VENDOR_TARGETS) $(CLEAN_TARGETS)
.SILENT: $(JAVA_BUILD_TARGETS) $(JAVA_VENDOR_TARGETS) $(CLEAN_TARGETS)
SQLITE_CP=$(PWD)$(PSEP)fixtures$(PSEP)sqlite-driver$(PSEP)sqlite-jdbc-${JDBC_VERSION}.jar

java-print:
	- $(call print_running_target)
	- $(info $(JAVA_TARGETS))
	- $(call print_completed_target)
java-run: 
	- $(call print_running_target)
	- $(eval name=app)
	- $(eval root=$(PWD)$(PSEP)projects$(PSEP)lab5)
	- $(eval cp=$(root)$(PSEP)classes)
	- $(eval command=java --class-path $(cp):$(SQLITE_CP) com.$(name).app)
ifneq ($(Log_LEVEL),)
	- $(eval command += --log-level $(Log_LEVEL))
endif
	- $(eval help_command = $(command) --help)
# 	- $(eval store_sub_command = $(command) store )
    ifeq ($(DOCKER_ENV),true)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell docker_image="${JAVA_IMAGE}" container_name="java_java-builder_container" mount_point="/go/src/github.com/da-moon/go-packages" cmd="$(command)"
    else
	- $(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="$(help_command)"; 
    endif
	- $(call print_completed_target)
java-build: 
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(JAVA_BUILD_TARGETS)
	- $(call print_completed_target)
java-vendor:  
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(JAVA_VENDOR_TARGETS)
	- $(call print_completed_target)
java-sqlite: 
	- $(call print_running_target)
	- aria2c -c -x16 -j16 -k 1M -d $(PWD)$(PSEP)fixtures$(PSEP)sqlite-driver https://bitbucket.org/xerial/sqlite-jdbc/downloads/sqlite-jdbc-${JDBC_VERSION}.jar
	- $(call print_completed_target)
java-clean: 
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(CLEAN_TARGETS)
	- $(call print_completed_target)

$(JAVA_BUILD_TARGETS): 
	- $(call print_running_target)
	- $(eval name=$(@:java-build-%=%))
	- $(eval root=$(PWD)$(PSEP)projects$(PSEP)$(name))
	- $(eval targets=$(dir $(wildcard $(root)$(PSEP)src$(PSEP)com$(PSEP)*$(PSEP).)))
	- $(eval cp=$(root)$(PSEP)classes)
	- $(eval command=javac -d $(cp) --class-path $(cp):$(SQLITE_CP) )
	- $(eval command += -s $(root)$(PSEP)src$(PSEP)com)
	- $(MKDIR) $(root)/classes
    ifeq ($(DOCKER_ENV),true)
	for target in $(targets); do \
            $(MAKE) --no-print-directory -f $(THIS_FILE) shell docker_image="${JAVA_IMAGE}" container_name="java_java-builder_container" mount_point="/go/src/github.com/da-moon/go-packages" cmd="$(command) $$target*.java"; \
	done
    endif
    ifeq ($(DOCKER_ENV),false)
	for target in $(targets); do \
			$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="$(command) $$target*.java"; \
	done
    endif
	- $(call print_completed_target)
$(JAVA_VENDOR_TARGETS): 
	- $(call print_running_target)
	- $(eval name=$(@:vendor-%=%))
	- $(eval root=$(PWD)$(PSEP)projects$(PSEP)$(name))
	- $(eval targets=$(dir $(wildcard $(root)$(PSEP)src$(PSEP)vendor$(PSEP)*$(PSEP).)))
	- $(eval cp=$(root)$(PSEP)classes)
	- $(eval command=javac -nowarn -d $(cp) --class-path $(cp):$(SQLITE_CP) )
	- $(eval command += -s $(root)$(PSEP)src$(PSEP)vendor)

	- $(MKDIR) $(root)/classes/vendor
    ifeq ($(DOCKER_ENV),true)
	for target in $(targets); do \
            $(MAKE) --no-print-directory -f $(THIS_FILE) shell docker_image="${JAVA_IMAGE}" container_name="java_java-builder_container" mount_point="/go/src/github.com/da-moon/go-packages" cmd="$(command) $$target*.java"; \
	done
    endif
    ifeq ($(DOCKER_ENV),false)
	for target in $(targets); do \
			$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="$(command) $$target*.java"; \
	done
    endif
	- $(call print_completed_target)
$(CLEAN_TARGETS): 
	- $(call print_running_target)
	- $(eval name=$(@:clean-%=%))
	- $(eval root=$(PWD)$(PSEP)projects$(PSEP)$(name))
	- $(RM) $(root)/classes/com
	- $(RM) $(root)/classes/vendor
	- $(call print_completed_target)
