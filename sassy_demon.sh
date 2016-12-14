#!/bin/bash

######### SASS AUTOCOMPILER ################
#
# First it checks if you have Sass and inotify-tools installed
# You can then pass it a folder path to watch for changes as the first parameter
# You can pass an optional second parameter for the output directory where the CSS file will go once compiled
# If you pass . as the second parameter, make the subdirectories inside the current director you are in
# and output the file there.
#
### Ex: ./sassy_demon.sh ../scss/ ../../css
####### If there are changes made to ../scss/test/files/test_file.scss, it will output to
####### It will output to ../../css/test/files/test_file.css
#
### If you are currently in your home directory (ex: pwd = /home/justin)
####### ./sassy_demon.sh /www/scss/files .
####### If there is a change made to /www/scss/files/test/files/test_file.scss
####### It will output to /home/justin/test/files/test_file.css
#
#########################################################################

############## MAIN PROGRAM ################

has_sass=$(which sass);
has_inotifywait=$(which inotifywait);

if [ -z $has_inotifywait ] && [ -z $has_sass ]
then
    echo -e "********************\nERROR: YOU DO NOT HAVE CERTAIN DEPENDENCIES INSTALLED: \n- inotify-tools (https://github.com/rvoicilas/inotify-tools/wiki)\n - Sass (http://sass-lang.com/install)\n";
    exit;
elif [ -z $has_inotifywait ]
then
    echo -e "********************\nERROR: YOU DO NOT HAVE CERTAIN DEPENDENCIES INSTALLED: \n- inotify-tools (https://github.com/rvoicilas/inotify-tools/wiki)\n";
    exit;
elif [ -z $has_sass ]
then
    echo -e "********************\nERROR: YOU DO NOT HAVE CERTAIN DEPENDENCIES INSTALLED: \n- Sass (http://sass-lang.com/install)\n";
    exit;
fi

if [ $# -eq 0 ]
then
  echo "\nNo arguments specified. You must at least specify a directory to watch\n";
  exit;
else
  watch_dir=$1;
  output_dir=${2:-$watch_dir};
  echo -e "--------------------------\nWATCHING DIRECTORY: ${watch_dir}\nWILL SEND OUTPUT TO: ${output_dir}\n--------------------------";
  inotifywait -mr -e modify $watch_dir |
    while read path action file; do
      if [[ ${file: -4} != ".swp" ]]
      then
         if [[ ${file: -4} != ".css" ]]
         then
            filename=${file%.*};
            if [[ $watch_dir -ef $output_dir ]]
            then
                output_path=$path;
            elif [ "$output_dir" == '.' ]
            then
                output_path=${path#$watch_dir};
            else
                output_path=${output_dir}${path#$watch_dir};
            fi
            mkdir -p $output_path;
            echo -e "********\nCOMPILING: ${path}${filename}.scss \nOUTPUT: ${output_path}${filename}.css\n";
            sass --sourcemap=none --cache=false ${path}${filename}.scss ${output_path}${filename}.css;
            #sass ${path}${filename}.scss ${output_path}${filename}.css;
            echo -e "done.\n**********";
         fi
      fi
    done
fi
