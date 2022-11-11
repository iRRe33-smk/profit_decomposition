#include "ampl/ampl.h"

#include <iostream>

int main() {
  try {
    // Create an AMPL instance
    ampl::AMPL ampl;

    /*
    // If the AMPL installation directory is not in the system search path:
    ampl::Environment env("full path to the AMPL installation directory");
    ampl::AMPL ampl(env);
    */

    // Get the value of the option presolve and print
    int presolve = *ampl.getIntOption("presolve");
    int s;
#ifdef FMT_GCC_VERSION
    s = FMT_GCC_VERSION;
#else
    s = -1;
#endif
    std::cout << "AMPL presolve is " << presolve << "\n";
    std::cout << "FMT_GCC_VERSION = " << s << "\n";
    // Set the value to false (maps to 0)
    ampl.setBoolOption("presolve", false);

    // Get the value of the option presolve and print
    presolve = *ampl.getIntOption("presolve");
    std::cout << "AMPL presolve is now " << presolve << "\n";

    // Check whether an option with a specified name
    // exists
    if (ampl::Optional<std::string> value =
      ampl.getOption("solver")) {
      std::cout << "Option solver exists and has value: "
        << *value << "\n";
    }
    // Check again, this time failing
    if (ampl::Optional<std::string> value =
      ampl.getOption("s_o_l_v_e_r")) {
      std::cout << "Option s_o_l_v_e_r does not exists!\n";
    }
    // Optional::value() throws exception if it has no value
    try {
      ampl.getOption("s_o_l_v_e_r").value();
    }
    catch (const std::exception &ex) {
      std::cout << "Option s_o_l_v_e_r does not exist" << std::endl;
      std::cout << ex.what() << std::endl;
    }
    return 0;
  } catch (const std::exception &e) {
    std::cout << e.what() << "\n";
    return 1;
  }
}
