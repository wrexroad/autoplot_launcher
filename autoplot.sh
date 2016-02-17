#!/bin/bash
mkdir -p $HOME/autoplot_data/log
wget http://autoplot.org/jnlp/latest/index.html -O/tmp/autoplot.index > /dev/null 2>/dev/null
autoplotversionhash=$(cat /tmp/autoplot.index | md5sum | tr -d '[:space:]')
oldautoplotversionhash=$(cat $HOME/autoplot_data/.versionhash | tr -d '[:space:]')
if [ "$autoplotversionhash" != "$oldautoplotversionhash" ]; then
   echo "Updating Autolplot..."
   echo $autoplotversionhash > $HOME/autoplot_data/.versionhash
   rm $HOME/autoplot_data/autoplot.jar
   wget http://autoplot.org/jnlp/latest/autoplot.jar -O$HOME/autoplot_data/autoplot.jar
fi

rm /tmp/autoplot.index*

java -jar $HOME/autoplot_data/autoplot.jar >$HOME/autoplot_data/log/out.txt 2>$HOME/autoplot_data/log/err.txt &
