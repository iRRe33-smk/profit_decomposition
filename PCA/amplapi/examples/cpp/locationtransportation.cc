#include  "ampl/ampl.h"

#include <vector>
#include <cstdio>       // std::printf

int main(int argc, char **argv) {
  try {
    // Create an AMPL instance
    ampl::AMPL ampl;

    /*
    // If the AMPL installation directory is not in the system search path:
    ampl::Environment env("full path to the AMPL installation directory");
    ampl::AMPL ampl(env);
    */

    // Must be solved with a solver supporting the suffix dunbdd
    ampl.setOption("solver", "cplex");

    ampl.setBoolOption("presolve", false);
    ampl.setBoolOption("omit_zero_rows", true);

    // Read the model.
    std::string modelDirectory = argc == 2 ? argv[1] : "../models";
    modelDirectory += "/locationtransportation";
    ampl.read(modelDirectory + "/trnloc2.mod");
    ampl.readData(modelDirectory + "/trnloc.dat");

    // Get references to AMPL's model entities for easy access.
    ampl::Objective shipCost = ampl.getObjective("Ship_Cost");
    ampl::Variable maxShipCost = ampl.getVariable("Max_Ship_Cost");
    ampl::Variable buildVar = ampl.getVariable("Build");
    ampl::Constraint supply = ampl.getConstraint("Supply");
    ampl::Constraint demand = ampl.getConstraint("Demand");
    ampl::Parameter numCutParam = ampl.getParameter("nCUT");
    ampl::Parameter cutType = ampl.getParameter("cut_type");
    ampl::Parameter buildParam = ampl.getParameter("build");
    ampl::Parameter supplyPrice = ampl.getParameter("supply_price");
    ampl::Parameter demandPrice = ampl.getParameter("demand_price");

    numCutParam.set(0);
    maxShipCost.setValue(0);
    std::vector<double> initialBuild(ampl.getSet("ORIG").size(), 1);
    buildParam.setValues(&initialBuild[0], initialBuild.size());
    int numCuts;
    for (numCuts = 1; ; numCuts++) {
      std::printf("Iteration %d\n", numCuts);
      ampl.display("build");
      // Solve the subproblem.
      ampl.eval("solve Sub;");
      std::string result = shipCost.result();

      if (result.find("infeasible") != std::string::npos) {
        // Add a feasibility cut.
        numCutParam.set(numCuts);
        cutType.set(numCuts, "ray");
        ampl::DataFrame dunbdd = supply.getValues("dunbdd");

        ampl::DataFrame::iterator end = dunbdd.end();
        for (ampl::DataFrame::iterator it=dunbdd.begin(); it != end; ++it)
          supplyPrice.set(ampl::Tuple((*it)[0], numCuts), (*it)[1]);

        dunbdd = demand.getValues("dunbdd");
        end = dunbdd.end();
        for (ampl::DataFrame::iterator it = dunbdd.begin(); it != end; ++it)
          demandPrice.set(ampl::Tuple((*it)[0], numCuts), (*it)[1]);
      }
      else if (shipCost.value() > maxShipCost.value() + 0.00001) {
        // Add an optimality cut.
        numCutParam.set(numCuts);
        cutType.set(numCuts, "point");
        ampl.setIntOption("display_1col", 0);
        ampl.display("Ship");
        ampl::DataFrame duals = supply.getValues();

        ampl::DataFrame::iterator end = duals.end();
        for (ampl::DataFrame::iterator it = duals.begin(); it != end; ++it)
          supplyPrice.set(ampl::Tuple((*it)[0], numCuts), (*it)[1]);
        duals = demand.getValues();
        end = duals.end();
        for (ampl::DataFrame::iterator it = duals.begin(); it != end; ++it)
          demandPrice.set(ampl::Tuple((*it)[0], numCuts), (*it)[1]);
      }
      else break;

      // Re-solve the master problem.
      std::printf("RE-SOLVING MASTER PROBLEM");
      ampl.eval("solve Master;");
      // Copy the data from the Build variable used in the master problem
      // to the build parameter used in the subproblem.
      buildParam.setValues(buildVar.getValues());
    }
    std::printf("Procedure completed in %i iterations\n\n", numCuts);
    ampl.display("Ship");
    return 0;
  } catch (const std::exception &ex) {
    std::printf("%s\n", ex.what());
    return 1;
  }
}
