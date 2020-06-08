#!/usr/bin/env bash
#/ Usage: create-change-set.sh [-h] <prefix> <filename>
#/
#/ Create a Change Set
#/
#/ OPTIONS:
#/   -h | --help      Show this message.
#/   -d | --delete    Delete a change set before creation
#/
#/ Parameters
#/   prefix           A prefix for the stack name
#/   filename         A name for the stack name
#/
set -e

DELETE=0

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
  aws cloudformation delete-change-set \
    --change-set-name "$STACK_NAME" \
    --stack-name "$STACK_NAME"

#  echo "waiting for delete-change-set..."

#  aws cloudformation wait delete-change-set --stack-name "$STACK_NAME"
fi



if [[ "$FILE_NAME" = "ecs-cluster" ]]; then
  aws s3 cp cloudformation/"$FILE_NAME".yaml s3://cf-templates-codjsehan4rp-ap-northeast-1/"$FILE_NAME"

  aws cloudformation create-change-set \
    --change-set-name "$STACK_NAME" \
    --stack-name "$STACK_NAME" \
    --template-url https://s3-ap-northeast-1.amazonaws.com/cf-templates-codjsehan4rp-ap-northeast-1/"$FILE_NAME" \
    --parameters file://cloudformation/"$FILE_NAME".json \
    --capabilities CAPABILITY_NAMED_IAM

  aws s3 rm s3://cf-templates-codjsehan4rp-ap-northeast-1/"$FILE_NAME"
else
  aws cloudformation create-change-set \
    --change-set-name "$STACK_NAME" \
    --stack-name "$STACK_NAME" \
    --template-body file://cloudformation/"$FILE_NAME".yaml \
    --parameters file://cloudformation/"$FILE_NAME".json \
    --capabilities CAPABILITY_NAMED_IAM
fi


echo "waiting for change-set-create-complete..."

aws cloudformation wait change-set-create-complete \
  --change-set-name "$STACK_NAME" \
  --stack-name "$STACK_NAME" || {
    aws cloudformation describe-change-set \
      --change-set-name "$STACK_NAME" \
      --stack-name "$STACK_NAME" | jq -r '.StatusReason'
    exit 1
  }
#aws cloudformation wait change-set-create-complete \
#  --change-set-name "$STACK_NAME" \
#  --stack-name "$STACK_NAME"

#aws cloudformation describe-change-set \
#  --change-set-name "$STACK_NAME" \
#  --stack-name "$STACK_NAME" | jq '.Changes'
