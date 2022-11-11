import com.ampl.AMPL;
import com.ampl.DataFrame;
import com.ampl.Environment;

public class MultiDimensionalExample {

  public static void main(String[] args) {

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
      ampl.eval("set CITIES; set LINKS within (CITIES cross CITIES);");
      ampl.eval("param cost {LINKS} >= 0; param capacity {LINKS} >= 0;");
      ampl.eval("data; set CITIES := PITT NE SE BOS EWR BWI ATL MCO;");

      double[] cost = new double[] { 2.5, 3.5, 1.7, 0.7, 1.3, 1.3, 0.8, 0.2, 2.1 };
      double[] capacity = new double[] { 250, 250, 100, 100, 100, 100, 100, 100, 100 };

      String LinksFrom[] = {"PITT", "PITT", "NE", "NE", "NE", "SE", "SE", "SE", "SE"};
      String LinksTo[] = {"NE", "SE", "BOS", "EWR", "BWI", "EWR", "BWI", "ATL", "MCO"};

      DataFrame df = new DataFrame(2, "LinksFrom", "LinksTo", "cost", "capacity");
      df.setColumn("LinksFrom", LinksFrom);
      df.setColumn("LinksTo", LinksTo);
      df.setColumn("cost", cost);
      df.setColumn("capacity", capacity);
      System.out.println(df.toString());
      ampl.setData(df, "LINKS");

      DataFrame output = ampl.getParameter("cost").getValues();
      for(int i=0; i<LinksFrom.length; i++)
      {
        System.out.format("%s should be equal to %s%n",
            df.getRow(LinksFrom[i], LinksTo[i])[2],
            output.getRow(LinksFrom[i], LinksTo[i])[2]);
        Double o1 = (Double)df.getRow(LinksFrom[i], LinksTo[i])[2];
        Double o2 = (Double)output.getRow(LinksFrom[i], LinksTo[i])[2];
        if(Double.compare(o1, o2) != 0)
          throw new RuntimeException("Error while comparing values!");
      }
    }
    finally {
      ampl.close();
    }
  }
}
