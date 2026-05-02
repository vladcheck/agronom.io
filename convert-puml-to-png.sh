#!/bin/zsh
set -euo pipefail

path_to_source_file="${PWD}/docs/erd.puml"
path_to_png_artifact="${PWD}/docs/erd.png"
path_to_plantuml_jar="${HOME}/plantuml-1.2026.2.jar"
verbose=0
quiet=0

# Коды ошибок
readonly EXIT_SUCCESS=0
readonly EXIT_GENERAL_ERROR=1
readonly EXIT_PATH_NOT_FOUND=2
readonly EXIT_PLANTUML_FAILED=3


usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -v, --verbose             Verbose (default: false) - print debug messages"
  echo "  -q, --quiet               Quiet (default: false)"
  echo "  -s, --source <file>       Source file (default: $path_to_source_file)"
  echo "  -o, --output <file>       Output file path (default: $path_to_png_artifact)"
  echo "  --plantuml <file>         PlantUML jar file (default: $path_to_plantuml_jar)"
  echo "  -h, --help                Display this help message"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose) verbose=1; shift ;;
    -q|--quiet) quiet=1; shift ;;
    -s|--source) path_to_source_file="$2"; shift 2 ;;
    -o|--output) path_to_png_artifact="$2"; shift 2 ;;
    --plantuml) path_to_plantuml_jar="$2"; shift 2 ;;
    -h|--help) usage; exit $EXIT_SUCCESS ;;
    *) echo "Unknown option: $1"; usage; exit $EXIT_GENERAL_ERROR ;;
  esac
done

# Функция нормализации пути через zsh-native модификаторы
# :A - абсолютный путь с разрешением симлинков, :h - голова (директория), :t - хвост (имя файла)
normalize_path() {
  local p="$1"
  # Если путь относительный, добавляем PWD перед нормализацией
  [[ "$p" != /* ]] && p="${PWD}/${p}"
  # :A резолвит путь, но если файл/директория не существует, вернет ошибку
  # Поэтому используем :A только для существующих путей, а для новых - просто чистим /./ и /../
  print -r -- "${p:A}"
}

# Проверка PlantUML jar
if [[ ! -f "$path_to_plantuml_jar" ]]; then
  echo "ERROR: file does not exist: $path_to_plantuml_jar"
  exit $EXIT_PATH_NOT_FOUND
fi
path_to_plantuml_jar="${path_to_plantuml_jar:A}"

# Проверка исходного файла
if [[ ! -f "$path_to_source_file" ]]; then
  echo "ERROR: file does not exist: $path_to_source_file"
  exit $EXIT_PATH_NOT_FOUND
fi
path_to_source_file="${path_to_source_file:A}"

# Проверка директории вывода (файл может не существовать)
output_dir="${path_to_png_artifact:h}"
if [[ ! -d "$output_dir" ]]; then
  echo "ERROR: file does not exist: $output_dir"
  exit $EXIT_PATH_NOT_FOUND
fi
# Нормализуем путь вывода: берем абсолютную директорию + имя файла
output_dir="${output_dir:A}"
output_filename="${path_to_png_artifact:t}"
path_to_png_artifact="${output_dir}/${output_filename}"

# PlantUML создаст файл с именем источника + .png
expected_generated_name="${path_to_source_file:t:r}.png"
expected_generated_path="${output_dir}/${expected_generated_name}"

if [[ $quiet -eq 0 ]] && [[ $verbose -eq 1 ]]; then
  echo "Source: $path_to_source_file"
  echo "Output dir for PlantUML: $output_dir"
  echo "Expected generated file: $expected_generated_path"
  echo "Final target path: $path_to_png_artifact"
  echo "PlantUML jar: $path_to_plantuml_jar"
fi

# Генерация
if ! java -jar "$path_to_plantuml_jar" -tpng "$path_to_source_file" -o "$output_dir" 2>&1; then
  echo "ERROR: PlantUML generation failed"
  exit $EXIT_PLANTUML_FAILED
fi

# Переименование результата
if [[ -f "$expected_generated_path" ]]; then
  if [[ "$expected_generated_path" != "$path_to_png_artifact" ]]; then
    mv "$expected_generated_path" "$path_to_png_artifact"
    [[ $quiet -eq 0 ]] && [[ $verbose -eq 1 ]] && echo "Renamed: $expected_generated_path -> $path_to_png_artifact"
  fi
  # Оптимизация
  if (( ${+commands[pngquant]} )) && [[ -f "$path_to_png_artifact" ]]; then
    pngquant --quality=65-80 --force "$path_to_png_artifact" &> /dev/null
    [[ $quiet -eq 0 ]] && [[ $verbose -eq 1 ]] && echo "Image optimized: $path_to_png_artifact"
  fi
  [[ $quiet -eq 0 ]] && echo "Done. Output: $path_to_png_artifact"
  exit $EXIT_SUCCESS
else
  echo "ERROR: PNG artifact was not generated at $expected_generated_path"
  exit $EXIT_PLANTUML_FAILED
fi
