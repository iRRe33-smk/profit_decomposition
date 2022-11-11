using ampl;
using System;
using System.Collections.Generic;

namespace Examples
{
  /// <summary>
  /// This example shows how to redirect AMPL output (normally directed to the console) and AMPL
  /// errors (by default, an error throws an exception and a warning is simply directed to the console.
  /// </summary>
  public class OutputAndErrorRedirectionExample
  {

    class OutputMsg
    {
      public DateTime Date;
      public Kind Kind;
      public string Msg;

      public OutputMsg(DateTime date, Kind kind, string msg)
      {
        Date = date;
        Kind = kind;
        Msg = msg;
      }
    }

    static List<OutputMsg> outputs = new List<OutputMsg>();

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
      using (var ampl = new AMPL())
      {
        ampl.Eval("var x{1..3};");
        ampl.Eval("maximize z: sum{i in 1..3} x[i];");

        // *** Output redirection *** Enable output redirection
        ampl.EnableOutputRouting();
        // Assign handler: Method 1: using method
        ampl.Output += HandleOutput;
        ampl.Eval("display x;");
        ampl.Eval("let {i in 1..3} x[i] := i;");
        ampl.Eval("display x;");
        // Unassign output handler
        ampl.Output -= HandleOutput;
        // print all outputs
        foreach (var t in outputs)
          Console.Write("{0} - Kind: {1} - Msg:\n{2}", t.Date,
            t.Kind, t.Msg);

        // Method 2: Using lambda expression
        ampl.Output += (kind, message) => Console.Write("Got AMPL message:\n{0}\n", message);
        // Test it
        ampl.Eval("display x,x;");

        // *** Error redirection *** Enable error and warnings redirection
        ampl.EnableErrorAndWarningRouting();
        // Register handlers
        ampl.Error += HandleError;
        ampl.Warning += HandleWarning;
        // Normally throws exception, will just be printed on screen
        ampl.Eval("var x;");
        // Create an obvious infeasibility
        ampl.Eval("c1: x[1]>=1; c2: x[1]<=0;");
        // Solve the model, issuing a warning
        ampl.Solve();
      }
      return 0;
    }

    private static void HandleError(AMPLException obj)
    {
      Console.Write("Got error: {0}\n", obj.Message);
    }

    private static void HandleOutput(Kind arg1, string arg2)
    {
      outputs.Add(new OutputMsg(DateTime.Now, arg1, arg2));
    }

    private static void HandleWarning(AMPLException obj)
    {
      Console.Write("Got warning: {0}\n", obj.Message);
    }
  }
}
