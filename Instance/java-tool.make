#
#   Instance/java-tool.make
#
#   Instance makefile rules to build Java command-line tools.
#
#   Copyright (C) 2001 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola@brainstorm.co.uk>
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# Why using Java if you can use Objective-C ...
# Anyway if you really want it, here we go.

#
# The name of the tools is in the JAVA_TOOL_NAME variable.
# The main class (the one implementing main) is in the
# xxx_PRINCIPAL_CLASS variable.
#

# prevent multiple inclusions
ifeq ($(INSTANCE_JAVA_TOOL_MAKE_LOADED),)
INSTANCE_JAVA_TOOL_MAKE_LOADED = yes

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

.PHONY: internal-java_tool-all \
        internal-java_tool-clean \
        internal-java_tool-distclean \
        internal-java_tool-install \
        internal-java_tool-uninstall \
        before-$(GNUSTEP_INSTANCE)-all \
        after-$(GNUSTEP_INSTANCE)-all \
        internal-install-java_tool-dirs \
        install-java_tool \
        _FORCE

# This is the directory where the tools get installed. If you don't specify a
# directory they will get installed in $(GNUSTEP_LOCAL_ROOT)/Tools/Java/.
ifeq ($(JAVA_TOOL_INSTALLATION_DIR),)
  JAVA_TOOL_INSTALLATION_DIR = $(GNUSTEP_TOOLS)/Java/
endif

internal-java_tool-all:: before-$(GNUSTEP_INSTANCE)-all \
                         $(JAVA_OBJ_FILES)    \
                         after-$(GNUSTEP_INSTANCE)-all

before-$(GNUSTEP_INSTANCE)-all::

after-$(GNUSTEP_INSTANCE)-all::

internal-java_tool-install:: install-java_tool

$(JAVA_TOOL_INSTALLATION_DIR):
	$(MKINSTALLDIRS) $(JAVA_TOOL_INSTALLATION_DIR)

internal-install-java_tool-dirs:: $(JAVA_TOOL_INSTALLATION_DIR)
ifneq ($(JAVA_OBJ_FILES),)
	$(MKINSTALLDIRS) $(addprefix $(JAVA_TOOL_INSTALLATION_DIR)/,$(dir $(JAVA_OBJ_FILES)));
endif

ifeq ($(PRINCIPAL_CLASS),)
  $(warning You must specify PRINCIPAL_CLASS)
  # But then, we are good, and try guessing
  PRINCIPAL_CLASS = $(word 1 $(JAVA_OBJ_FILES))
endif

# Remove an eventual extension (.class or .java) from PRINCIPAL_CLASS;
# only take the first word of it
NORMALIZED_PRINCIPAL_CLASS = $(basename $(word 1 $(PRINCIPAL_CLASS)))

# Escape '/' so it can be passes to sed
ESCAPED_PRINCIPAL_CLASS = $(subst /,\/,$(PRINCIPAL_CLASS))

# Always rebuild this because if the PRINCIPAL_CLASS changes...
$(GNUSTEP_INSTALLATION_DIR)/Tools/$(GNUSTEP_INSTANCE): _FORCE
	sed -e 's/JAVA_OBJ_FILE/$(ESCAPED_PRINCIPAL_CLASS)/g' \
	    $(GNUSTEP_MAKEFILES)/java-executable.template \
	    > $(GNUSTEP_INSTALLATION_DIR)/Tools/$(GNUSTEP_INSTANCE); \
	chmod a+x $(GNUSTEP_INSTALLATION_DIR)/Tools/$(GNUSTEP_INSTANCE);
ifneq ($(CHOWN_TO),)
	$(CHOWN) $(CHOWN_TO) \
	         $(GNUSTEP_INSTALLATION_DIR)/Tools/$(GNUSTEP_INSTANCE)
endif

_FORCE::

# See java.make for comments on ADDITIONAL_JAVA_OBJ_FILES
UNESCAPED_ADD_JAVA_OBJ_FILES = $(wildcard $(JAVA_OBJ_FILES:.class=[$$]*.class))
ADDITIONAL_JAVA_OBJ_FILES = $(subst $$,\$$,$(UNESCAPED_ADD_JAVA_OBJ_FILES))

JAVA_PROPERTIES_FILES = $($(GNUSTEP_INSTANCE)_JAVA_PROPERTIES_FILES)

install-java_tool:: internal-install-java_tool-dirs \
                   $(GNUSTEP_INSTALLATION_DIR)/Tools/$(GNUSTEP_INSTANCE)
ifneq ($(strip $(JAVA_OBJ_FILES)),)
	for file in $(JAVA_OBJ_FILES); do \
	  $(INSTALL_DATA) $$file $(JAVA_TOOL_INSTALLATION_DIR)/$$file ; \
	done;
endif
ifneq ($(strip $(ADDITIONAL_JAVA_OBJ_FILES)),)
	for file in $(ADDITIONAL_JAVA_OBJ_FILES); do \
	  $(INSTALL_DATA) $$file $(JAVA_TOOL_INSTALLATION_DIR)/$$file ; \
	done;
endif
ifneq ($(JAVA_PROPERTIES_FILES),)
	for file in $(JAVA_PROPERTIES_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $$file $(JAVA_INSTALLATION_DIR)/$$file ; \
	  fi;    \
	done
endif

# Warning - to uninstall nested classes you need to have a compiled 
# source available ...
internal-java_tool-uninstall::
	rm -f $(JAVA_TOOL_INSTALLATION_DIR)/$(JAVA_OBJ_FILES)
	rm -f $(JAVA_TOOL_INSTALLATION_DIR)/$(ADDITIONAL_JAVA_OBJ_FILES)
	rm -f $(GNUSTEP_INSTALLATION_DIR)/Tools/$(GNUSTEP_INSTANCE)

#
# Cleaning targets
#
internal-java_tool-clean::
	rm -f $(JAVA_OBJ_FILES) $(ADDITIONAL_JAVA_OBJ_FILES)

internal-java_tool-distclean::


endif # Instance/java_tool.make loaded

## Local variables:
## mode: makefile
## End: