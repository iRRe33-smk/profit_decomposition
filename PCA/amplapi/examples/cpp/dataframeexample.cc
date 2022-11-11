#include "ampl/ampl.h"

#include <algorithm> // for std::fill_n
#include <iostream>

int main(int argc, char **argv) {
  try {
    // Create first dataframe (for data indexed over NUTR)
    // Add data row by row
    ampl::DataFrame df1(1, ampl::StringArgs("NUTR", "n_min", "n_max"));
    df1.addRow("A", 700, 20000);
    df1.addRow("B1", 700, 20000);
    df1.addRow("B2", 700, 20000);
    df1.addRow("C", 700, 20000);
    df1.addRow("CAL", 16000, 24000);
    df1.addRow("NA", 0.0, 50000);

    // Create second dataframe (for data indexed over FOOD)
    // Add column by column
    ampl::DataFrame df2(1, "FOOD");
    const char* foods[] = { "BEEF", "CHK", "FISH", "HAM",
      "MCH", "MTL", "SPG", "TUR" };
    df2.setColumn("FOOD", foods, 8);
    double contents[8];
    std::fill_n(contents, 8, 2);
    df2.addColumn("f_min", contents);
    std::fill_n(contents, 8, 10);
    df2.addColumn("f_max", contents);
    double costs[] = { 3.19, 2.59, 2.29, 2.89, 1.89,
      1.99, 1.99, 2.49 };
    df2.addColumn("cost", costs);

    // Create third dataframe, to assign data to the AMPL entity
    // param amt{NUTR, FOOD};
    ampl::DataFrame df3(2, ampl::StringArgs("NUTR", "FOOD"));
    // Populate the set columns
    const char* nutrWithMultiplicity[48];
    const char* foodWithMultiplicity[48];
    std::size_t i = 0;
    for (int n = 0; n < 6; n++) {
      for (int f = 0; f < 8; f++) {
        nutrWithMultiplicity[i] = df1.getRowByIndex(n)[0].c_str();
        foodWithMultiplicity[i] = foods[f];
        i++;
      }
    }
    df3.setColumn("NUTR", nutrWithMultiplicity, 48);
    df3.setColumn("FOOD", foodWithMultiplicity, 48);

    // Populate with all these values
    double values[] = { 60, 8, 8, 40, 15, 70, 25, 60, 10, 20, 15,
      35, 15, 15, 25, 15, 15, 20, 10, 10, 15, 15, 15, 10, 20, 0, 10,
      40, 35, 30, 50, 20, 295, 770, 440, 430, 315, 400, 370, 450,
      968, 2180, 945, 278, 1182, 896, 1329, 1397 };
    df3.addColumn("amt", values);

    // Create an AMPL instance
    ampl::AMPL ampl;

    if (argc > 1)
      ampl.setOption("solver", argv[1]);

    std::string modelDirectory = argc == 3 ? argv[2] : "../models";
    ampl.read(modelDirectory + "/diet/diet.mod");
    // Assign data to NUTR, n_min and n_max
    ampl.setData(df1, "NUTR");
    // Assign data to FOOD, f_min, f_max and cost
    ampl.setData(df2, "FOOD");
    // Assign data to amt
    ampl.setData(df3);
    // Solve the model
    ampl.solve();

    // Print out the result
    std::cout << "Objective function value: " <<
      ampl.getObjective("Total_Cost").value() << "\n";

    // Get the values of the variable Buy in a dataframe
    ampl::DataFrame results = ampl.getVariable("Buy").getValues();
    // Print
    std::cout << results.toString() << "\n";
    return 0;
  } catch (const std::exception &e) {
    std::cout << e.what() << "\n";
    return 1;
  }
}
