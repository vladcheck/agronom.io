#!/bin/zsh
set -euo pipefail

path_input=${1:A}
path_output=${2:A}

for file in ${path_input}/*.puml; do
  ./convert-puml-to-png.sh -s "$file" -o "${path_output}/${file:t:r}.png" -v
done
