#!/bin/bash

#make sure there is a valid place to keep autoplot and log info
AUTOPLOT_HOME=$HOME/autoplot_data
JARFILE=$AUTOPLOT_HOME/autoplot.jar;
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
   echo $APVERHASH > $AUTOPLOT_HOME/.versionhash
   rm $AUTOPLOT_HOME/autoplot.jar
   wget http://autoplot.org/jnlp/latest/autoplot.jar -O$AUTOPLOT_HOME/autoplot.jar
fi
#clean up the downloaded webpage
rm $AUTOPLOT_HOME/.html.tmp*

#get any user supplied arguments
JAVA_ARGS=""
AP_ARGS=""
memIsImplicit=1

for i in "$@"; do
   if [ "$APDEBUG" == "1" ]; then    
       echo "arg: \"$i\""
   fi
   if [[ $i == -J-Xmx* ]]; then
      JAVA_ARGS="${JAVA_ARGS} ${i:2}";
      memIsImplicit=0
   elif [[ $i == -J* ]]; then
      JAVA_ARGS="${JAVA_ARGS} ${i:2}";
   elif [[ $i == '--headless' ]]; then
      JAVA_ARGS="${JAVA_ARGS} -Djava.awt.headless=true";
   elif [[ $i == '-h' ]]; then
      JAVA_ARGS="${JAVA_ARGS} -Djava.awt.headless=true";
   else
      AP_ARGS="${AP_ARGS} $i";
   fi
done

#Try to run java as specified by $JAVA_HOME. If that variable isn't set, just
#use whatever java shows up first in the PATH 
if [ "$APDEBUG" == "1" ]; then 
   if [ "${JAVA_HOME}" -a \( -x "${JAVA_HOME}"/bin/java \) ]; then      
      echo $EXEC "${JAVA_HOME}"/bin/java ${JAVA_ARGS} -jar ${JARFILE} "${AP_ARGS}"
   else
      echo $EXEC /usr/bin/env java ${JAVA_ARGS} -jar ${JARFILE} "${AP_ARGS}"
   fi
fi

if [ "${JAVA_HOME}" -a \( -x "${JAVA_HOME}"/bin/java \) ]; then      
      $EXEC "${JAVA_HOME}"/bin/java ${JAVA_ARGS} -jar ${JARFILE} "${AP_ARGS}" >$AUTOPLOT_HOME/log/out.txt 2>$AUTOPLOT_HOME/log/err.txt &
else
      $EXEC /usr/bin/env java ${JAVA_ARGS} -jar ${JARFILE} "${AP_ARGS}" >$AUTOPLOT_HOME/log/out.txt 2>$AUTOPLOT_HOME/log/err.txt &
fi
