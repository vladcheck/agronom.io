#!/bin/zsh
set -e

echo "ВНИМАНИЕ! Это действие ОПАСНО, оно удалит ВСЕ миграции, ВСЮ базу данных. Вы ТОЧНО хотите сделать это?"
read -r answer

if [ "$answer" = 'y' ] || [ "$answer" = 'yes' ]; then
  echo "Вы ТОЧНО уверены?"
  read -r answer
  if [ "$answer" = 'y' ] || [ "$answer" = 'yes' ]; then
    prisma db push --force-reset
    rm -rf prisma/migrations
    echo "Миграции и база данных полностью удалены."
    echo "Для создания новой базы данных запустите скрипт setup-prisma.sh, а для создания первой миграции - pnpm db:migrate"
  fi
fi
