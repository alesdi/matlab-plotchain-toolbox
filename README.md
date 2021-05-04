# matlab-plotchain-toolbox

A MATLAB toolbox to easily create LaTeX-style plots with an elegant method chaining syntax. The toolbox also integrates miscellaneous utility functions.

## Available Classes and Functions
- **ptInit:** performs standard initialization actions (clear workspace and console), prepares the folder for saving figures and initializes an execution timer
- **ptEnd:** terminates the script and shows the total execution time, if ptInit was used correctly
- **ptFigure:** wrapper class to create a pre-styled figure with dedicated methods for layout and plots (refer to <code>help</code> for usage).
- **ptStore:** general purpose folder-related persistent storage utility (refer to <code>help</code> for usage)
- **ptSpectrum:** wrapper for matlab <code>spectrum</code> function to get the spectrum of a signal in Hz
- **ptTHD:** simple function to compute the THD of a signal with respect to an arbitrary fundamental frequency
- **ptPersistentTimeSeriesBounds:** shows a GUI interface for picking the start and end times of a signal and saves the result persistently leveraging <code>ptStore</code> for future script execution.
