using ampl;
using System;

namespace Examples
{
  public class MultidimensionalExample
  {
    public static int Main(string[] args)
    {
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
        ampl.Eval("set CITIES; set LINKS within (CITIES cross CITIES);");
        ampl.Eval("param cost {LINKS} >= 0; param capacity {LINKS} >= 0;");
        ampl.Eval("data; set CITIES := PITT NE SE BOS EWR BWI ATL MCO;");

        double[] cost = { 2.5, 3.5, 1.7, 0.7, 1.3, 1.3, 0.8, 0.2, 2.1 };
        double[] capacity = { 250, 250, 100, 100, 100, 100, 100, 100, 100 };
        string[] LinksFrom = { "PITT", "PITT", "NE", "NE", "NE", "SE", "SE", "SE", "SE" };
        string[] LinksTo = { "NE", "SE", "BOS", "EWR", "BWI", "EWR", "BWI", "ATL", "MCO" };

        DataFrame df = new DataFrame(2, "LINKSFrom", "LINKSTo", "cost", "capacity");
        df.SetColumn("LINKSFrom", LinksFrom);
        df.SetColumn("LINKSTo", LinksTo);
        df.SetColumn("cost", cost);
        df.SetColumn("capacity", capacity);
        Console.WriteLine(df.ToString());

        ampl.SetData(df, "LINKS");
      }
      return 0;
    }
  }
}