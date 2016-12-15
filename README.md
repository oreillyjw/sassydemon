# sassydemon
## sass autocompiler shell script
This script uses `inotify-tools` to monitor a specified `watch directory` for any changes to `.scss` files. It then runs `sass` on those files to compile it into `.css` and output them into an (optional) output directory. _If no output directory is specified, it will output them to the same directory as the changed `.scss` file_


## Basic Usage
`/bin/bash sassy_demon.sh -w scss/`

This will have the script watch the `scss/` directory for changes. Since no output directory was specified, the CSS file will go to the same place

## Using Output Directory
`/bin/bash sassy_demon.sh -w scss/ -o css/`

This will have the script watch the `scss/` directory for changes and send the output to `css/`


