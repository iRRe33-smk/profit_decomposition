import com.ampl.AMPL;
import com.ampl.Environment;

public class OptionsExample {

  public static void main(String[] args) {

    // Create an AMPL instance
    AMPL ampl = new AMPL();

    /*
    // If the AMPL installation directory is not in the system search path:
    Environment env = new Environment(
        "full path to the AMPL installation directory");
    AMPL ampl = new AMPL(env);
    */

    // Embed everything in a try-catch-finally block, so that we are certain
    // that ampl.close() is called to free resources at the end of the
    // execution.
    try {
      int presolve;
      // Get the value of the option presolve and print
      presolve = ampl.getIntOption("presolve");
      System.out.format("AMPL presolve is %d%n", presolve);
      // Set the value to false (maps to 0)
      ampl.setBoolOption("presolve", false);
      // Get the value of the option presolve and print
      presolve = ampl.getIntOption("presolve");
      System.out.format("AMPL presolve is now %d%n", presolve);

      // Set the value of the boolean option show_stats to true (maps to 1
      // in AMPL)
      ampl.setBoolOption("show_stats", true);
      // Print its value as an integer
      System.out.format("AMPL show_stats is %d%n", ampl.getIntOption("show_stats"));
      // Set the value of the boolean option show_stats to false (maps to
      // 0 in AMPL)
      ampl.setBoolOption("show_stats", false);
      // Print its value as an integer
      System.out.format("AMPL show_stats is %d%n", ampl.getIntOption("show_stats"));
    } finally {
      ampl.close();
    }
  }

}
