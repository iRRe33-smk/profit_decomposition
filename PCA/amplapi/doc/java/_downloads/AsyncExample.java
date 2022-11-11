import java.io.IOException;
import java.util.LinkedList;

import com.ampl.AMPL;
import com.ampl.Kind;
import com.ampl.OutputHandler;
import com.ampl.Environment;

public class AsyncExample {

  /**
   * Class used as an output handler, it just accumulates the output messages,
   * which are then accessible via the function getOutputs().
   */
  static class MyOutputHandler implements OutputHandler {
    LinkedList<String> returned = new LinkedList<String>();

    @Override
    public void output(Kind kind, String msg) {
      returned.add(msg);
    }

    public LinkedList<String> getOutputs() {
      return returned;
    }

    public String getOutputsAsString() {
      StringBuilder sb = new StringBuilder();
      for (String o : returned)
        sb.append(o);
      return sb.toString();
    }
  }

  /**
   * Object used to communicate back the results of the async operation. Must
   * implement the interface ``Runnable``.
   */
  static class MyInterpretIsOver implements Runnable {

    @Override
    public void run() {
      System.out.println("Solution process ended.");
    }
  }

  public static void main(String[] args) throws IOException {

    String baseDir = args.length > 1 ? args[1] : "../models";
    String modelDirectory = baseDir + "/qpmv";

    // Create an AMPL instance
    AMPL ampl = new AMPL();

    /*
    // If the AMPL installation directory is not in the system search path:
    Environment env = new Environment(
        "full path to the AMPL installation directory");
    AMPL ampl = new AMPL(env);
    */

    if (args.length > 0)
      if (!args[0].equals("NA"))
        ampl.setOption("solver", args[0]);
    // Outer try-catch-finally block, to be sure of releasing the AMPL
    // object when done
    try {
      ampl.setBoolOption("reset_initial_guesses", true);
      ampl.setBoolOption("send_statuses", false);
      ampl.setBoolOption("relax_integrality", true);

      // Load the AMPL model from file
      ampl.read(modelDirectory + "/qpmv.mod");
      ampl.read(modelDirectory + "/qpmvbit.run");

      // Set tables directory (parameter used in the script above)
      ampl.getParameter("data_dir").set(modelDirectory);
      // Read tables
      ampl.readTable("assetstable");
      ampl.readTable("astrets");

      ampl.eval("let stockopall:={};let stockrun:=stockall;");

      // Set the output handler to accumulate the output messages
      MyOutputHandler outputHandler = new MyOutputHandler();
      ampl.setOutputHandler(outputHandler);

      // Create the callback object
      MyInterpretIsOver callback = new MyInterpretIsOver();

      // Initiate the async solution process, passing the callback object
      // as a parameter.
      // The function "call"will be called by the AMPL API when the
      // solution process will be completed.
      // In the meantime the main thread of execution will carry on, and
      // the :java:ref:`AMPL.isBusy` flag will be set to true
      ampl.solveAsync(callback);

      int counter = 50;

      // Wait until AMPL is free
      while (ampl.isBusy()) {
        try {
          Thread.sleep(50);
        } catch (InterruptedException ie) {
          System.out.println(ie.getMessage());
        }
        System.out.format("%d milliseconds elapsed%n", counter);
        counter += 50;
      }

      // At this stage, the AMPL process is done, the message
      // "Solution process ended." has been printed on the console by the
      // callback
      // and we print a second confirmation from the main thread
      System.out.println("Main thread: Solution process ended.");

      // Print the AMPL messages occurred during the solution process
      System.out.println(outputHandler.getOutputsAsString());

      // Print the objective value, using AMPL routines
      ampl.display("cst");
    } finally {
      ampl.close();
    }
  }
}
