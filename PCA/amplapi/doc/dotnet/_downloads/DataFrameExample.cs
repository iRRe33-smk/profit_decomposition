using ampl;
using System;

namespace Examples
{
  public class DataFrameExample
  {
    public static int Main(string[] args)
    {
      string modelDirectory = ((args != null) && (args.Length > 0)) ? args[0]
            : "../../models";
      string solver = ((args != null) && (args.Length > 1)) ? args[1] : null;
      // Create first dataframe (for data indexed over NUTR) Add data row by row
      DataFrame df1 = new DataFrame(1, "NUTR", "n_min", "n_max");
      df1.AddRow("A", 700, 20000);
      df1.AddRow("B1", 700, 20000);
      df1.AddRow("B2", 700, 20000);
      df1.AddRow("C", 700, 20000);
      df1.AddRow("CAL", 16000, 24000);
      df1.AddRow("NA", 0.0, 50000);

      // Create second dataframe (for data indexed over FOOD) Add column by column
      DataFrame df2 = new DataFrame(1, "FOOD");
      string[] foods = { "BEEF", "CHK", "FISH", "HAM",
    "MCH", "MTL", "SPG", "TUR" };
      df2.SetColumn("FOOD", foods);
      double[] contents = new double[8];
      for (int j = 0; j < 8; j++)
        contents[j] = 2;
      df2.AddColumn("f_min", contents);
      for (int j = 0; j < 8; j++)
        contents[j] = 10;
      df2.AddColumn("f_max", contents);
      double[] costs = { 3.19, 2.59, 2.29, 2.89, 1.89,
        1.99, 1.99, 2.49 };
      df2.AddColumn("cost", costs);

      // Create third dataframe, to assign data to the AMPL entity param amt{NUTR, FOOD};
      DataFrame df3 = new DataFrame(2, "NUTR", "FOOD");
      // Populate the set columns
      string[] nutrWithMultiplicity = new string[48];
      string[] foodWithMultiplicity = new string[48];
      int i = 0;
      for (int n = 0; n < 6; n++)
      {
        for (int f = 0; f < 8; f++)
        {
          nutrWithMultiplicity[i] = df1.GetRowByIndex(n)[0].Str;
          foodWithMultiplicity[i++] = foods[f];
        }
      }
      df3.SetColumn("NUTR", nutrWithMultiplicity);
      df3.SetColumn("FOOD", foodWithMultiplicity);

      // Populate with all these values
      double[] values = { 60, 8, 8, 40, 15, 70, 25, 60, 10, 20, 15,
        35, 15, 15, 25, 15, 15, 20, 10, 10, 15, 15, 15, 10, 20, 0, 10,
        40, 35, 30, 50, 20, 295, 770, 440, 430, 315, 400, 370, 450,
        968, 2180, 945, 278, 1182, 896, 1329, 1397 };
      df3.AddColumn("amt", values);

      // Create an AMPL instance
      using (AMPL ampl = new AMPL())
      {
        if (solver != null) ampl.SetOption("solver", solver);
        // Read model only
        ampl.Read(modelDirectory + "/diet/diet.mod");
        // Assign data to NUTR, n_min and n_max
        ampl.SetData(df1, "NUTR");
        // Assign data to FOOD, f_min, f_max and cost
        ampl.SetData(df2, "FOOD");
        // Assign data to amt
        ampl.SetData(df3);
        // Solve the model
        ampl.Solve();

        // Print out the result
        Console.Write("Objective function value: {0}\n",
          ampl.GetObjective("Total_Cost").Value);

        // Get the values of the variable Buy in a dataframe
        DataFrame results = ampl.GetVariable("Buy").GetValues();
        // Print
        Console.WriteLine(results.ToString());
      }
      return 0;
    }
  }
}
