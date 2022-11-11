#include "ampl/ampl.h"

#include <iostream>

int main(int argc, char **argv) {
  try {
    // Create an AMPL instance
    ampl::AMPL ampl;

    /*
    // If the AMPL installation directory is not in the system search path:
    ampl::Environment env("full path to the AMPL installation directory");
    ampl::AMPL ampl(env);
    */

    if (argc > 1)
      ampl.setOption("solver", argv[1]);

    // Read the model and data files.
    std::string modelDirectory = argc == 3 ? argv[2] : "../models";
    ampl.read(modelDirectory + "/diet/diet.mod");
    ampl.readData(modelDirectory + "/diet/diet.dat");

    // Solve
    ampl.solve();

    // Get objective entity by AMPL name
    ampl::Objective totalcost = ampl.getObjective("Total_Cost");
    // Print it
    std::cout << "Objective is: " << totalcost.value() << std::endl;

    // Reassign data - specific instances
    ampl::Parameter cost = ampl.getParameter("cost");
    ampl::Tuple indices[] = {ampl::Tuple("BEEF"), ampl::Tuple("HAM")};
    double values[] = {5.01, 4.55};
    cost.setValues(indices, values, 2);
    std::cout << "Increased costs of beef and ham." << std::endl;

    // Resolve and display objective
    ampl.solve();
    std::cout << "New objective value: " << totalcost.value() << std::endl;

    // Reassign data - all instances
    double elements[8] = {3, 5, 5, 6, 1, 2, 5.01, 4.55};
    cost.setValues(elements, 8);
    std::cout << "Updated all costs." << std::endl;

    // Resolve and display objective
    ampl.solve();
    std::cout << "New objective value: " << totalcost.value() << std::endl;

    // Get the values of the variable Buy in a dataframe object
    ampl::Variable buy = ampl.getVariable("Buy");
    ampl::DataFrame df = buy.getValues();
    // Print them
    std::cout << df.toString() << std::endl;

    // Get the values of an expression into a DataFrame object
    ampl::DataFrame df2 = ampl.getData("{j in FOOD} 100*Buy[j]/Buy[j].ub");
    // Print them
    std::cout << df2.toString() << std::endl;
    return 0;
  } catch (const std::exception &e) {
    std::cout << e.what() << "\n";
    return 1;
  }
}
