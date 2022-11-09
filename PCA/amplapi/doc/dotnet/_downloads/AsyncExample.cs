using ampl;
using System;
using System.Collections.Generic;
using System.Threading;

namespace Examples
{
  public class AsyncExample
  {
    static List<string> outputs = new List<string>();
    static AutoResetEvent waitHandle = new AutoResetEvent(false);

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

      using (AMPL ampl = new AMPL())
      {
        if (solver != null) ampl.SetOption("solver", solver);
        ampl.SetOption("reset_initial_guesses", true);
        ampl.SetOption("send_statuses", false);
        ampl.SetOption("relax_integrality", true);

        // Load the AMPL model from file
        ampl.Read(modelDirectory + "/qpmv/qpmv.mod");
        ampl.Read(modelDirectory + "/qpmv/qpmvbit.run");

        // set tables directory (parameter used in the script above)
        ampl.GetParameter("data_dir").Set(modelDirectory + "/qpmv");
        // Read tables
        ampl.ReadTable("assetstable");
        ampl.ReadTable("astrets");

        // set the output handler to accumulate the output messages
        ampl.Output += Ampl_Output;

        // Create the callback object
        Console.WriteLine("Main thread: Model setup complete. Solve on worker thread.");
        // Initiate the async solution process, passing the callback as a parameter. The Action
        // below will be executed by the AMPL API when the solution process will be completed.
        ampl.SolveAsync(() => Callback());

        // Wait for the solution to complete (achieved by waiting on the AutoResetEvent waitHandle
        Console.WriteLine("Main thread: Waiting for solution to end...\n");
        var start = DateTime.Now;
        waitHandle.WaitOne();
        var duration = DateTime.Now - start;

        Console.WriteLine("Main thread: done waiting.");

        // At this stage, the AMPL process is done, the message "Solution process ended." has been
        // printed on the console by the callback and we print a second confirmation from the main thread
        Console.WriteLine("Main thread: waited for {0}", duration.ToString());
        // Print the objective value
        Console.WriteLine("Main thread: cost: {0}", ampl.GetValue("cst").Dbl);
      }
      return 0;
    }

    private static void Ampl_Output(Kind arg1, string arg2)
    {
      outputs.Add(arg2);
    }

    private static void Callback()
    {
      Console.WriteLine("Solution process ended");
      // Signal the waiting thread so that it knows the result is ready.
      waitHandle.Set();
    }
  }
}
