# locate all cephes subfolders to process
FILE(GLOB src
    "bessel/*.c"
    "cmath/*.c"
    "cprob/*.c"
    "misc/*.c"
    "ellf/*.c"
    "polyn/*.c"
    "torch_mtherr.c"
    )
# note: single/ is not compiled because it conflicts
# with many functions in cmath and cprob :(

# use our custom mtherr instead of cmath/mtherr.c
LIST(REMOVE_ITEM src
    "${CMAKE_CURRENT_SOURCE_DIR}/cmath/mtherr.c"
    )


# ignore files which have a main() 
LIST(REMOVE_ITEM src
    "${CMAKE_CURRENT_SOURCE_DIR}/cmath/mtst.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/cmath/dtestvec.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/cmath/mod2pi.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/ellf/ellf.c")

# ignore files who are exact duplicates of cmath
LIST(REMOVE_ITEM src
    "${CMAKE_CURRENT_SOURCE_DIR}/cprob/drand.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/cprob/const.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/cprob/mtherr.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/cprob/polevl.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/cprob/unity.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/misc/chbevl.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/misc/mtherr.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/misc/polevl.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/ellf/cmplx.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/ellf/const.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/ellf/mtherr.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/ellf/polevl.c"
    )

# ignore files in misc who are exact duplicates of any other
LIST(REMOVE_ITEM src
    "${CMAKE_CURRENT_SOURCE_DIR}/misc/psi.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/misc/revers.c"
    )

# ignore rational polynomials of polyr.c,
# because it conflict with the simpler polynomials of polyn.c
LIST(REMOVE_ITEM src
    "${CMAKE_CURRENT_SOURCE_DIR}/polyn/polyr.c"
    )

# install the lua code for the cephes package
FILE(GLOB luasrc "luasrc/*.lua")
# TODO: install the tests, too
# ADD_SUBDIRECTORY(tests)

ADD_TORCH_WRAP(cepheswrap cepheswrap.lua)


ADD_LIBRARY(tcephes SHARED cepheswrap.c "${src}")
target_include_directories(tcephes PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
set_target_properties(tcephes PROPERTIES PREFIX "")
SET_TARGET_PROPERTIES(tcephes PROPERTIES
  IMPORT_PREFIX "lib")
IF(APPLE)
  SET_TARGET_PROPERTIES(tcephes PROPERTIES
    LINK_FLAGS "-undefined dynamic_lookup")
ENDIF()
SET_TARGET_PROPERTIES(tcephes PROPERTIES
    DEFINE_SYMBOL "CEPHES_EXPORTS")
IF(LUALIB)
  TARGET_LINK_LIBRARIES(tcephes ${LUALIB} luaT)
ENDIF()

INSTALL(FILES ${luasrc} DESTINATION ${LUADIR}/cephes)
INSTALL(TARGETS tcephes
  LIBRARY DESTINATION ${LIBDIR}
  RUNTIME DESTINATION ${LUA_BINDIR})

