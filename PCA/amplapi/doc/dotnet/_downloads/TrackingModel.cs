using ampl;
using ampl.Entities;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Examples
{
  public class TrackingModel
  {
    /// <summary>
    /// This example shows a simple AMPL iterative procedure implemented in AMPL
    /// </summary>
    /// <param name="args">
    /// </param>
    public static int Main(string[] args)
    {
      string modelDirectory = ((args != null) && (args.Length > 0)) ? args[0]
            : "../../models";
      string solver = ((args != null) && (args.Length > 1)) ? args[1] : null;

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
        if (solver != null) ampl.SetOption("solver", solver);
        modelDirectory += "/tracking";

        // Load the AMPL model from file
        ampl.Read(modelDirectory + "/tracking.mod");
        // Read data
        ampl.ReadData(modelDirectory + "/tracking.dat");
        // Read table declarations
        ampl.Read(modelDirectory + "/trackingbit.run");
        // set tables directory (parameter used in the script above)
        ampl.GetParameter("data_dir").Set(modelDirectory);
        // Read tables
        ampl.ReadTable("assets");
        ampl.ReadTable("indret");
        ampl.ReadTable("returns");

        var hold = ampl.GetVariable("hold");
        Parameter ifinuniverse = ampl.GetParameter("ifinuniverse");

        // Relax the integrality
        ampl.SetOption("relax_integrality", true);
        // Solve the problem
        ampl.Solve();
        Console.Write("QP objective value {0}\n",
          ampl.GetObjectives().First().Value);

        double lowcutoff = 0.04;
        double highcutoff = 0.1;

        // Get the variable representing the (relaxed) solution vector
        DataFrame holdvalues = hold.GetValues();
        List<double> toHold = new List<double>(holdvalues.NumRows);
        // For each asset, if it was held by more than the highcutoff, forces it in the model, if
        // less than lowcutoff, forces it out
        foreach (var value in holdvalues.GetColumn("hold"))
        {
          if (value.Dbl < lowcutoff)
            toHold.Add(0);
          else if (value.Dbl > highcutoff)
            toHold.Add(2);
          else
            toHold.Add(1);
        }
        // uses those values for the parameter ifinuniverse, which controls which stock is included
        // or not in the solution
        ifinuniverse.SetValues(toHold.ToArray());

        // Get back to the integer problem
        ampl.SetOption("relax_integrality", false);
        // Solve the (integer) problem
        ampl.Solve();
        Console.Write("QMIP objective value {0}\n",
        ampl.GetObjectives().First().Value);
      }
      return 0;
    }
  }
}
