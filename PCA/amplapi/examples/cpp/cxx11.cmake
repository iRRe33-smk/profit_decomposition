# C++11 support

include(CheckCXXCompilerFlag)
check_cxx_compiler_flag(-std=c++11 HAVE_STD_CXX11_FLAG)
if (HAVE_STD_CXX11_FLAG)
  set(CXX11_FLAG -std=c++11)
else ()
  check_cxx_compiler_flag(-std=c++0x HAVE_STD_CXX0x_FLAG)
  if (HAVE_STD_CXX0x_FLAG)
    set(CXX11_FLAG -std=c++0x)
  endif ()
endif ()

set(CMAKE_REQUIRED_FLAGS "${CXX11_FLAG} ${CLANG_STDLIB}")
include(CheckCXXSourceCompiles)
check_cxx_source_compiles(
  "#include <thread>
  int main() { auto i = 42; }" HAVE_CXX11_THREADS)
check_cxx_source_compiles(
  "#include <vector>
  int main() { for (auto i: std::vector<int>()); }" HAVE_RANGE_FOR)
