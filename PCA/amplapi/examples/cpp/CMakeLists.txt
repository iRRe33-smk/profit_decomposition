cmake_minimum_required(VERSION 3.0)
project(EXAMPLES)

if (NOT TARGET ampl)
  # Add library name
  include(ampl_version.cmake)
  # Check for C++11 support.
  include(cxx11.cmake)
  # Create an imported ampl target.
  set(AMPLAPI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../..)
  set(CMAKE_INSTALL_RPATH ${AMPLAPI_DIR}/lib)
  set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
  add_library(ampl STATIC IMPORTED)
  find_library(AMPL_LIBRARY ${AMPL_LIBRARY_NAME} PATHS ${CMAKE_INSTALL_RPATH})
  if(NOT(AMPL_LIBRARY))
	message(FATAL_ERROR "AMPL library \"${AMPL_LIBRARY_NAME}\" could not be found")
  endif()
  set_target_properties(ampl PROPERTIES
    IMPORTED_LOCATION ${AMPL_LIBRARY}
    INTERFACE_INCLUDE_DIRECTORIES ${AMPLAPI_DIR}/include)
endif ()

function(copy_library example)
set(DLL_FILE_NAME ${AMPLAPI_DIR}/bin/${AMPL_LIBRARY_NAME}.dll)
  ADD_CUSTOM_COMMAND(TARGET ${example}
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${DLL_FILE_NAME} ${CMAKE_CURRENT_SOURCE_DIR}/.
  )
endfunction ()

include(CMakeParseArguments)

# Usage: add_examples(name... [REQUIRE VAR])
# For each passed ${name} add an executable built from the source ${name}.cc.
# If REQUIRE is specified, the example is only added when ${VAR} is true.
function (add_examples)
  cmake_parse_arguments(add_examples "" "REQUIRE" "" ${ARGN})
  foreach (example ${add_examples_UNPARSED_ARGUMENTS})
    install(FILES ${example}.cc DESTINATION examples/cpp)
    set(enabled TRUE)
    if (add_examples_REQUIRE)
      set(enabled ${${add_examples_REQUIRE}})
    endif ()
    if (enabled)
      add_executable(${example} ${example}.cc)
      target_compile_options(${example} PRIVATE ${CXX11_FLAG})
      target_link_libraries(${example} ampl)
	  # Copy the runtime library to the project directory if compiling with 
	  # Visual Studio
	  if (MSVC AND AMPL_LIBRARY_NAME)
        copy_library(${example})
	  endif()
    else ()
      message(WARNING
              "Example ${example} disabled: ${add_examples_REQUIRE} not set")
    endif ()
  endforeach ()
endfunction ()


add_examples(dataframeexample dietmodel efficientfrontier firstexample
             multidimensionalexample optionsexample locationtransportation)
add_examples(asyncexample REQUIRE HAVE_CXX11_THREADS)
add_examples(trackingmodel REQUIRE HAVE_RANGE_FOR)
