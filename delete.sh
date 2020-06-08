#!/usr/bin/env bash
#/ Usage: delete.sh [-h] <prefix> <filename>
#/
#/ Delete a CloudFormation stack.
#/
#/ OPTIONS:
#/   -h | --help      Show this message.
#/
#/ Parameters
#/   <prefix>         A prefix for the stack name
#/   <filename>       A name for the stack name
#/
set -e

function usage {
  grep '^#/' <"$0" | cut -c 4-
}

if [ $# -eq 0 -o "$1" = "--help" -o "$1" = "-h" ]; then
  usage
  exit 2
fi

PREFIX=$1
FILE_NAME=$2

if [[ "$PREFIX" = "" ]]; then
  echo "Invalid Parameter: <prefix> must be specified"
  usage
  exit 1
fi

if [[ "$FILE_NAME" = "" ]]; then
  echo "Invalid Parameter: <filename> must be specified"
  usage
  exit 1
fi

AWS_PROFILE=training
STACK_NAME="$PREFIX"-"$FILE_NAME"

aws cloudformation delete-stack --stack-name "$STACK_NAME"
echo "waiting for stack-delete-complete..."
aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"
