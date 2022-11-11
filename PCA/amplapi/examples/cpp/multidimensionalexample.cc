#include "ampl/ampl.h"

#include <iostream>

int main() {
  try {
    // Create an AMPL instance
    ampl::AMPL ampl;

    /*
    // If the AMPL installation directory is not in the system search path:
    ampl::Environment env("full path to the AMPL installation directory");
    ampl::AMPL ampl(env);
    */

    ampl.eval("set CITIES; set LINKS within (CITIES cross CITIES);");
    ampl.eval("param cost {LINKS} >= 0; param capacity {LINKS} >= 0;");
    ampl.eval("data; set CITIES := PITT NE SE BOS EWR BWI ATL MCO;");

    double cost[] = {2.5, 3.5, 1.7, 0.7, 1.3, 1.3, 0.8, 0.2, 2.1};
    double capacity[] = {250, 250, 100, 100, 100, 100, 100, 100, 100};
    const char *LinksFrom[] = {
        "PITT", "PITT", "NE", "NE", "NE", "SE", "SE", "SE", "SE"};
    const char *LinksTo[] = {
        "NE", "SE", "BOS", "EWR", "BWI", "EWR", "BWI", "ATL", "MCO"};

    ampl::DataFrame df(2, ampl::StringArgs(
                              "LINKSFrom", "LINKSTo", "cost", "capacity"));
    df.setColumn("LINKSFrom", LinksFrom, 9);
    df.setColumn("LINKSTo", LinksTo, 9);
    df.setColumn("cost", cost, 9);
    df.setColumn("capacity", capacity, 9);
    std::cout << df.toString();

    ampl.setData(df, "LINKS");
    return 0;
  } catch (const std::exception &e) {
    std::cout << e.what() << "\n";
    return 1;
  }
}
