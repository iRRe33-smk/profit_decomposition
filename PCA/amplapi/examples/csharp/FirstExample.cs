using ampl;
using ampl.Entities;
using System;

namespace Examples
{
  public class FirstExample
  {
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
      using (AMPL a = new AMPL())
      {
        if (solver != null) a.SetOption("solver", solver);
        // Interpret the two files
        a.Read(System.IO.Path.Combine(modelDirectory, "diet/diet.mod"));
        a.ReadData(System.IO.Path.Combine(modelDirectory, "diet/diet.dat"));

        // Solve
        a.Solve();

        // Get objective entity by AMPL name
        Objective totalcost = a.GetObjective("Total_Cost");
        // Print it
        Console.WriteLine("ObjectiveInstance is: {0}", totalcost.Value);
        // Reassign data - specific instances
        Parameter cost = a.GetParameter("cost");
        cost.SetValues(ampl.Tuple.FromArray("BEEF", "HAM"),
                            new double[] { 5.01, 4.55 });
        Console.WriteLine("Increased costs of beef and ham.");

        // ReSolve and display objective
        a.Solve();
        Console.WriteLine("Objective value: {0}", totalcost.Value);

        // Reassign data - all instances
        cost.SetValues(new double[] { 3, 5, 5, 6, 1, 2, 5.01, 4.55 });
        Console.WriteLine("Updated all costs");
        // ReSolve and display objective
        a.Solve();
        Console.WriteLine("New objective value: {0}", totalcost.Value);

        // Get the values of the variable Buy in a dataframe object
        Variable Buy = a.GetVariable("Buy");
        // Access a specific instance (method 1)
        Console.WriteLine(Buy.Get("FISH").ToString());
        // Access a specific instance (method 2)
        Console.WriteLine(Buy[new ampl.Tuple("FISH")].ToString());
        DataFrame df = Buy.GetValues();
        // Print them
        Console.WriteLine(df);

        // Get the values of an expression into a DataFrame object
        DataFrame df2 = a.GetData("{j in FOOD} 100*Buy[j]/Buy[j].ub");
        // Print them
        Console.WriteLine(df2);
      }
      return 0;
    }
  }
}
