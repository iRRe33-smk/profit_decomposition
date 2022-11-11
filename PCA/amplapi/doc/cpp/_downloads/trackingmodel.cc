#include "ampl/ampl.h"

#include <vector>
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

    std::string modelDirectory(argc == 3 ? argv[2] : "../models");
    modelDirectory += "/tracking";

    // Load the AMPL model from file
    ampl.read(modelDirectory + "/tracking.mod");
    // Read data
    ampl.readData(modelDirectory + "/tracking.dat");
    // Read table declarations
    ampl.read(modelDirectory + "/trackingbit.run");
    // Set tables directory (parameter used in the script above)
    ampl.getParameter("data_dir").set(modelDirectory);
    // Read tables
    ampl.readTable("assets");
    ampl.readTable("indret");
    ampl.readTable("returns");

    ampl::Variable hold = ampl.getVariable("hold");
    ampl::Parameter ifinuniverse = ampl.getParameter("ifinuniverse");

    // Relax the integrality
    ampl.setBoolOption("relax_integrality", true);
    // Solve the problem
    ampl.solve();
    std::cout << "QP objective value " << ampl.getObjectives().begin()->value() << "\n";

    double lowcutoff = 0.04;
    double highcutoff = 0.1;

    // Get the variable representing the (relaxed) solution vector
    ampl::DataFrame holdvalues = hold.getValues();
    std::vector<double> toHold;
    toHold.reserve(holdvalues.getNumRows());
    // For each asset, if it was held by more than the highcutoff,
    // forces it in the model, if less than lowcutoff, forces it out
    for (auto value : holdvalues.getColumn("hold"))
    {
      if (value.dbl() < lowcutoff)
        toHold.push_back(0);
      else if (value.dbl() > highcutoff)
        toHold.push_back(2);
      else
        toHold.push_back(1);
    }

    // uses those values for the parameter ifinuniverse, which controls
    // which
    // stock is included or not in the solution
    ifinuniverse.setValues(&toHold[0], toHold.size());

    // Get back to the integer problem
    ampl.setBoolOption("relax_integrality", false);
    // Solve the (integer) problem
    ampl.solve();
    std::cout << "QMIP objective value " <<
    ampl.getObjectives().begin()->value() << "\n";
    return 0;
  } catch (const std::exception &e) {
    std::cout << e.what() << "\n";
    return 1;
  }
}
