GNUCAP_CONF = $(shell which gnucap-conf$(SUFFIX))

include Make2

ifneq ($(GNUCAP_CONF),)
    CXX = $(shell $(GNUCAP_CONF) --cxx)
    GNUCAP_CPPFLAGS = $(shell $(GNUCAP_CONF) --cppflags) -DADD_VERSION
    GNUCAP_CXXFLAGS = $(shell $(GNUCAP_CONF) --cxxflags)
	 GNUCAP_LIBDIR   = $(shell $(GNUCAP_CONF) --libdir)
	 GNUCAP_EXECPREFIX=$(shell $(GNUCAP_CONF) --exec-prefix)
else
    $(info no gnucap-conf, this might not work)
    CXX = g++
    GNUCAP_CXXFLAGS = \
        -g -O0 \
        -Wall -Wextra \
        -Wswitch-enum -Wundef -Wpointer-arith -Woverloaded-virtual \
        -Wcast-qual -Wcast-align -Wpacked -Wshadow -Wconversion \
        -Winit-self -Wmissing-include-dirs -Winvalid-pch \
        -Wvolatile-register-var -Wstack-protector \
        -Wlogical-op -Wvla -Woverlength-strings -Wsign-conversion
    GNUCAP_CPPFLAGS = \
        -DHAVE_LIBREADLINE \
        -DUNIX \
        -DTRACE_UNTESTED
	 GNUCAP_LIBDIR=/usr/share/gnucap
endif

GNUCAP_CXXFLAGS+= -fPIC -shared

# QUCS_DEVS = opamp cccs
QUCS_DEVS_SO = $(QUCS_DEVS:%=d_qucs_%.so)

# LDLIBS =

QUCS_PLUGINS = \
	$(QUCS_DEVS_SO) \
	lang_qucs.so \
	d_eqn.so \
	d_probe.so \
	functions.so \
	bm_value.so \
	bm_trivial.so \
	bm_wrapper.so \
	cmd_wrapper.so

CLEANFILES = $(QUCS_PLUGINS) *.o *~

all: $(QUCS_PLUGINS) gnucsator.sh

lang_qucs.so: l_qucs.h
cmd_wrapper.so: l_qucs.h

dbg:
	echo $(QUCS_DEVS_SO)

$(QUCS_DEVS_SO): d_qucs_%.so: qucs_wrapper.cc
	$(CXX) -std=c++11 $(CXXFLAGS) $(GNUCAP_CXXFLAGS) -DQUCS_DEVICE=$* \
		$(CPPFLAGS) $(QUCS_CPPFLAGS) $(GNUCAP_CPPFLAGS) -o $@ \
		$< $(QUCS_LDFLAGS) $(QUCS_LIBS) \
	$(LDLIBS)

%.so : %.cc
	$(CXX) $(CXXFLAGS) $(GNUCAP_CXXFLAGS) $(CPPFLAGS) $(GNUCAP_CPPFLAGS) -o $@ $< $(LDLIBS)

d_eqn.so: CXXFLAGS+=-std=c++11
cmd_wrapper.so: CXXFLAGS+=-std=c++11

QUCS_INCLUDEDIR = $(QUCS_PREFIX)/include
QUCS_CPPFLAGS = -I$(QUCS_INCLUDEDIR) -I$(QUCS_INCLUDEDIR)/qucs-core
QUCS_LDFLAGS = -L$(QUCS_PREFIX)/lib
QUCS_LIBS = -lqucs

install: $(QUCS_PLUGINS) gnucsator.sh
	install -d $(GNUCAP_LIBDIR)/qucs
	install $(QUCS_PLUGINS) $(GNUCAP_LIBDIR)/qucs
	install gnucsator.sh $(GNUCAP_EXECPREFIX)/bin

uninstall:
	(cd $(GNUCAP_LIBDIR)/qucs ; rm $(QUCS_PLUGINS))

clean :
	rm -f $(CLEANFILES)

distclean: clean
	rm Make.override

define NOTICE
#THIS FILE IS AUTOMATICALLY GENERATED
endef

gnucsator.sh: gnucsator.sh.in Makefile
	sed -e 's/@SUFFIX@/$(SUFFIX)/' \
	    -e 's#@GNUCAP_LIBDIR@#$(GNUCAP_LIBDIR)#' \
	    -e 's/@NOTICE@/$(NOTICE)/' < $< > $@
	chmod +x $@

Make2:
	[ -e $@ ] || echo "# here you may override settings" > $@

check:
	$(MAKE) -C tests
