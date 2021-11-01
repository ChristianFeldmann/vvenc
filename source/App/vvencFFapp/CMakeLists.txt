# executable
set( EXE_NAME vvencFFapp )

# get source files
file( GLOB SRC_FILES "*.cpp" )

# get include files
file( GLOB INC_FILES "*.h" )

# get address sanitizer libs for gcc
if( CMAKE_CXX_COMPILER_ID STREQUAL "GNU" )
  if( VVENC_USE_ADDRESS_SANITIZER )
    set( ADDITIONAL_LIBS asan )
  endif()
endif()

# set resource file for MSVC compilers
if( MSVC )
  set( RESOURCE_FILE ${EXE_NAME}.rc )
  file( GLOB NATVIS_FILES "../../VisualStudio/*.natvis" )
  # extend the stack size on windows to 2MB
  set( CMAKE_EXE_LINKER_FLAGS  "${CMAKE_EXE_LINKER_FLAGS} /STACK:0x200000" )
endif()

# add executable
add_executable( ${EXE_NAME} ${SRC_FILES} ${INC_FILES} ${RESOURCE_FILE} )
set_target_properties( ${EXE_NAME} PROPERTIES RELEASE_POSTFIX        "${CMAKE_RELEASE_POSTFIX}" )
set_target_properties( ${EXE_NAME} PROPERTIES DEBUG_POSTFIX          "${CMAKE_DEBUG_POSTFIX}" )
set_target_properties( ${EXE_NAME} PROPERTIES RELWITHDEBINFO_POSTFIX "${CMAKE_RELWITHDEBINFO_POSTFIX}" )
set_target_properties( ${EXE_NAME} PROPERTIES MINSIZEREL_POSTFIX     "${CMAKE_MINSIZEREL_POSTFIX}" )

target_compile_options( ${EXE_NAME} PRIVATE $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>>:-Wall -Werror>
                                            $<$<CXX_COMPILER_ID:GNU>:-Wall -Werror -fdiagnostics-show-option>
                                            $<$<CXX_COMPILER_ID:MSVC>:/W4 /WX /wd4100 /wd4244 /wd4251 /wd4459 /wd4996>)

target_link_libraries( ${EXE_NAME} Threads::Threads vvenc apputils )

# example: place header files in different folders
source_group( "Header Files"   FILES ${INC_FILES} )
source_group( "Resource Files" FILES ${RESOURCE_FILE} )
source_group( "Natvis Files"   FILES ${NATVIS_FILES} )

# set the folder where to place the projects
set_target_properties( ${EXE_NAME}  PROPERTIES FOLDER app )

if( VVENC_ENABLE_INSTALL )
  # set destination directories
  set( RUNTIME_DEST ${CMAKE_INSTALL_BINDIR} )
  set( LIBRARY_DEST ${CMAKE_INSTALL_LIBDIR} )
  set( ARCHIVE_DEST ${CMAKE_INSTALL_LIBDIR} )

  # install targets
  macro( install_targets config_ )
    string( TOLOWER ${config_} config_lc_ )
    install( TARGETS            vvencFFapp
            EXPORT              vvencTargets-${config_lc_} 
            CONFIGURATIONS      ${config_}
            RUNTIME DESTINATION ${RUNTIME_DEST}
            LIBRARY DESTINATION ${LIBRARY_DEST}
            ARCHIVE DESTINATION ${ARCHIVE_DEST} )
  endmacro( install_targets )

  install_targets( Release )
  install_targets( Debug )
  install_targets( RelWithDebInfo )
endif()
