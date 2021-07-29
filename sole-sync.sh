#!/bin/bash

################################################################################################################
#
# WELCOME to SOLE-SYNC
# A quickie bash script to easily push/pull sites to/from a remote via RSYNC. It's inteded to help
# keep remotes and locals sync'd when .git or other methods aren't an option for you. Also,
# it's a much much faster than FTP for large sites and files.
#
# GETTING STARTED
# 1. Make this script global "sole-sync" or whatever you want to name your alias:
#    https://stackoverflow.com/questions/3560326/how-to-make-a-shell-script-global
# 2. Go to your project folder
# 3. Optionally create your sync-exclude and sync-preset file(s)
# 4. Run "sole-sync [OPTIONS]" and enjoy
#
# DOCS
# run "sole-sync --help", that's all there is
#
################################################################################################################

####################################################
# Configuration
####################################################

# Paths
LOCAL_PATH=./

# Source directory (can be overriden with command args)
src=

# Default preset file location (can be overriden with command args)
preset="${LOCAL_PATH}sync-preset"

# Default excludes file location (can be overriden with command args)
exclude="${LOCAL_PATH}sync-exclude"

# Default values
MODE=TEST
RSYNC_OPTIONS=rvc
OPT_DELETE=
OPT_DRY_RUN=--dry-run
OPT_EXCLUDES=
OPT_PORT=

# Colors
ESC_SEQ="\x1b["
C_END=$ESC_SEQ"39;49;00m"
C_RED=$ESC_SEQ"31;01m"
C_GREEN=$ESC_SEQ"32;01m"
C_YELLOW=$ESC_SEQ"33;01m"
C_BLUE=$ESC_SEQ"34;01m"
C_MAGENTA=$ESC_SEQ"35;01m"
C_CYAN=$ESC_SEQ"36;01m"

####################################################
# Setup
####################################################

# Script input parameters
# https://brianchildress.co/named-parameters-in-bash/
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"
    declare $param="$2"
  fi
  shift
done

# Check preset file
if [ -e ${preset} ]; then
  . ${preset}
  echo "Loading preset file from $preset"
fi

# Ensure required preset variables are set
if [ -z "$host" ] || [ -z "$path" ] || [ -z "$user" ]; then
  echo -e "${C_RED}🚫 Define host, path, and user in arguments or the preset file ${preset}${C_END}"
  exit 1
fi

# Inculde the exclude file if specified
if [ -e ${exclude} ]; then
  echo "Loading excludes from $exclude"
  OPT_EXCLUDES="--exclude-from=${exclude}"
fi

####################################################
# Option configuration based on settings
####################################################

# Port
if [ -n "${port+set}" ]; then
  OPT_PORT="-e 'ssh -p $port'"
fi

# Dry Run (--live)
# Don't do a dry run, do it for realsies
if [ -n "${live+set}" ]; then
  MODE=LIVE
  OPT_DRY_RUN=
fi

# Delete (--delete)
# Remove files that don't match in the destination
if [ -n "${delete+set}" ]; then
  OPT_DELETE=--delete
fi

# Pull (--pull)
# Defaults to push (local > remote)
if [ -n "${pull+set}" ]
  then
    SOURCE=$user@$host:$path$src
    DESTINATION=$LOCAL_PATH$src
  else
    SOURCE=$LOCAL_PATH$src
    DESTINATION=$user@$host:$path$src
fi

####################################################
# Help
####################################################

__HELP="
Usage: $(basename $0) [OPTIONS]

Options:
  --delete                  Remove unmatching files in the destination (default: false)
  --exclude [filepath]      Relative path to exclude file (default: ${exclude})
  --help                    Looks like you've already found it!
  --live                    Don't do a dry run, do it for R E A L (default: false)
  --port [number]           Specify a non-standard ssh port
  --preset [filepath]       Relative path to preset file (default: ${preset})
  --pull                    Pull from the remote (default: push)
  --src [path]              Local source directory (default: ${src})
  --<var> [string]          Any preset variables not defined in presets (host, path, user)

NOTE: Any of the options other than preset or help may be defined in your preset file(s).
"

if [ -n "${help+set}" ]; then
  echo -e "$__HELP";
  exit 1
fi

####################################################
# RSYNC execution
####################################################

CMD="rsync -$RSYNC_OPTIONS $OPT_PORT $OPT_DELETE $OPT_DRY_RUN $OPT_EXCLUDES $SOURCE $DESTINATION"

# Display the mode being run
if [ $MODE == "TEST" ]
  then
    echo -e "${C_YELLOW}🚀 Beginning $MODE sync...${C_END}"
  else
    echo -e "${C_GREEN}🚀 Beginning $MODE sync...${C_END}"
fi

# Execute it and handle any rsync errors
eval $CMD

if [ "$?" -eq "0" ]
  then
    echo '--------------------------------------------------------------------------'
    echo -e "${C_GREEN}✅ All done with $MODE run.${C_END}"
    echo "$CMD"
    echo '--------------------------------------------------------------------------'

    # Live reminder
    if [ $MODE != "LIVE" ]; then
      echo -e "If everything looks good, add the ${C_CYAN}--live${C_END} argument to run for realsies"
    fi
else
  echo -e "🚫 ${C_RED}Error while running rsync: See output above 👆🏼${C_END}"
  echo -e "COMMAND: ${C_YELLOW}$CMD${C_END}"
fi
