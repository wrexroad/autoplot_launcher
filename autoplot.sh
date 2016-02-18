#!/bin/bash

#make sure there is a valid place to keep autoplot and log info
AUTOPLOT_HOME=$HOME/autoplot_data
mkdir -p $AUTOPLOT_HOME/log

#Download the webpage of the lasest version. This page contains the 
#current version number.
wget http://autoplot.org/jnlp/latest/index.html -O$AUTOPLOT_HOME/.html.tmp > /dev/null 2>/dev/null

#Comparing a hash of the downloaded page to the hash of the previously
#downloaded page will tell us if the version has changed.
APVERHASH=$(md5sum $AUTOPLOT_HOME/.html.tmp | tr -d '[:space:]')
APVERHASH_OLD=$(cat $AUTOPLOT_HOME/.versionhash | tr -d '[:space:]')
if [ "$APVERHASH" != "$APVERHASH_OLD" ]; then
   #Something (presumably the version number) has changed on the webpage. 
   #Download a new copy of autoplot.jar
   echo "Updating Autolplot..."
   echo $autoplotversionhash > $AUTOPLOT_HOME/.versionhash
   rm $AUTOPLOT_HOME/autoplot.jar
   wget http://autoplot.org/jnlp/latest/autoplot.jar -O$AUTOPLOT_HOME/autoplot.jar
fi
#clean up the downloaded webpage
rm $AUTOPLOT_HOME/.html.tmp*

java -jar $AUTOPLOT_HOME/autoplot.jar >$AUTOPLOT_HOME/log/out.txt 2>$AUTOPLOT_HOME/log/err.txt &
