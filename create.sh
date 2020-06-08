#!/usr/bin/env bash
#/ Usage: create.sh [-h] [-d] <prefix> <filename>
#/
#/ Create a CloudFormation stack.
#/
#/ OPTIONS:
#/   -h | --help                      Show this message.
#/   -d | --delete                    Delete a stack before creation
#/   -t | --termination-protection    Enable the termination-protection
#/
#/ Parameters
#/   prefix           A prefix for the stack name
#/   filename         A name for the stack name
#/
set -e

DELETE=0
TERMINATION_PROTECTION=

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
    '-d'|'--delete' )
      DELETE=1
      shift 1
      ;;
    '-t'|'--termination-protection' )
      TERMINATION_PROTECTION="--enable-termination-protection"
      shift 1
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

if [[ "$DELETE" = "1" ]]; then
  aws cloudformation delete-stack --stack-name "$STACK_NAME"
  echo "waiting for stack-delete-complete..."
  aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"
fi

if [[ "$FILE_NAME" = "ecs-cluster" ]]; then
  aws s3 cp cloudformation/"$FILE_NAME".yaml s3://cf-templates-codjsehan4rp-ap-northeast-1/"$FILE_NAME"

  aws cloudformation create-stack \
    "$TERMINATION_PROTECTION" \
    --stack-name "$STACK_NAME" \
    --template-url https://s3-ap-northeast-1.amazonaws.com/cf-templates-codjsehan4rp-ap-northeast-1/"$FILE_NAME" \
    --parameters file://cloudformation/"$FILE_NAME".json \
    --capabilities CAPABILITY_NAMED_IAM

  aws s3 rm s3://cf-templates-codjsehan4rp-ap-northeast-1/"$FILE_NAME"
else
  aws cloudformation create-stack \
    "$TERMINATION_PROTECTION" \
    --stack-name "$STACK_NAME" \
    --template-body file://cloudformation/"$FILE_NAME".yaml \
    --parameters file://cloudformation/"$FILE_NAME".json \
    --capabilities CAPABILITY_NAMED_IAM
fi

echo "waiting for stack-create-complete..."

aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME"
