# Change Log

## [v1.5.3](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.5.3) (2021-07-04)

- misc. improvements:
  - adding the configuration of the [makelove](https://github.com/pfirsich/makelove) tool:
    - supporting the building of the game for the following platforms:
      - Windows;
      - macOS;
      - Linux (via the [AppImage](https://appimage.org/) format).

## [v1.5.2](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.5.2) (2021-06-29)

- describe the game documentation:
  - contents:
    - controls;
    - gameplay;
  - translations:
    - in English;
    - in Russian;
  - misc.:
    - screenshot;
    - linked table of contents.

## [v1.5.1](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.5.1) (2021-03-22)

Describe releases of the game.

- description of releases:
  - features;
  - change log.

## [v1.5](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.5) (2021-03-14)

Store the game stats in the [FlatDB](https://github.com/uleelx/FlatDB) database, store the game configuration in a JSON file, and support resizing of the game window.

- plots:
  - configuration:
    - options:
      - speed of motion of the plots;
      - amount of plot points per screen;
      - coefficients:
        - of updation of the random plot;
        - of updation of the custom plot:
          - in the inactive mode;
          - in the active mode;
- game stats:
  - truncation of indexes to integers when defining the distance type;
  - storing the game stats in the [FlatDB](https://github.com/uleelx/FlatDB) database:
    - regular saving with a certain period;
  - configuration:
    - options:
      - amount of points per screen for checking the distance between the random and custom plots;
      - limits of the distance between the random and custom plots:
        - soft limit;
        - hard limit;
      - period of saving of the game stats;
- drawing:
  - drawing of a type of distance between the random and custom plots:
    - truncation of indexes to integers when defining the distance type;
  - drawing of the game stats:
    - dynamic width of the stats labels:
      - correction of the coefficients of widths of the stats labels;
- game configuration:
  - loading from a JSON file;
  - validation via the JSON Schema;
- misc. improvements:
  - adding the [LÖVE configuration](https://love2d.org/wiki/Config_Files):
    - game window:
      - resizable mode;
      - title;
      - size:
        - minimal;
        - default;
    - [MSAA](https://en.wikipedia.org/wiki/Multisample_anti-aliasing) tuning;
    - save directory for a game.

### Features

- plots:
  - they display functions of time (as in an oscilloscope);
  - they are initially initialized by the average value over the entire length;
  - random plot:
    - it is updated with a random shift from the last value;
    - it takes up three-quarters of the screen width;
  - custom plot:
    - it is updated with a custom shift from the last value:
      - custom shift can be positive (the plot grows);
      - custom shift can be negative (the plot shrinks);
    - it takes up half of the screen width;
  - custom source plot:
    - it is updated by either the minimal or maximal value;
    - it takes up half of the screen width;
  - configuration:
    - options:
      - speed of motion of the plots;
      - amount of plot points per screen;
      - coefficients:
        - of updation of the random plot;
        - of updation of the custom plot:
          - in the inactive mode;
          - in the active mode;
- game stats:
  - metrics:
    - percentage of time when the distance between the random and custom plots was normal;
    - percentage of time when the distance between the random and custom plots fit within the soft limit;
    - percentage of time when the distance between the random and custom plots fit within the hard limit;
  - types:
    - current;
    - best;
  - storing the game stats in the [FlatDB](https://github.com/uleelx/FlatDB) database:
    - regular saving with a certain period;
  - configuration:
    - options:
      - amount of points per screen for checking the distance between the random and custom plots;
      - limits of the distance between the random and custom plots:
        - soft limit;
        - hard limit;
      - period of saving of the game stats;
- pause mode:
  - stopping of updating:
    - of the plots;
    - of the game stats;
- drawing:
  - drawing of plot boundaries;
  - drawing of plots;
  - drawing of a type of distance between the random and custom plots:
    - normal distance;
    - distance that fits within the soft limit;
    - distance that fits within the hard limit;
  - drawing of the game stats:
    - dynamic width of the stats labels:
      - width is selected by the maximum of the current and best values;
    - delay of updating of the best stats:
      - update starts only after all initial values of the custom plot have left the screen;
  - drawing of the pause mode;
  - support of resizing of the game window;
- game configuration:
  - loading from a JSON file;
  - validation via the JSON Schema.

## [v1.4](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.4) (2021-03-11)

Perform refactoring.

- refactoring.

## [v1.3](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.3) (2021-02-06)

Add the pause mode.

- pause mode:
  - stopping of updating:
    - of the plots;
    - of the game stats;
- drawing:
  - drawing of the pause mode.

### Features

- plots:
  - they display functions of time (as in an oscilloscope);
  - they are initially initialized by the average value over the entire length;
  - random plot:
    - it is updated with a random shift from the last value;
    - it takes up three-quarters of the screen width;
  - custom plot:
    - it is updated with a custom shift from the last value:
      - custom shift can be positive (the plot grows);
      - custom shift can be negative (the plot shrinks);
    - it takes up half of the screen width;
  - custom source plot:
    - it is updated by either the minimal or maximal value;
    - it takes up half of the screen width;
- game stats:
  - metrics:
    - percentage of time when the distance between the random and custom plots was normal;
    - percentage of time when the distance between the random and custom plots fit within the soft limit;
    - percentage of time when the distance between the random and custom plots fit within the hard limit;
  - types:
    - current;
    - best;
- pause mode:
  - stopping of updating:
    - of the plots;
    - of the game stats;
- drawing:
  - drawing of plot boundaries;
  - drawing of plots;
  - drawing of a type of distance between the random and custom plots:
    - normal distance;
    - distance that fits within the soft limit;
    - distance that fits within the hard limit;
  - drawing of the game stats:
    - dynamic width of the stats labels:
      - width is selected by the maximum of the current and best values;
    - delay of updating of the best stats:
      - update starts only after all initial values of the custom plot have left the screen;
  - drawing of the pause mode.

## [v1.2](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.2) (2021-01-18)

Collect and draw the game stats.

- game stats:
  - metrics:
    - percentage of time when the distance between the random and custom plots was normal;
    - percentage of time when the distance between the random and custom plots fit within the soft limit;
    - percentage of time when the distance between the random and custom plots fit within the hard limit;
  - types:
    - current;
    - best;
- drawing:
  - drawing of the game stats:
    - dynamic width of the stats labels:
      - width is selected by the maximum of the current and best values;
    - delay of updating of the best stats:
      - update starts only after all initial values of the custom plot have left the screen.

### Features

- plots:
  - they display functions of time (as in an oscilloscope);
  - they are initially initialized by the average value over the entire length;
  - random plot:
    - it is updated with a random shift from the last value;
    - it takes up three-quarters of the screen width;
  - custom plot:
    - it is updated with a custom shift from the last value:
      - custom shift can be positive (the plot grows);
      - custom shift can be negative (the plot shrinks);
    - it takes up half of the screen width;
  - custom source plot:
    - it is updated by either the minimal or maximal value;
    - it takes up half of the screen width;
- game stats:
  - metrics:
    - percentage of time when the distance between the random and custom plots was normal;
    - percentage of time when the distance between the random and custom plots fit within the soft limit;
    - percentage of time when the distance between the random and custom plots fit within the hard limit;
  - types:
    - current;
    - best;
- drawing:
  - drawing of plot boundaries;
  - drawing of plots;
  - drawing of a type of distance between the random and custom plots:
    - normal distance;
    - distance that fits within the soft limit;
    - distance that fits within the hard limit;
  - drawing of the game stats:
    - dynamic width of the stats labels:
      - width is selected by the maximum of the current and best values;
    - delay of updating of the best stats:
      - update starts only after all initial values of the custom plot have left the screen.

## [v1.1](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.1) (2021-01-10)

Draw a type of distance between the random and custom plots.

- drawing:
  - drawing of a type of distance between the random and custom plots:
    - normal distance;
    - distance that fits within the soft limit;
    - distance that fits within the hard limit.

### Features

- plots:
  - they display functions of time (as in an oscilloscope);
  - they are initially initialized by the average value over the entire length;
  - random plot:
    - it is updated with a random shift from the last value;
    - it takes up three-quarters of the screen width;
  - custom plot:
    - it is updated with a custom shift from the last value:
      - custom shift can be positive (the plot grows);
      - custom shift can be negative (the plot shrinks);
    - it takes up half of the screen width;
  - custom source plot:
    - it is updated by either the minimal or maximal value;
    - it takes up half of the screen width;
- drawing:
  - drawing of plot boundaries;
  - drawing of plots;
  - drawing of a type of distance between the random and custom plots:
    - normal distance;
    - distance that fits within the soft limit;
    - distance that fits within the hard limit.

## [v1.0.1](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.0.1) (2021-01-03)

Perform refactoring.

- refactoring.

## [v1.0](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.0) (2020-12-25)

Major version. Implement the custom and custom source plots.

- plots:
  - they are initially initialized by the average value over the entire length;
  - custom plot:
    - it is updated with a custom shift from the last value:
      - custom shift can be positive (the plot grows);
      - custom shift can be negative (the plot shrinks);
    - it takes up half of the screen width;
  - custom source plot:
    - it is updated by either the minimal or maximal value;
    - it takes up half of the screen width.

### Features

- plots:
  - they display functions of time (as in an oscilloscope);
  - they are initially initialized by the average value over the entire length;
  - random plot:
    - it is updated with a random shift from the last value;
    - it takes up three-quarters of the screen width;
  - custom plot:
    - it is updated with a custom shift from the last value:
      - custom shift can be positive (the plot grows);
      - custom shift can be negative (the plot shrinks);
    - it takes up half of the screen width;
  - custom source plot:
    - it is updated by either the minimal or maximal value;
    - it takes up half of the screen width;
- drawing:
  - drawing of plot boundaries;
  - drawing of plots.

## [v1.0-alpha](https://github.com/thewizardplusplus/pwm-simulator/tree/v1.0-alpha) (2020-12-23)

Alpha of the major version. Implement the random plot.

### Features

- plots:
  - they display functions of time (as in an oscilloscope);
  - random plot:
    - it is updated with a random shift from the last value;
    - it takes up three-quarters of the screen width;
- drawing:
  - drawing of plot boundaries;
  - drawing of plots.
