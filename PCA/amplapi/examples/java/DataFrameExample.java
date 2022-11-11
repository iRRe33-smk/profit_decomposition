import java.io.IOException;

import com.ampl.AMPL;
import com.ampl.DataFrame;

// This example illustrates the usage of the DataFrame class.
public class DataFrameExample {

  public static void main(String[] args) throws IOException {
    // Create first dataframe (for data indexed over NUTR)
    // Add data row by row
    DataFrame df1 = new DataFrame(1, "NUTR", "n_min", "n_max");
    df1.addRow("A", 700, 20000);
    df1.addRow("B1", 700, 20000);
    df1.addRow("B2", 700, 20000);
    df1.addRow("C", 700, 20000);
    df1.addRow("CAL", 16000, 24000);
    df1.addRow("NA", 0, 50000);

    // Create second dataframe (for data indexed over FOOD)
    // Add column by column
    DataFrame df2 = new DataFrame(1, "FOOD");
    df2.setColumn("FOOD", new String[] { "BEEF", "CHK", "FISH", "HAM", "MCH", "MTL", "SPG", "TUR" });
    int[] contents = new int[df2.getNumRows()];
    for (int i = 0; i < contents.length; i++)
      contents[i] = 2;
    df2.addColumn("f_min", contents);
    for (int i = 0; i < contents.length; i++)
      contents[i] = 10;
    df2.addColumn("f_max", contents);
    df2.addColumn("cost", new double[] { 3.19, 2.59, 2.29, 2.89, 1.89, 1.99, 1.99, 2.49 });

    // Create third dataframe, to assign data to the AMPL entity
    // param amt{NUTR, FOOD};
    DataFrame df3 = new DataFrame(2, "NUTR", "FOOD");
    // Populate the set columns
    String[] nutrWithMultiplicity = new String[df1.getColumn("NUTR").length * df2.getColumn("FOOD").length];
    String[] foodWithMultiplicity = new String[df1.getColumn("NUTR").length * df2.getColumn("FOOD").length];

    int i = 0;
    for (String n : df1.getColumnAsStrings("NUTR")) {
      for (String f : df2.getColumnAsStrings("FOOD")) {
        nutrWithMultiplicity[i] = n;
        foodWithMultiplicity[i] = f;
        i++;
      }
    }

    df3.setColumn("NUTR", nutrWithMultiplicity);

    // This second operation automatically populates the two indexing
    // columns with the set product of the two indexing sets
    df3.setColumn("FOOD", foodWithMultiplicity);

    // Populate with all these values
    int[] values = new int[] { 60, 8, 8, 40, 15, 70, 25, 60, 10, 20, 15, 35, 15, 15, 25, 15, 15, 20, 10, 10, 15, 15, 15,
        10, 20, 0, 10, 40, 35, 30, 50, 20, 295, 770, 440, 430, 315, 400, 370, 450, 968, 2180, 945, 278, 1182, 896, 1329,
        1397 };
    df3.addColumn("amt", values);

    // Create AMPL object
    AMPL ampl = new AMPL();
    try {
      if (args.length > 0)
        if (!args[0].equals("NA"))
          ampl.setOption("solver", args[0]);
      // Load the model (which defines all the parameters we will be
      // assigning)
      String baseDir = args.length > 1 ? args[1] : "../models";
      String modelDirectory = baseDir + "/diet";
      ampl.read(modelDirectory + "/diet.mod");
      // Assign data to NUTR, n_min and n_max
      ampl.setData(df1, "NUTR");
      // Assign data to FOOD, f_min, f_max and cost
      ampl.setData(df2, "FOOD");
      // Assign data to amt
      ampl.setData(df3);
      // Solve the model
      ampl.solve();

      // Print out the result
      System.out.format("Objective function value: %f%n", ampl.getObjective("Total_Cost").value());

      // Get the values of the variable Buy in a dataframe
      DataFrame results = ampl.getVariable("Buy").getValues();
      // Print
      System.out.println(results);
    } finally {
      ampl.close();
    }
  }
}
