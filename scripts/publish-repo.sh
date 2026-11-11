#!/usr/bin/env bash
# Publish this repository to GitHub / Gitee.
set -e
cd "$(dirname "$0")/.."

echo "============================================================"
echo "  ZhituAI - publish repository to GitHub / Gitee"
echo "============================================================"
echo
echo "Create an EMPTY PUBLIC repository first (no README / license)."
echo

if ! command -v git >/dev/null 2>&1; then
  echo "[ERROR] git not found."; exit 1
fi
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[ERROR] .git not found. Extract the GitRepo zip, not the submission zip."
  exit 1
fi

read -r -p "Paste the EMPTY repository HTTPS URL: " REPO_URL
if [ -z "$REPO_URL" ]; then echo "[ERROR] No URL entered."; exit 1; fi

echo "[1/3] Setting remote origin ..."
git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"

echo "[2/3] Renaming local branch to main ..."
git branch -M main

echo "[3/3] Pushing all commits ..."
git push -u origin main

echo
echo "[SUCCESS] Verify: repository is Public, README renders, history visible,"
echo "          no API keys / .env / data/ folder."
