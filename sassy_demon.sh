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
track_subs=false;
watch_dir='';
output_dir='';
SCRIPT=$(basename ${BASH_SOURCE});
RED='\033[0;31m';
GREEN='\033[0;32m';
CYAN='\033[0;36m';
NC='\033[0m';

function HELP {
  echo -e "${CYAN}************ HELP DOCUMENTATION FOR SASSY_DEMON.SH ************${NC}\n";
  echo -e "Dependencies:\t${SCRIPT} requires ${CYAN}inotify-tools${NC} and ${CYAN}sass${NC} to be installed\n"
  echo -e "Basic Usage:\t${GREEN}./${SCRIPT} -w scss/${NC}\nThis will set ${SCRIPT} to watch the ${CYAN}scss/${NC} directory for changes.\n";
  echo -e "Using Output Directory:\t${GREEN}./${SCRIPT} -w scss/ -o css/${NC}\nThis will set ${SCRIPT}to watch the ${CYAN}scss/${NC} directory for changes\nand output the compiled CSS file to the ${CYAN}css/${NC} directory.\n";
  echo -e "${CYAN}\n********* FLAGS **********${NC}\n";
  echo -e "${RED}(REQUIRED)${NC} [ ${GREEN}-w <path>${NC} ] is used to set the directory you want to watch. \nEx: ${GREEN}./${SCRIPT} -w scss/${NC} will set ${SCRIPT} to watch the ${CYAN}scss/${NC}\n";
  echo -e "[ ${GREEN}-o <path>${NC} ] is used to set the directory you want to output to. \nEx: ${GREEN}./${SCRIPT} -w scss/ -o css/${NC} will set ${SCRIPT} to watch the ${CYAN}scss/${NC} but will output the CSS file to ${CYAN}css/${NC}\n${RED}NOTE:${NC} if no output directory is declared, ${SCRIPT} will output the CSS file to the same directory you are watching.\n";
  echo -e "[ ${GREEN}-s${NC} ] is the ${CYAN}'track subdirectories'${NC} flag.\nThe program runs recursively.  Without this flag, the output will just go directly to your output directory and not maintain the full path of the change.\nEx: If you're watching ${CYAN}scss/${NC} and your ouput directory is ${CYAN}css/${NC};\nif the file changed is ${CYAN}scss/test/files/testfile.scss${NC} then the CSS file will go to ${CYAN}css/testfile.css${NC}\nWith the ${GREEN}-s${NC} flag, the file would go to ${CYAN}/css/test/files/testfile.css${NC} and create any of the directories if they do not exist\n";
   echo -e "[ ${GREEN}-h${NC} ] will bring up this help documentation.\n";
}

while getopts :shw:o: FLAG; do
  case $FLAG in
    s)
      track_subs=true
      ;;
    w)
      watch_dir=$OPTARG
      ;;
    o)
      output_dir=$OPTARG
      ;;
    h)
      HELP
      exit
      ;;
    \?)
    echo -e "${RED}Invalid command line argument.${NC}\n"
      HELP
      exit
      ;;
  esac
done

if [ -z $has_inotifywait ] && [ -z $has_sass ]
then
    echo -e "${RED}********************\nERROR: YOU DO NOT HAVE CERTAIN DEPENDENCIES INSTALLED:${NC} \n- inotify-tools (https://github.com/rvoicilas/inotify-tools/wiki)\n - Sass (http://sass-lang.com/install)\n";
    exit;
elif [ -z $has_inotifywait ]
then
    echo -e "${RED}********************\nERROR: YOU DO NOT HAVE CERTAIN DEPENDENCIES INSTALLED:${NC} \n- inotify-tools (https://github.com/rvoicilas/inotify-tools/wiki)\n";
    exit;
elif [ -z $has_sass ]
then
    echo -e "${RED}********************\nERROR: YOU DO NOT HAVE CERTAIN DEPENDENCIES INSTALLED:${NC} \n- Sass (http://sass-lang.com/install)\n";
    exit;
fi

if [ -z $watch_dir ]
then
  echo -e "\n${RED}No directories specified. You must at least specify a directory to watch${NC}\nUse ${GREEN}-w <path>${NC}\n";
  exit;
else
  if [ -z $output_dir ]
  then
     output_dir=${watch_dir};
  fi
  echo -e "--------------------------\nWATCHING DIRECTORY: ${GREEN}${watch_dir}${NC}\nWILL SEND OUTPUT TO: ${GREEN}${output_dir}${NC}\n";
  if [ $track_subs = true ]
  then
  echo -e "${GREEN}OUTPUT WILL CONTAIN SUBDIRECTORIES${NC}\n";
  fi
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
            elif [ $track_subs = true ]
            then
                output_path=${output_dir}${path#$watch_dir};
            else
                output_path=${output_dir};
            fi
            mkdir -p $output_path;
            echo -e "********\nCOMPILING: ${GREEN}${path}${filename}.scss${NC} \nOUTPUT: ${GREEN}${output_path}${filename}.css${NC}\n";
            sass --sourcemap=none --cache=false ${path}${filename}.scss ${output_path}${filename}.css;
            #sass ${path}${filename}.scss ${output_path}${filename}.css;
            echo -e "done.\n**********";
         fi
      fi
    done
fi
