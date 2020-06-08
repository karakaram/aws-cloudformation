#!/usr/bin/env bash
#/ Usage: validate.sh [-h] <filename>
#/
#/ Validate a specified template.
#/
#/ OPTIONS:
#/   -h | --help      Show this message.
#/
#/ Parameters
#/   filename         A filename for validation
#/
set -e

function usage {
  grep '^#/' <"$0" | cut -c 4-
}

DELETE=0

for OPT in "$@"
do
  case "$OPT" in
    '-h'|'--help' )
      usage
      exit 1
      ;;
    '--'|'-' )
      shift 1
      param+=( "$@" )
      break
      ;;
    -*)
      echo "Illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
      echo "Try '${progname} --help' for more information." 1>&2
      exit 1
      ;;
    *)
      if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
        param+=( "$1" )
        shift 1
      fi
      ;;
  esac
done

if [ "${#param[@]}" -eq 0 ]; then
    usage
    exit 1
fi

FILE_NAME="${param[0]}"

if [[ "$FILE_NAME" = "" ]]; then
  echo "Invalid Parameter: <filename> must be specified"
  echo ""
  usage
  exit 1
fi

aws cloudformation validate-template --template-body file://./cloudformation/"$FILE_NAME".yaml
