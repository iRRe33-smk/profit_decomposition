using ampl;
using System;

namespace Examples
{
  /// <summary>
  /// Demonstrates how to assign all the data to a model
  /// </summary>
  public class DietModel
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
      using (var ampl = new AMPL())
      {
        if (solver != null) ampl.SetOption("solver", solver);
        // Read the model file
        ampl.Read(modelDirectory + "/diet/diet.mod");

        string[] foods = {"BEEF", "CHK", "FISH", "HAM",
          "MCH", "MTL", "SPG", "TUR" };
        double[] costs = { 3.59, 2.59, 2.29, 2.89, 1.89, 1.99, 1.99, 2.49 };
        double[] fmin = { 2, 2, 2, 2, 2, 2, 2, 2 };
        double[] fmax = { 10, 10, 10, 10, 10, 10, 10, 10 };

        DataFrame df = new DataFrame(1, "FOOD");
        df.SetColumn("FOOD", foods);
        df.AddColumn("cost", costs);
        df.AddColumn("f_min", fmin);
        df.AddColumn("f_max", fmax);
        ampl.SetData(df, "FOOD");

        string[] nutrients = { "A", "C", "B1", "B2", "NA", "CAL" };
        double[] nmin = { 700, 700, 700, 700, 0, 16000 };
        double[] nmax = { 20000, 20000, 20000, 20000, 50000, 24000 };
        df = new DataFrame(1, "NUTR");
        df.SetColumn("NUTR", nutrients);
        df.AddColumn("n_min", nmin);
        df.AddColumn("n_max", nmax);
        ampl.SetData(df, "NUTR");

        double[,] amounts = {
            {  60,    8,   8,  40,   15,  70,   25,   60 },
            {  20,    0,  10,  40,   35,  30,   50,   20 },
            {  10,   20,  15,  35,   15,  15,   25,   15 },
            {  15,   20,  10,  10,   15,  15,   15,   10 },
            { 928, 2180, 945, 278, 1182, 896, 1329, 1397 },
            { 295,  770, 440, 430,  315, 400,  379,  450 }
          };
        df = new DataFrame(2, "NUTR", "FOOD", "amt");
        df.SetMatrix(nutrients, foods, amounts);
        ampl.SetData(df);

        ampl.Solve();

        Console.WriteLine(string.Format("Objective: {0}",
          ampl.GetObjective("Total_Cost").Value));
      }
      return 0;
    }
  }
}
