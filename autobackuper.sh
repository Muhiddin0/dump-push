#!/bin/bash

workspace_dir=$(cat workspace_path.txt)

cd "$workspace_dir" || exit 1

find ./ -type d -name ".git" | while read -r gitdir; do
  repo_dir=$(dirname "$gitdir")
  echo "➡ Kirilmoqda: $repo_dir"
  cd "$repo_dir" || continue

  current_branch=$(git rev-parse --abbrev-ref HEAD)
  echo "📝 Joriy branch: $current_branch"

  # O‘zgarishlar mavjudmi?
  if [ -n "$(git status --porcelain)" ]; then
    echo "🔐 O‘zgarishlar stash qilinmoqda..."
    git stash push -u -m "Auto-backup stash"
    stash_applied=true
  else
    stash_applied=false
  fi

  # backup branchga o'tish yoki yaratish
  if git show-ref --verify --quiet refs/heads/backup; then
    git checkout backup
  else
    git checkout -b backup
  fi

  # Agar stash bo'lsa, uni apply qilish
  if $stash_applied; then
    echo "📦 Stash qo‘llanmoqda..."
    git stash apply
    now=$(date +"%Y-%m-%d %H:%M:%S")
    git add .
    git commit -m "Backup: $now by script"
    git push origin backup
    echo "✅ Backup branchga push qilindi"

    # Agar merge conflict bo'lmasa, stashni tozalash
    git stash drop
  else
    echo "ℹ️ O‘zgartirishlar mavjud emas"
  fi

  # Joriy branchga qaytish
  git checkout "$current_branch"
  echo "🔙 Joriy branchga qaytildi: $current_branch"

  cd - >/dev/null
done
