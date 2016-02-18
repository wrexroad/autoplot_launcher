#!/bin/bash

#make sure there is a valid place to keep autoplot and log info
AP_HOME=$HOME/autoplot_data
AP_LIB=$AP_HOME/lib
AP_LOG=$AP_HOME/log
mkdir -p $AP_LIB
mkdir -p $AP_LOG

echo "Checking for Autolplot update..."
cd $AP_LIB

#download the webstart file which contains the version info
wget -N http://autoplot.org/autoplot.jnlp

#get the AutoplotStable version and main class path
MAINCLASS=$(grep main-class ~/autoplot_data/lib/autoplot.jnlp | sed -e 's/.*main-class="\(.*\)".*/\1/')
AP_STAB=$(grep -oh "AutoplotStable.[[:digit:]]\{8\}.jar" autoplot.jnlp)

#get the AutoplotStable and AutoplotVolatile jars
wget -N http://autoplot.org/jnlp/lib/$AP_STAB.pack.gz http://autoplot.org/jnlp/latest/AutoplotVolatile.jar.pack.gz

#unpack the jars
unpack200 -v $AP_STAB.pack.gz $AP_STAB
echo ""
unpack200 -v AutoplotVolatile.jar.pack.gz AutoplotVolatile.jar
echo ""
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
      echo $EXEC "${JAVA_HOME}"/bin/java -cp "${AP_LIB}/*" ${JAVA_ARGS} $MAINCLASS "${AP_ARGS}"
   else
      echo $EXEC /usr/bin/env java -cp "${AP_LIB}/*" ${JAVA_ARGS} $MAINCLASS "${AP_ARGS}"
   fi
fi

if [ "${JAVA_HOME}" -a \( -x "${JAVA_HOME}"/bin/java \) ]; then      
      $EXEC "${JAVA_HOME}"/bin/java -cp "${AP_LIB}/*" ${JAVA_ARGS} $MAINCLASS "${AP_ARGS}" >$AP_HOME/log/out.txt 2>$AP_HOME/log/err.txt &
else
      $EXEC /usr/bin/env java -cp "${AP_LIB}/*" ${JAVA_ARGS} $MAINCLASS "${AP_ARGS}" >$AP_HOME/log/out.txt 2>$AP_HOME/log/err.txt &
fi
