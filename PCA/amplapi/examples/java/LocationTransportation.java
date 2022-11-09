import java.io.IOException;
import java.util.Arrays;

import com.ampl.AMPL;
import com.ampl.Constraint;
import com.ampl.DataFrame;
import com.ampl.Objective;
import com.ampl.Parameter;
import com.ampl.Tuple;
import com.ampl.Variable;
import com.ampl.Environment;

/**
 * This example implements a simple iterative procedure in AMPL.
 * The first argument, if present, is interpreted as the name of the solver
 * to be used (for this example the chosen solver should support the suffix dunbdd).
 * The second argument, if present, should point to the  models directory.
 */
public class LocationTransportation {
  public static void main(String[] args) throws IOException {

    // Create an AMPL instance
    AMPL ampl = new AMPL();

    /*
    // If the AMPL installation directory is not in the system search path:
    Environment env = new Environment(
        "full path to the AMPL installation directory");
    AMPL ampl = new AMPL(env);
    */

    try {
      ampl.setOption("solver", "cplex"); // Use cplex by default: solver must support the suffix dunbdd
      if (args.length > 0)
        if (!args[0].equals("NA"))
          ampl.setOption("solver", args[0]);

      // Use the provided path or the default one
      String baseDir = args.length > 1 ? args[1] : "../models";
      String modelDirectory = baseDir + "/locationtransportation";

      ampl.setBoolOption("presolve", false);
      ampl.setBoolOption("omit_zero_rows", true);

      // Read the model.
      ampl.read(modelDirectory + "/trnloc2.mod");
      ampl.readData(modelDirectory + "/trnloc.dat"); // TODO: set data
                                                     // programmatically
      // Get references to AMPL's model entities for easy access.
      Objective shipCost = ampl.getObjective("Ship_Cost");
      Variable maxShipCost = ampl.getVariable("Max_Ship_Cost");
      Variable buildVar = ampl.getVariable("Build");
      Constraint supply = ampl.getConstraint("Supply");
      Constraint demand = ampl.getConstraint("Demand");
      Parameter numCutParam = ampl.getParameter("nCUT");
      Parameter cutType = ampl.getParameter("cut_type");
      Parameter buildParam = ampl.getParameter("build");
      Parameter supplyPrice = ampl.getParameter("supply_price");
      Parameter demandPrice = ampl.getParameter("demand_price");

      numCutParam.set(0);
      maxShipCost.setValue(0);
      double[] initialBuild = new double[ampl.getSet("ORIG").size()];
      Arrays.fill(initialBuild, 1);
      buildParam.setValues(initialBuild);
      int numCuts;
      for (numCuts = 1;; numCuts++) {
        System.out.format("Iteration %d%n", numCuts);
        ampl.display("build");
        // Solve the subproblem.
        ampl.eval("solve Sub;");
        String result = shipCost.result();

        if (result.equals("infeasible")) {
          // Add a feasibility cut.
          numCutParam.set(numCuts);
          cutType.set(numCuts, "ray");
          DataFrame dunbdd = supply.getValues("dunbdd");
          for (Object[] row : dunbdd)
            supplyPrice.set(new Tuple(row[0], numCuts), (Double) row[1]);
          dunbdd = demand.getValues("dunbdd");
          for (Object[] row : dunbdd)
            demandPrice.set(new Tuple(row[0], numCuts), (Double) row[1]);
        } else if (shipCost.value() > maxShipCost.value() + 0.00001) {
          // Add an optimality cut.
          numCutParam.set(numCuts);
          cutType.set(new Tuple(numCuts), "point");
          ampl.display("Ship");
          DataFrame duals = supply.getValues();
          for (Object[] row : duals)
            supplyPrice.set(new Tuple(row[0], numCuts), (Double) row[1]);
          duals = demand.getValues();
          for (Object[] row : duals)
            demandPrice.set(new Tuple(row[0], numCuts), (Double) row[1]);
        } else
          break;

        // Re-solve the master problem.
        System.out.println("RE-SOLVING MASTER PROBLEM");
        ampl.eval("solve Master;");

        // Copy the data from the Build variable used in the master problem
        // to the build parameter used in the subproblem.
        DataFrame data = buildVar.getValues();
        buildParam.setValues(data);
      }

      ampl.display("Ship");
    } finally {
      ampl.close();
    }
  }
}
