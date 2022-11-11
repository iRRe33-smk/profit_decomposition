using ampl;
using ampl.Entities;
using System;
using System.Linq;

namespace Examples
{
  public class EfficientFrontier
  {
    public static int Main(string[] args)
    {
      string modelDirectory = ((args != null) && (args.Length > 0)) ? args[0]
            : "../../models";
      modelDirectory += "/qpmv";
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
        // Number of steps of the efficient frontier
        const int steps = 10;
        if (solver != null) ampl.SetOption("solver", solver);
        ampl.SetOption("reset_initial_guesses", true);
        ampl.SetOption("send_statuses", false);
        ampl.SetOption("Solver", "cplex");

        // Load the AMPL model from file
        ampl.Read(modelDirectory + "/qpmv.mod");
        ampl.Read(modelDirectory + "/qpmvbit.run");

        // set tables directory (parameter used in the script above)
        ampl.GetParameter("data_dir").Set(modelDirectory);
        // Read tables
        ampl.ReadTable("assetstable");
        ampl.ReadTable("astrets");

        Variable portfolioReturn = ampl.GetVariable("portret");
        Parameter averageReturn = ampl.GetParameter("averret");
        Parameter targetReturn = ampl.GetParameter("targetret");
        Objective variance = ampl.GetObjective("cst");

        // Relax the integrality
        ampl.SetOption("relax_integrality", true);
        // Solve the problem
        ampl.Solve();
        // Calibrate the efficient frontier range
        double minret = portfolioReturn.Value;
        DataFrame values = averageReturn.GetValues();
        DataFrame.Column col = values.GetColumn("averret");

        double maxret = col.Max().Dbl;
        double stepsize = (maxret - minret) / steps;
        double[] returns = new double[steps];
        double[] variances = new double[steps];

        for (int i = 0; i < steps; i++)
        {
          Console.WriteLine(string.Format("Solving for return = {0}",
            maxret - (i - 1) * stepsize));
          // set target return to the desired point
          targetReturn.Set(maxret - (i - 1) * stepsize);
          ampl.Eval("let stockopall:={};let stockrun:=stockall;");
          // Relax integrality
          ampl.SetOption("relax_integrality", true);
          ampl.Solve();
          Console.WriteLine(string.Format("QP result = {0}",
            variance.Value));
          // Adjust included stocks
          ampl.Eval("let stockrun:={i in stockrun:weights[i]>0};");
          ampl.Eval("let stockopall:={i in stockrun:weights[i]>0.5};");
          // set integrality back
          ampl.SetOption("relax_integrality", false);
          ampl.Solve();
          Console.WriteLine(string.Format("QMIP result = {0}",
            variance.Value));
          // Store data of corrent frontier point
          returns[i] = maxret - (i - 1) * stepsize;
          variances[i] = variance.Value;
        }

        // Display efficient frontier points
        Console.WriteLine("    RETURN    VARIANCE");
        for (int i = 0; i < steps; i++)
          Console.WriteLine(string.Format("{0,10:0.00000}  {1,10:0.00000}", returns[i], variances[i]));
      }
      return 0;
    }
  }
}
