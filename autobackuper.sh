#!/bin/bash

# workspace_path.txt faylini o'qish
workspace_dir=$(cat workspace_path.txt)

# Boshlang‘ich papkaga o‘tish
cd "$workspace_dir" || exit 1

# Har bir .git papkasi uchun
find ./ -type d -name ".git" | while read -r gitdir; do
  repo_dir=$(dirname "$gitdir")
  echo "➡ Kirilmoqda: $repo_dir"
  cd "$repo_dir" || continue

  # Joriy branchni saqlab olish
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  echo "📝 Joriy branch: $current_branch"

  # Backup branch mavjudligini tekshirish
  if git show-ref --verify --quiet refs/heads/backup; then
    echo "✅ backup branch mavjud — o'tyapti..."
    git checkout backup
  else
    echo "➕ backup branch mavjud emas — yaratilyapti..."
    git checkout -b backup
  fi

  # O‘zgartirishlar mavjudmi?
  if [ -n "$(git status --porcelain)" ]; then
    now=$(date +"%Y-%m-%d %H:%M:%S")
    git add .
    git commit -m "Backup: $now by script"
    git push origin backup
    git pull origin backup
    echo "✅ O‘zgartirishlar push qilindi"
  else
    echo "ℹ️ Hech qanday o‘zgartirish yo‘q, commit qilinmadi"
  fi

  # Joriy branchga qaytish
  git checkout "$current_branch"
  echo "🔙 Joriy branchga qaytildi: $current_branch"

  # Boshlang‘ich joyga qaytish
  cd - >/dev/null
done
