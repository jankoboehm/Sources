ACLOCAL_AMFLAGS = -I ../../m4

MYINCLUDES = -I${top_srcdir} -I${top_builddir} \
-I${top_srcdir}/libpolys -I${top_builddir}/libpolys \
$(FACTORY_INCLUDES) $(RESOURCES_INCLUDES) $(OMALLOC_INCLUDES) \
$(FLINT_CFLAGS) $(NTL_CXXFLAGS) ${NTL_CPPFLAGS} $(GMP_CPPFLAGS)

if SI_BUILTIN_SYZWALK
  noinst_LTLIBRARIES=syzwalk.la
  P_PROCS_CPPFLAGS_COMMON = -DSTATIC_VERSION
  P_PROCS_MODULE_LDFLAGS = -module
else
  module_LTLIBRARIES=syzwalk.la
  moduledir = $(libdir)/singular/MOD
  P_PROCS_CPPFLAGS_COMMON = -DDYNAMIC_VERSION
  P_PROCS_MODULE_LDFLAGS = -module -export-dynamic -avoid-version
endif

syzwalk_la_SOURCES = mod_main.cc
syzwalk_la_CPPFLAGS = ${MYINCLUDES} ${P_PROCS_CPPFLAGS_COMMON}
syzwalk_la_LDFLAGS = ${AM_LDFLAGS} ${P_PROCS_MODULE_LDFLAGS} $(SINGULAR_LDFLAGS)

if SING_WIN
if !SI_BUILTIN_SYZWALK
syzwalk_la_LIBADD = ${top_builddir}/Singular/libSingular.la
endif
endif

AM_COLOR_TESTS=always
TESTS_ENVIRONMENT = SINGULARPATH='${abs_top_builddir}/Singular/LIB:${abs_top_srcdir}/Singular/LIB:${abs_top_builddir}/libpolys/polys/.libs:${abs_top_builddir}/factory/gftables:${abs_top_builddir}/Singular/dyn_modules/gfanlib/.libs:${abs_builddir}/.libs:${abs_srcdir}'
TESTS_ENVIRONMENT += SINGULAR_ROOT_DIR='${abs_top_builddir}'
TESTS_ENVIRONMENT += SINGULAR_BIN_DIR='${abs_top_builddir}/Singular'
TESTS=test_release.sh

EXTRA_DIST = syzwalk.tst syzwalk.res test.sh test_release.sh \
  dp_block_benchmark.sing
