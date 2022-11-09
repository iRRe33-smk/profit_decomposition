using ampl;
using System;

namespace Examples
{
  public class OptionsExample
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
        // Get the value of the option preSolve and print
        int presolve = ampl.GetIntOption("presolve").Value;
        Console.Write("AMPL preSolve is {0}\n", presolve);

        // set the value to false (maps to 0)
        ampl.SetOption("presolve", false);

        // Get the value of the option preSolve and print
        presolve = ampl.GetIntOption("presolve").Value;
        Console.Write("AMPL preSolve is now {0}\n", presolve);

        // Check whether an option with a specified name exists
        string value = ampl.GetOption("Solver");
        if (value != null)
          Console.WriteLine("Option Solver exists and has value: " + value);

        // Check again, this time failing
        value = ampl.GetOption("s_o_l_v_e_r");
        if (value == null)
          Console.WriteLine("Option s_o_l_v_e_r does not exists!");

        // Using nullables (for bool, int and double options)
        double? dblvalue = ampl.GetDblOption("does_not_exist");
        if (dblvalue.HasValue)
          Console.WriteLine("Surprisingly, \"does_not_exist\" has a value!");
        else
          Console.WriteLine("\"does_not_exist\" does not have a value!");

        // Error if accessing value
        try
        {
          Console.WriteLine(dblvalue.Value);
        }
        catch (InvalidOperationException ex)
        {
          Console.WriteLine("Error while accessing not existing value:");
          Console.WriteLine(ex.Message);
        }
      }
      return 0;
    }
  }
}