import java.io.IOException;

import com.ampl.AMPL;
import com.ampl.DataFrame;
import com.ampl.Objective;
import com.ampl.Parameter;
import com.ampl.Tuple;
import com.ampl.Variable;
import com.ampl.Environment;

public class FirstExample {

  public static void main(String[] args) throws IOException {

    // Create an AMPL instance
    AMPL ampl = new AMPL();

    /*
    // If the AMPL installation directory is not in the system search path:
    Environment env = new Environment(
        "full path to the AMPL installation directory");
    AMPL ampl = new AMPL(env);
    */

    // Embed everything in a try-catch-finally block, so that
    // we are certain that ampl.close() is called to free
    // resources at the end of the execution
    try {
      if (args.length > 0)
        if (!args[0].equals("NA"))
          ampl.setOption("solver", args[0]);

      String baseDir = args.length > 1 ? args[1] : "../models";
      String modelDirectory = baseDir + "/diet";

      // Interpret the two files
      ampl.read(modelDirectory + "/diet.mod");
      ampl.readData(modelDirectory + "/diet.dat");

      // Solve
      ampl.solve();

      // Get objective entity by AMPL name
      Objective totalcost = ampl.getObjective("Total_Cost");
      // Print it
      System.out.format("ObjectiveInstance is: %f%n", totalcost.value());

      // Reassign data - specific instances
      Parameter cost = ampl.getParameter("cost");
      cost.setValues(new Tuple[] { new Tuple("BEEF"), new Tuple("HAM") }, new double[] { 5.01, 4.55 });
      System.out.println("Increased costs of beef and ham.");

      // Resolve and display objective
      ampl.solve();
      System.out.format("New objective value: %f%n", totalcost.value());

      // Reassign data - all instances
      cost.setValues(new double[] { 3, 5, 5, 6, 1, 2, 5.01, 4.55 });
      System.out.println("Updated all costs");
      // Resolve and display objective
      ampl.solve();
      System.out.format("New objective value: %f%n", totalcost.value());

      // Get the values of the variable Buy in a dataframe object
      Variable buy = ampl.getVariable("Buy");
      DataFrame df = buy.getValues();
      // Print them
      System.out.println(df);

      // Get the values of an expression into a DataFrame object
      DataFrame df2 = ampl.getData("{j in FOOD} 100*Buy[j]/Buy[j].ub");
      // Print them
      System.out.println(df2);

    } finally {
      ampl.close();
    }
  }
}