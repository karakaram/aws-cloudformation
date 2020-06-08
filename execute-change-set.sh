#!/usr/bin/env bash
#/ Usage: execute-change-set.sh [-h] <prefix> <filename>
#/
#/ Create a Change Set
#/
#/ OPTIONS:
#/   -h | --help      Show this message.
#/
#/ Parameters
#/   prefix           A prefix for the stack name
#/   filename         A name for the stack name
#/
set -e

function usage {
  grep '^#/' <"$0" | cut -c 4-
}

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

PREFIX="${param[0]}"
FILE_NAME="${param[1]}"

if [[ "$PREFIX" = "" ]]; then
  echo "Invalid Parameter: <prefix> must be specified"
  echo ""
  usage
  exit 1
fi

if [[ "$FILE_NAME" = "" ]]; then
  echo "Invalid Parameter: <filename> must be specified"
  echo ""
  usage
  exit 1
fi

AWS_PROFILE=training
STACK_NAME="$PREFIX"-"$FILE_NAME"

aws cloudformation execute-change-set \
  --change-set-name "$STACK_NAME" \
  --stack-name "$STACK_NAME"

echo "waiting for stack-update-complete..."

aws cloudformation wait stack-update-complete --stack-name "$STACK_NAME"

#aws cloudformation wait stack-update-complete --stack-name "$STACK_NAME" || {
#  aws cloudformation describe-stack-events --stack-name "$STACK_NAME"
#  exit 1
#}
