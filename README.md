# sassydemon
## sass autocompiler shell script
This script uses `inotify-tools` to monitor a specified `watch directory` for any changes to `.scss` files. It then runs `sass` on those files to compile it into `.css` and output them into an (optional) output directory. _If no output directory is specified, it will output them to the same directory as the changed `.scss` file_


### Basic Usage
`/bin/bash sassy_demon.sh -w scss/`

This will have the script watch the `scss/` directory for changes. Since no output directory was specified, the CSS file will go to the same place
```
 /bin/bash sassy_demon.sh -w scss/
--------------------------
WATCHING DIRECTORY: scss/
WILL SEND OUTPUT TO: scss/

Setting up watches.  Beware: since -r was given, this may take a while!
Watches established.
```
_NOTE: Because the watcher is using a `-r` flag behind the scenes to look recursively for changes, `inotify` gives the warning that it may take a while. Once the watcher is established, it will show `Watches established.`, meaning it is running and watching your files_

When you make a change, the script will display the following:
```
********
COMPILING: scss/test/files/test_file.scss
OUTPUT: scss/test/files/test_file.css

done.
**********
```

### Using Output Directory
`/bin/bash sassy_demon.sh -w scss/ -o css/`

This will have the script watch the `scss/` directory for changes and send the output to `css/`
```
$ /bin/bash sassy_demon.sh -w scss/ -o css/
--------------------------
WATCHING DIRECTORY: scss/
WILL SEND OUTPUT TO: css/

Setting up watches.  Beware: since -r was given, this may take a while!
Watches established.
********
COMPILING: scss/test/files/test_file.scss
OUTPUT: css/test_file.css

done.
**********
```
_NOTE: When you specify an output directory, the CSS file will just go straight to that directory. If you want to maintain the subdirectories of the file changes, use the `-s` flag._

### Maintain Subdirectories
If you want the output to maintain the same subdirectories as the changed file, you can use the `-s` flag. This flag will maintain the subdirectories and make any directories that do not exist before putting the file there. _NOTE: If you do not specify an output directory, the script will maintain the subdirectories by default, so you do not need to use this flag_

#### WITHOUT THE -S FLAG (DEFAULT WHEN OUTPUT IS SPECIFIED)
```
/bin/bash sassy_demon.sh -w scss/ -o css/
--------------------------
WATCHING DIRECTORY: scss/
WILL SEND OUTPUT TO: css/

Setting up watches.  Beware: since -r was given, this may take a while!
Watches established.
********
COMPILING: scss/test/files/test_file.scss
OUTPUT: css/test_file.css

done.
**********
```
#### WITH THE -S FLAG (DEFAULT WHEN OUTPUT IS NOT SPECIFIED)
```
/bin/bash sassy_demon.sh -w scss/ -o css/ -s
--------------------------
WATCHING DIRECTORY: scss/
WILL SEND OUTPUT TO: css/

OUTPUT WILL CONTAIN SUBDIRECTORIES

Setting up watches.  Beware: since -r was given, this may take a while!
Watches established.
********
COMPILING: scss/test/files/test_file.scss
OUTPUT: css/test/files/test_file.css

done.
**********
```

_Notice how the script maintains the subdirectories without the need for the `-s` flag if only a watch directory is specified_
```
bin/bash sassy_demon.sh -w scss/
--------------------------
WATCHING DIRECTORY: scss/
WILL SEND OUTPUT TO: scss/

Setting up watches.  Beware: since -r was given, this may take a while!
Watches established.
********
COMPILING: scss/test/files/test_file.scss
OUTPUT: scss/test/files/test_file.css

done.
**********
```

## DEPENDENCIES
- This script requires `inotify-tools` and `sass` to be installed.
- The script also uses the `sass --sourcemap=none --cache=false` command, so make sure you have those. If your version of sass does not support those flags, there is a commented out `sass` command in the script that does not use them, so you can use that instead.
