#include "ampl/ampl.h"

#include <iostream>

int main(int argc, char **argv) {
  try {
    // Create an AMPL instance
    ampl::AMPL ampl;

    /*
    // If the AMPL installation directory is not in the system search path:
    ampl::Environment env("full path to the AMPL installation directory");
    ampl::AMPL ampl(env);
    */

    if (argc > 1)
      ampl.setOption("solver", argv[1]);

    // Read the model file
    std::string modelDirectory = argc == 3 ? argv[2] : "../models";
    ampl.read(modelDirectory + "/diet/diet.mod");

    const char *foods[] = {
        "BEEF", "CHK", "FISH", "HAM", "MCH", "MTL", "SPG", "TUR"};
    double costs[] = {
        3.59, 2.59, 2.29, 2.89, 1.89, 1.99, 1.99, 2.49};
    double fmin[] = {2, 2, 2, 2, 2, 2, 2, 2};
    double fmax[] = {10, 10, 10, 10, 10, 10, 10, 10};

    ampl::DataFrame df(1, "FOOD");
    df.setColumn("FOOD", foods, 8);
    df.addColumn("cost", costs);
    df.addColumn("f_min", fmin);
    df.addColumn("f_max", fmax);
    ampl.setData(df, "FOOD");

    const char *nutrients[] = {"A", "C", "B1", "B2", "NA", "CAL"};
    double nmin[] = {700, 700, 700, 700, 0, 16000};
    double nmax[] = {20000, 20000, 20000, 20000, 50000, 24000};
    df = ampl::DataFrame(1, "NUTR");
    df.setColumn("NUTR", nutrients, 6);
    df.addColumn("n_min", nmin);
    df.addColumn("n_max", nmax);
    ampl.setData(df, "NUTR");

    double amounts[6][8] = {
        {60, 8, 8, 40, 15, 70, 25, 60},
        {20, 0, 10, 40, 35, 30, 50, 20},
        {10, 20, 15, 35, 15, 15, 25, 15},
        {15, 20, 10, 10, 15, 15, 15, 10},
        {928, 2180, 945, 278, 1182, 896, 1329, 1397},
        {295, 770, 440, 430, 315, 400, 379, 450}};
    // Note the use of ampl::StringArgs to pass an array of strings
    df = ampl::DataFrame(2, ampl::StringArgs("NUTR", "FOOD", "amt"));
    df.setMatrix(nutrients, foods, amounts);
    ampl.setData(df);

    ampl.solve();

    std::cout << "Objective: " << ampl.getObjective("Total_Cost").value() << "\n";
    return 0;
  } catch (const std::exception &e) {
    std::cout << e.what() << "\n";
    return 1;
  }
}
