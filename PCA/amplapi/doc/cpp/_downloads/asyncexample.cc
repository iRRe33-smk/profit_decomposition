#include "ampl/ampl.h"

#include <iostream>
#include <thread>
#include <condition_variable>

// Use C++11 synchronization:
std::condition_variable isdone_cv;
std::mutex isdone_mutex;
bool isdone = false;

struct IsDone {
  bool operator()() const { return isdone; }
};

/*
 * Class used as an output handler. It only prints the solver output.
 * Must publicly implement ``ampl::OutputHandler``.
 */
class MyOutputHandler : public ampl::OutputHandler {
public:
  void output(ampl::output::Kind kind, const char* output) {
    if (kind == ampl::output::SOLVE)
      std::printf("Solver: %s\n", output);
  }
};

/*
 * Object used to communicate the end of the async operation. Must
 * publicly implement ``ampl::Runnable``.
 */
class MyInterpretIsOver : public ampl::Runnable {
public:
  void run() {
    std::cout << "Solution process ended. Notifying waiting thread.\n";
    {
      std::lock_guard<std::mutex> lk(isdone_mutex);
      isdone = true;
    }
    isdone_cv.notify_all();
  }
};

int main(int argc, char **argv) {
  try {
    std::string modelDirectory(argc == 3 ? argv[2] : "../models");

    // Create an AMPL instance
    ampl::AMPL ampl;

    /*
    // If the AMPL installation directory is not in the system search path:
    ampl::Environment env("full path to the AMPL installation directory");
    ampl::AMPL ampl(env);
    */

    ampl.setBoolOption("reset_initial_guesses", true);
    ampl.setBoolOption("send_statuses", false);
    ampl.setBoolOption("relax_integrality", true);

    if (argc > 1)
      ampl.setOption("solver", argv[1]);

    // Load the AMPL model from file
    ampl.read(modelDirectory + "/qpmv/qpmv.mod");
    ampl.read(modelDirectory + "/qpmv/qpmvbit.run");

    // Set tables directory (parameter used in the script above)
    ampl.getParameter("data_dir").set(modelDirectory + "/qpmv");
    // Read tables
    ampl.readTable("assetstable");
    ampl.readTable("astrets");

    // Set the output handler to accumulate the output messages
    MyOutputHandler outputHandler;
    ampl.setOutputHandler(&outputHandler);

    // Create the callback object
    MyInterpretIsOver callback;
    std::cout << "Main thread: Model setup complete. Solve on worker thread.\n";
    // Initiate the async solution process, passing the callback object
    // as a parameter.
    // The function run() will be called by the AMPL API when the
    // solution process will be completed.
    ampl.solveAsync(&callback);

    // Wait for the solution to complete (achieved by waiting on the
    // std::condition_variable isdone
    std::cout << "Main thread: Waiting for solution to end...\n\n";
    std::unique_lock<std::mutex> lk(isdone_mutex);

    namespace chrono = std::chrono;
    auto start = chrono::system_clock::now();
    isdone_cv.wait(lk, IsDone());
    auto duration = chrono::system_clock::now() - start;

    std::cout << "Main thread: done waiting.\n";

    // At this stage, the AMPL process is done, the message
    // "Solution process ended." has been printed on the console by the
    // callback and we print a second confirmation from the main thread
    std::cout << "Main thread: waited for "
      << chrono::duration_cast<chrono::milliseconds>(duration).count()
      << " ms\n";
    // Print the objective value
    std::cout << "Main thread: cost: " << ampl.getValue("cst").dbl() << "\n";
  } catch (const std::exception &e) {
    std::cout << e.what() << "\n";
  }
}
