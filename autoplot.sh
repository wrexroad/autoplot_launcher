#!/bin/bash

#make sure there is a valid place to keep autoplot and log info
AUTOPLOT_HOME=$HOME/autoplot_data
JARFILE=$AUTOPLOT_HOME/autoplot.jar;
mkdir -p $AUTOPLOT_HOME/log

echo "Checking for Autolplot update..."
cd $AUTOPLOT_HOME
wget -N http://autoplot.org/jnlp/latest/autoplot.jar
cd -

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
