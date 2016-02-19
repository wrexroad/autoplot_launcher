#!/bin/bash

AP_HOME=$HOME/autoplot_data
AP_LIB=$AP_HOME/lib
AP_LOG=$AP_HOME/log
JAVA_ARGS=""
AP_ARGS=""
AP_VER="latest"
memIsImplicit=1

#get any user supplied arguments
for i in "$@"; do
   if [[ $i == -J-Xmx* ]]; then
      JAVA_ARGS="${JAVA_ARGS} ${i:2}";
      memIsImplicit=0
   elif [[ $i == -J* ]]; then
      JAVA_ARGS="${JAVA_ARGS} ${i:2}";
   elif [[ $i == '--headless' ]]; then
      JAVA_ARGS="${JAVA_ARGS} -Djava.awt.headless=true";
   elif [[ $i == '-h' ]]; then
      JAVA_ARGS="${JAVA_ARGS} -Djava.awt.headless=true";
   elif [[ $i == --version* ]]; then
      AP_VER="${i:10}";
   elif [[ $i == "--debug" ]]; then
      APDEBUG=1;
   else
      AP_ARGS="${AP_ARGS} $i";
   fi
done

if [ "$APDEBUG" == "1" ]; then    
   for i in "$@"; do
          echo "arg: \"$i\""
   done
fi

#make sure there is a valid place to keep autoplot and log info
mkdir -p $AP_LIB
mkdir -p $AP_LOG

#download the webstart file which contains the version info
cd $AP_LIB
echo ""
echo "Updating Autoplot Webstart file..."
echo ""
wget -N http://autoplot.org/jnlp/$AP_VER/autoplot.jnlp
echo "---------------------------"
echo ""

#get the AutoplotStable version and main class path from the webstart file
MAINCLASS=$(grep main-class ~/autoplot_data/lib/autoplot.jnlp | sed -e 's/.*main-class="\(.*\)".*/\1/')
AP_STAB=$(grep -oh "AutoplotStable.[[:digit:]]\{8\}.jar" autoplot.jnlp)

#only download and upack AutoplotStable if we dont have it already
if [ ! -f $AP_LIB/$AP_STAB ]; then
   echo "Updating AutolplotStable library..."
   echo ""
   wget -N http://autoplot.org/jnlp/lib/$AP_STAB.pack.gz 
   unpack200 -v $AP_STAB.pack.gz $AP_STAB
   echo "---------------------------"
   echo ""
fi
  
#since AutoplotVolatile does not have a version number in the name,
#just try to redownload and unpack
echo "Updating AutolplotVolatile library..."
echo ""
wget -N http://autoplot.org/jnlp/$AP_VER/AutoplotVolatile.jar.pack.gz
unpack200 -v AutoplotVolatile.jar.pack.gz AutoplotVolatile.jar
echo "---------------------------"
echo ""

cd -

#Try to run java as specified by $JAVA_HOME. If that variable isn't set, just
#use whatever java shows up first in $PATH 
echo "Starting Autoplot..."

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

echo "Log files are being stored in $AP_LOG/out.txt and $AP_LOG/err.txt"
 