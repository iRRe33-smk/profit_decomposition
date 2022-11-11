using ampl;
using ampl.Entities;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Examples
{
  public class LocationTransportation
  {
    /// <summary>
    /// This example shows a simple AMPL iterative procedure implemented in AMPL.
    /// Must be executed with a solver supporting the suffix dunbdd
    /// </summary>
    /// <param name="args">
    /// The first string, if present, should point to the models directory
    /// </param>
    public static int Main(string[] args)
    {
      string modelDirectory = ((args != null) && (args.Length > 0)) ? args[0]
         : "../../models";

      /*
      // If the AMPL installation directory is not in the system search path:
      ampl.Environment env = new ampl.Environment(
        "full path to the AMPL installation directory");
      // Create an AMPL instance
      using (AMPL a = new AMPL(env)) {}
      */

      // Create an AMPL instance
      using (AMPL ampl = new AMPL())
      {
        // Must be solved with a solver supporting the suffix dunbdd
        ampl.SetOption("solver", "cplex");

        modelDirectory += "/locationtransportation";
        ampl.SetOption("presolve", false);
        ampl.SetOption("omit_zero_rows", true);

        // Read the model.
        ampl.Read(modelDirectory + "/trnloc2.mod");
        ampl.ReadData(modelDirectory + "/trnloc.dat"); // TODO: set data
                                                       // programmatically

        // Get references to AMPL's model entities for easy access.
        Objective shipCost = ampl.GetObjective("Ship_Cost");
        Variable maxShipCost = ampl.GetVariable("Max_Ship_Cost");
        Variable buildVar = ampl.GetVariable("Build");
        Constraint supply = ampl.GetConstraint("Supply");
        Constraint demand = ampl.GetConstraint("Demand");
        Parameter numCutParam = ampl.GetParameter("nCUT");
        Parameter cutType = ampl.GetParameter("cut_type");
        Parameter buildParam = ampl.GetParameter("build");
        Parameter supplyPrice = ampl.GetParameter("supply_price");
        Parameter demandPrice = ampl.GetParameter("demand_price");

        numCutParam.Set(0);
        maxShipCost.Value = 0;
        double[] initialBuild = new double[ampl.GetSet("ORIG").Size];
        for (int i = 0; i < initialBuild.Length; i++)
          initialBuild[i] = 1;
        buildParam.SetValues(initialBuild);
        int numCuts;
        for (numCuts = 1; ; numCuts++)
        {
          Console.WriteLine("Iteration {0}", numCuts);
          ampl.Display("build");
          // Solve the subproblem.
          ampl.Eval("solve Sub;");
          string result = shipCost.Result;

          if (result.Equals("infeasible"))
          {
            // Add a feasibility cut.
            numCutParam.Set(numCuts);
            cutType.Set(new ampl.Tuple(numCuts), "ray");
            DataFrame dunbdd = supply.GetValues("dunbdd");
            foreach (var row in dunbdd)
              supplyPrice.Set(new ampl.Tuple(row[0], numCuts), row[1].Dbl);
            dunbdd = demand.GetValues("dunbdd");
            foreach (var row in dunbdd)
              demandPrice.Set(new ampl.Tuple(row[0], numCuts), row[1].Dbl);
          }
          else if (shipCost.Value > maxShipCost.Value + 0.00001)
          {
            // Add an optimality cut.
            numCutParam.Set(numCuts);
            cutType.Set(new ampl.Tuple(numCuts), "point");
            ampl.Display("Ship");
            DataFrame duals = supply.GetValues();
            foreach (var row in duals)
              supplyPrice.Set(new ampl.Tuple(row[0], numCuts), row[1].Dbl);
            duals = demand.GetValues();
            foreach (var row in duals)
              demandPrice.Set(new ampl.Tuple(row[0], numCuts), row[1].Dbl);
          }
          else
            break;

          // Re-solve the master problem.
          Console.WriteLine("RE-SOLVING MASTER PROBLEM");
          ampl.Eval("solve Master;");

          // Copy the data from the Build variable used in the master problem
          // to the build parameter used in the subproblem.
          DataFrame data = buildVar.GetValues();
          buildParam.SetValues(data);
        }
        ampl.Display("Ship");
      }
      return 0;
    }
  }
}