import java.io.IOException;

import com.ampl.AMPL;
import com.ampl.DataFrame;
import com.ampl.Environment;

public class DietModel {

  public static void main(String[] args) throws IOException {

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

      // Use the provided path or the default one
      String baseDir = args.length > 1 ? args[1] : "../models";
      String modelDirectory = baseDir + "/diet";
      // Load the AMPL model from file
      ampl.read(modelDirectory + "/diet.mod");

      String[] foods =
          new String[] { "BEEF", "CHK", "FISH", "HAM", "MCH", "MTL", "SPG", "TUR" };

      DataFrame df = new DataFrame(1, "FOOD");
      df.setColumn("FOOD", foods);
      df.addColumn("cost", new double[] { 3.59, 2.59, 2.29, 2.89, 1.89, 1.99, 1.99, 2.49 });
      df.addColumn("f_min");
      df.addColumn("f_max");
      df.setColumn("f_min", new double [] {2,2,2,2,2,2,2,2});
      df.setColumn("f_max", new double [] {10,10,10,10,10,10,10,10});
      ampl.setData(df, "FOOD");

      String[] nutrients = new String[] { "A", "C", "B1", "B2", "NA", "CAL" };
      df = new DataFrame(1, "NUTR");
      df.setColumn("NUTR", nutrients);
      df.addColumn("n_min", new double[] { 700, 700, 700, 700, 0, 16000 });
      df.addColumn("n_max", new double[] { 20000, 20000, 20000, 20000, 50000, 24000 });
      ampl.setData(df, "NUTR");

      double[][] amounts = new double[6][];
      amounts[0] = new double[] { 60, 8, 8, 40, 15, 70, 25, 60 };
      amounts[1] = new double[] { 20, 0, 10, 40, 35, 30, 50, 20 };
      amounts[2] = new double[] { 10, 20, 15, 35, 15, 15, 25, 15 };
      amounts[3] = new double[] { 15, 20, 10, 10, 15, 15, 15, 10 };
      amounts[4] = new double[] { 928, 2180, 945, 278, 1182, 896, 1329, 1397 };
      amounts[5] = new double[] { 295, 770, 440, 430, 315, 400, 379, 450 };

      df = new DataFrame(2, "NUTR", "FOOD", "amt");
      df.setMatrix(amounts, nutrients, foods);
      ampl.setData(df);

      ampl.solve();

      System.out.println(ampl.getObjective("Total_Cost").value());
    } finally {
      ampl.close();
    }
  }
}
