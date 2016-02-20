#!/bin/bash

AP_HOME=$HOME/autoplot_data
AP_LIB=$AP_HOME/lib
AP_LOG=$AP_HOME/log
JAVA_ARGS=""
AP_ARGS=""
AP_VER="latest"
memIsImplicit=1

function linuxinstall {
   DESKTOPFILE="$HOME/.local/share/applications/autoplot.desktop"
   ICONFILE="$AP_HOME/autoplot.png"
   SCRIPTFILE="$AP_HOME/autoplot.sh"
   mkdir -p ~/.local/share/applications/
   mkdir -p $AP_HOME
   
   #copy all files to the $AP_HOME
   cp autoplot.sh $AP_HOME
   chmod a+x $AP_HOME/autoplot.sh
   cp autoplot.png $ICONFILE
      
   touch $DESKTOPFILE
   echo "[Desktop Entry]" > $DESKTOPFILE
   echo "Name=Autoplot" >> $DESKTOPFILE
   echo "Exec=$SCRIPTFILE" >> $DESKTOPFILE
   echo "Icon=$ICONFILE" >> $DESKTOPFILE
   echo "Type=Application" >> $DESKTOPFILE
   echo "Terminal=true" >> $DESKTOPFILE
   echo "Categories=Graphics;Science;Utility;" >> $DESKTOPFILE

   #try to link the script to a location in the user's PATH
   SETPATH=0
   array=(${PATH//:/ })
   for i in "${array[@]}"
   do
      ln -s $SCRIPTFILE $i/autoplot
      if [ "$?" == "0" ]; then
         SETPATH=1
         break
      fi
   done
   
   echo ""
   echo "---------------------------"
   echo ""
   echo "Autoplot installed!"
   echo "autoplot.sh (this file) located: $SCRIPTFILE"
   echo "autoplot.svg (icon file) located: $ICONFILE"
   echo "autoplot.desktop located: $DESKTOPFILE"
   if [ "$SETPATH" == "0" ]; then
      echo "Could not link $SCRIPTFILE to your PATH."
      echo "To run Autoplot from the command line you will need to specify the full path."
      echo ""
      echo "Type \"$SCRIPTFILE --help\" for options."
   else
      echo "Linked autoplot.sh to your path as 'autoplot'."
      echo ""
      echo "Type \"autoplot --help\" for options."  
   fi
   echo ""
   echo "---------------------------"
   echo ""
}

function printhelp {
   echo "Autoplot Launcher"
   echo
   echo "usage: ./autoplot.sh [options]"
   echo
   echo "Options:"
   echo "--version={version}       Request a specific version of Autoplot."
   echo "                          Default is 'latest'."
   echo "-J-{javaopts}             Options for the Java Virtual Machine should"
   echo "                          be prefixed with '-J'."
   echo "-h, --headless            Run Autoplot in headless mode."
   echo "--install                 Creates an launcer icon. Linux Only."
   echo "--debug                   Autoplot Launcher mode provides extra dialog"
   echo "                          about what is happening in this script."
   echo "--help                    Prints this dialog."
   echo
}

function getjars {
   #download the webstart file which contains the version info
   echo ""
   echo "Updating Autoplot Webstart file..."
   echo ""
   rm autoplot.jnlp
   wget http://autoplot.org/jnlp/$AP_VER/autoplot.jnlp
   echo "---------------------------"
   echo ""
   
   #get the AutoplotStable version and main class path from the webstart file
   MAINCLASS=$(grep main-class ~/autoplot_data/lib/autoplot.jnlp | sed -e    's/.*main-class="\(.*\)".*/\1/')
   AP_STAB=$(grep -oh "AutoplotStable.[[:digit:]]\{8\}.jar" autoplot.jnlp)
   
   #only download and upack AutoplotStable if we dont have it already
   if [ ! -f $AP_LIB/$AP_STAB ]; then
      echo "Updating AutolplotStable library..."
      echo ""
      wget -N http://autoplot.org/jnlp/lib/$AP_STAB.pack.gz
      if [ "$?" != "0" ]; then
         echo "Failed to get http://autoplot.org/jnlp/lib/$AP_STAB.pack.gz"
         echo "Quitting..."
         exit
      fi
      
      #We want to use gzip to decompress pack.gz file. Older versions of Java 
      #seem to be incompatable with some versions of unpack200 compression
      if hash gzip 2>/dev/null; then
         gzip -d $AP_STAB.pack.gz
         unpack200 -v $AP_STAB.pack $AP_STAB
         rm $AP_STAB.pack
      else
         #no gzip? What kind of system is this? Oh well...
         unpack200 -v $AP_STAB.pack.gz $AP_STAB
      fi
      
      echo "---------------------------"
      echo ""
   fi
     
   #since the AutoplotVolatile filename doesnt have specific versioning, we need
   #to do some extra managment to make sure wget is comparing the timestamp of
   #the correct file
   if [ -f "AutoplotVolatile.$AP_VER.jar.pack.gz" ]; then
      cp --preserve=timestamps AutoplotVolatile.$AP_VER.jar.pack.gz AutoplotVolatile.jar.pack.gz
   elif [ -f "AutoplotVolatile.jar.pack.gz" ]; then
      rm  AutoplotVolatile.jar.pack.gz
   fi 
   echo "Updating AutolplotVolatile library..."
   echo ""
   wget -N http://autoplot.org/jnlp/$AP_VER/AutoplotVolatile.jar.pack.gz
   if [ "$?" != "0" ]; then
      echo "Failed to get http://autoplot.org/jnlp/lib/AutoplotVolatile.jar.pack.gz"
      echo "Quitting..."
      exit
   fi
   
   #copy save the jar to a versioned filename for future use
   cp --preserve=timestamps AutoplotVolatile.jar.pack.gz AutoplotVolatile.$AP_VER.jar.pack.gz
   
   if hash gzip 2>/dev/null; then
      gzip -d AutoplotVolatile.jar.pack.gz
      unpack200 -v AutoplotVolatile.jar.pack AutoplotVolatile.jar
      rm AutoplotVolatile.jar.pack
   else
      unpack200 -v AutoplotVolatile.jar.pack.gz AutoplotVolatile.jar
   fi
   
   echo "---------------------------"
   echo ""
}

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
   elif [[ $i == "--install" ]]; then
      linuxinstall
      exit
   elif [[ $i == "--help" ]]; then
      printhelp
      exit
   else
      AP_ARGS="${AP_ARGS} $i";
   fi
done

if [ "$APDEBUG" == "1" ]; then    
   for i in "$@"; do
          echo "[DEBUG] arg: \"$i\""
   done
fi

#make sure there is a valid place to keep autoplot and log info
mkdir -p $AP_LIB
mkdir -p $AP_LOG

#download the correct version of autoplot
cd $AP_LIB
getjars
cd -

#Try to run java as specified by $JAVA_HOME. If that variable isn't set, just
#use whatever java shows up first in $PATH 
echo "Starting Autoplot..."
echo "Log files are being stored in $AP_LOG/out.txt and $AP_LOG/err.txt"

if [ "$APDEBUG" == "1" ]; then
   if [ "${JAVA_HOME}" -a \( -x "${JAVA_HOME}"/bin/java \) ]; then
      echo "[DEBUG]" $EXEC nohup "${JAVA_HOME}"/bin/java -cp ${AP_LIB}/AutoplotVolatile.jar:$AP_LIB/$AP_STAB ${JAVA_ARGS} $MAINCLASS "${AP_ARGS}"
   else
      echo "[DEBUG]" $EXEC nohup /usr/bin/env java -cp ${AP_LIB}/AutoplotVolatile.jar:$AP_LIB/$AP_STAB ${JAVA_ARGS} $MAINCLASS "${AP_ARGS}"
   fi
fi

if [ "${JAVA_HOME}" -a \( -x "${JAVA_HOME}"/bin/java \) ]; then
      nohup $EXEC "${JAVA_HOME}"/bin/java -cp ${AP_LIB}/AutoplotVolatile.jar:$AP_LIB/$AP_STAB ${JAVA_ARGS} $MAINCLASS "${AP_ARGS}" >$AP_HOME/log/out.txt 2>$AP_HOME/log/err.txt
else
      nohup $EXEC /usr/bin/env java -cp ${AP_LIB}/AutoplotVolatile.jar:$AP_LIB/$AP_STAB ${JAVA_ARGS} $MAINCLASS "${AP_ARGS}" >$AP_HOME/log/out.txt 2>$AP_HOME/log/err.txt
fi