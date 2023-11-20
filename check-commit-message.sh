#!/usr/bin/env bash

message=""
with_author=false
with_trello=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --author)
      with_author=true
      shift
      ;;
    --trello)
      with_trello=true
      shift
      ;;
    ".git/COMMIT_EDITMSG" | ".git/MERGE_MSG")
      message=""
      while read line; do
        message+=$line
      done < $1
      shift
      ;;
    *)
      message=$1
      shift
      ;;
  esac
done

author_example=""
author_regex=""
if $with_author; then
  author_example=" [user1]"
  author_regex=" \[([a-z0-9._-]+(/[a-z0-9._-]+)?)\]"
fi

project_example=""
project_regex="\[([A-Z]{2,5})-[0-9]{1,10}\]"
if $with_trello; then
  project_example=" or \"fix:$author_example [#0001] description message\""
  project_regex="\[(([A-Z]{2,5}-[0-9]{1,10})|#[0-9]{1,10})\]"
fi

commit_regex="^(feat|fix|hotfix|refactor|test|chore|docs|ci):$author_regex $project_regex .+|^(Merge) .+|^(Revert) .+|^(Initial commit)"
error_msg="Aborting commit.\nYour commit message should be in the following format.\nExample: \"fix:$author_example [AB-0001] description message\"$project_example"

if [[ ! $message =~ $commit_regex ]]; then
  echo -e "$error_msg"
  exit 1
fi
