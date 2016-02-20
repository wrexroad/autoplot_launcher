# Autoplot Launcher
A bash script for checking version info, downloading a new version if needed,
and running Autoplot from the Linux command line in one easy step. Autoplot is run in
the background with the STDOUT and STDERR streams redirected to log files.

This is intended for running Autoplot on Linux, users of other OS's should reference
the standard autoplot installation instructions (http://www.autoplot.org/help#Installation).

The current autoplot.jar file is kept in $HOME/autoplot_data/autoplot.jar
(when new versions are found the currently downloaded version is overwritten).

Log files of the stdout and stderr streams are stored in $HOME/autoplot_data/log

## Prerequisites
`wget` is required for downloading version info and jar files.

`gzip` is needed to unpack older versions of Autoplot correctly.

## Installation

### Automatic installation - creates .desktop file for Gnome and Unity launchers
```
$ git clone https://github.com/wrexroad/autoplot_launcher.git $HOME/autplot_launcher/
$ chmod +x $HOME/autplot_launcher/autoplot.sh
$ $HOME/autplot_launcher/autoplot.sh --install
```
### Manual install for command line only use
```
#in your home direcotry
$ git clone https://github.com/wrexroad/autoplot_launcher.git
$ chmod +x $HOME/autplot_launcher/autoplot.sh
$ sudo ln -s $HOME/autplot_launcher/autoplot.sh /bin/usr/autoplot
```
