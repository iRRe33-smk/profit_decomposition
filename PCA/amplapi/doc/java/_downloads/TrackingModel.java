import java.io.IOException;

import com.ampl.AMPL;
import com.ampl.Parameter;
import com.ampl.Variable;
import com.ampl.Environment;

public class TrackingModel {

  public static void main(String[] args) throws IOException {

    String baseDir = args.length > 1 ? args[1] : "../models";
    String modelDirectory = baseDir + "/tracking";

    // Create an AMPL instance
    AMPL ampl = new AMPL();

    /*
    // If the AMPL installation directory is not in the system search path:
    Environment env = new Environment(
        "full path to the AMPL installation directory");
    AMPL ampl = new AMPL(env);
    */

    // Outer try-catch-finally block, to be sure of releasing the AMPL
    // object when done
    try {
      if (args.length > 0)
        if (!args[0].equals("NA"))
          ampl.setOption("solver", args[0]);

      // Load the AMPL model from file
      ampl.read(modelDirectory + "/tracking.mod");
      // Read data
      ampl.readData(modelDirectory + "/tracking.dat");
      // Read table declarations
      ampl.read(modelDirectory + "/trackingbit.run");
      // Set tables directory (parameter used in the script above)
      ampl.getParameter("data_dir").set(modelDirectory);
      // Read tables
      ampl.readTable("assets");
      ampl.readTable("indret");
      ampl.readTable("returns");

      Variable hold = ampl.getVariable("hold");
      Parameter ifinuniverse = ampl.getParameter("ifinuniverse");

      // Relax the integrality
      ampl.setBoolOption("relax_integrality", true);
      // Solve the problem
      ampl.solve();

      double lowcutoff = 0.04;
      double highcutoff = 0.1;
      // Get the variable representing the (relaxed) solution vector
      double[] holddf = hold.getValues().getColumnAsDoubles("hold");
      // For each asset, if it was held by more than the highcutoff,
      // forces it in the model, if less than lowcutoff, forces it out
      double[] toHold = new double[holddf.length];
      for (int i = 1; i < toHold.length; i++) {
        if (holddf[i] < lowcutoff)
          toHold[i] = 0;
        else if (holddf[i] > highcutoff)
          toHold[i] = 2;
        else
          toHold[i] = 1;
      }

      // uses those values for the parameter ifinuniverse, which controls
      // which stock is included or not in the solution
      ifinuniverse.setValues(toHold);

      // Get back to the integer problem
      ampl.setBoolOption("relax_integrality", false);
      // Solve the (integer) problem
      ampl.solve();
    }
    finally {
      ampl.close();
    }
  }
}
