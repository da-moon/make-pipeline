
THIS_FILE := $(lastword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
.PHONY: python-run python-clean python-pip-upgrade python-pip python-develop python-clean python-add-shebang python-print
.SILENT: python-run python-clean python-pip-upgrade python-pip python-develop python-clean python-add-shebang python-print

BENCH_FUNCS := schaffer eggholder booth matyas cross levi
.PHONY: BENCH_FUNCS 
.SILENT: BENCH_FUNCS 

python-run: python-develop
	- $(call print_running_target)
ifneq ($(EXPORT_ROOT),)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(WOA_CLEAN_TARGETS)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(GWO_CLEAN_TARGETS)
endif
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(WOA_TARGETS)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(GWO_TARGETS)
	- $(call print_completed_target)
python-pip-upgrade:
	- $(call print_running_target)
	- python3 -m pip install --upgrade pip
	- $(call print_completed_target)
python-pip: python-pip-upgrade
	- $(call print_running_target)
	- $(call print_running_target, installing tsplib95)
	- python3 -m pip install --quiet tsplib95
	- $(call print_running_target, installing matplotlib)
	- python3 -m pip install --quiet matplotlib
	- $(call print_running_target, installing networkx)
	- python3 -m pip install --quiet networkx
	- $(call print_running_target, installing sympy)
	- python3 -m pip install --quiet sympy
	- $(call print_running_target, installing numpy)
	- python3 -m pip install --quiet numpy
	- $(call print_running_target, installing setuptools)
	- python3 -m pip install --quiet setuptools
	- $(call print_running_target, installing pandas)
	- python3 -m pip install --quiet pandas
	- $(call print_running_target, installing tabulate)
	- python3 -m pip install --quiet tabulate
	- $(call print_completed_target)

WOA_TARGETS = $(BENCH_FUNCS:%=woa-%)
WOA_CLEAN_TARGETS = $(WOA_TARGETS:%=clean-%)
.PHONY: BENCH_FUNCS $(WOA_TARGETS) $(WOA_CLEAN_TARGETS)
.SILENT: BENCH_FUNCS $(WOA_TARGETS)$(WOA_CLEAN_TARGETS)
$(WOA_TARGETS): $(WOA_CLEAN_TARGETS)
	- $(call print_running_target)
	- $(eval name=$(@:woa-%=%))
	- $(eval command=$(PWD)$(PSEP)metaheuristics$(PSEP)__main__.py)
ifneq ($(Log_LEVEL),)
	- $(eval command += --log $(Log_LEVEL))
endif
	- $(eval command += woa)
ifneq ($(EXPORT_ROOT),)
	- $(MKDIR) $(EXPORT_ROOT)
	- $(eval path = $(PWD)$(PSEP)export$(PSEP)woa-$(name).csv)
	- $(eval command += --csv-export $(path))
endif
ifneq ($(PLOT),)
ifeq ($(PLOT),true)
	- $(eval command += --plot)
endif
endif
	- $(eval command += --function $(name))
	- $(call print_running_env_enter,$(command),HOST OS)
	- python3 $(command)
	- $(call print_running_env_exit)
	- $(call print_completed_target)

$(WOA_CLEAN_TARGETS):
	- $(call print_running_target)
ifneq ($(EXPORT_ROOT),)
	- $(eval name=$(@:clean-%=%))
	- $(RM) $(PWD)$(PSEP)$(EXPORT_ROOT)$(PSEP)$(name).csv
endif
	- $(call print_completed_target)


GWO_TARGETS = $(BENCH_FUNCS:%=gwo-%)
GWO_CLEAN_TARGETS = $(GWO_TARGETS:%=gwo-%)
.PHONY: $(GWO_TARGETS) $(GWO_CLEAN_TARGETS)
.SILENT:  $(GWO_TARGETS)   $(GWO_CLEAN_TARGETS)

$(GWO_TARGETS): $(GWO_CLEAN_TARGETS)
	- $(call print_running_target)
	- $(eval name=$(@:gwo-%=%))
	- $(eval command=$(PWD)$(PSEP)metaheuristics$(PSEP)__main__.py)
ifneq ($(Log_LEVEL),)
	- $(eval command += --log $(Log_LEVEL))
endif
	- $(eval command += gwo)
ifneq ($(EXPORT_ROOT),)
	- $(MKDIR) $(EXPORT_ROOT)
	- $(eval path = $(PWD)$(PSEP)export$(PSEP)gwo-$(name).csv)
	- $(eval command += --csv-export $(path))
endif
ifneq ($(PLOT),)
ifeq ($(PLOT),true)
	- $(eval command += --plot)
endif
endif
	- $(eval command += --function $(name))
	- $(call print_running_env_enter,$(command),HOST OS)
	- python3 $(command)
	- $(call print_running_env_exit)
	- $(call print_completed_target)

python-develop: python-add-shebang
	- $(call print_running_target)
	- python3 $(PWD)$(PSEP)setup.py develop
	- $(call print_completed_target)
python-add-shebang: 
	- $(call print_running_target)
	- $(PWD)$(PSEP)contrib$(PSEP)scripts$(PSEP)add_shebang
	- $(call print_completed_target)
python-clean:
	- $(call print_running_target)
	- $(call print_running_target, running setup.py clean)
	- python3 $(PWD)$(PSEP)setup.py clean
	- $(call print_running_target, removing egg-info directories)
	- $(RM) $(PWD)$(PSEP)*.egg-info
	- $(call print_running_target, removing __pycache__ directories)
	- $(RM) $(call rwildcard,$(PWD)/metaheuristics/__pycache__)
	- $(RM) $(call rwildcard,$(PWD)/metaheuristics/*/__pycache__)
	- $(call print_completed_target)
python-print:
	- $(call print_running_target)
	- $(call print_completed_target)



