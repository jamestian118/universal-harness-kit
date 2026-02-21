#!/usr/bin/env bash
set -euo pipefail

# new_project.sh
# 作用：从 profiles/<lang>/template/ 复制骨架到 $HOME/Documents/Code/<project-name>/
# 说明：不做 OS 兼容性探测；默认目标环境为 macOS + bash + python3

usage() {
  cat <<'USAGE'
用法：
  ./new_project.sh <project-name> --lang <python|node|go|generic>

示例：
  ./new_project.sh demo-api --lang python
  ./new_project.sh web-tool --lang node
  ./new_project.sh cli-go --lang go
  ./new_project.sh misc --lang generic
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

PROJECT_NAME="$1"
shift || true

LANG="python"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang)
      LANG="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "未知参数：$1"
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$PROJECT_NAME" ]]; then
  echo "project-name 不能为空"
  exit 2
fi

case "$LANG" in
  python|node|go|generic) ;;
  *)
    echo "不支持的 lang：$LANG（支持：python|node|go|generic）"
    exit 2
    ;;
esac

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$KIT_DIR/profiles/$LANG/template"
DEST_ROOT="$HOME/Documents/Code"
DEST_DIR="$DEST_ROOT/$PROJECT_NAME"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "模板不存在：$SRC_DIR"
  exit 2
fi

if [[ -e "$DEST_DIR" ]]; then
  echo "目标目录已存在：$DEST_DIR"
  exit 2
fi

mkdir -p "$DEST_ROOT"
mkdir -p "$DEST_DIR"

# 复制模板（包含隐藏目录）
cp -R "$SRC_DIR/." "$DEST_DIR/"

# 占位符替换：__PROJECT_NAME__
python3 - <<PY
import os
import pathlib

root = pathlib.Path(r"$DEST_DIR")
project = r"$PROJECT_NAME"

def is_text_file(path: pathlib.Path) -> bool:
    # 简单判断：按扩展名过滤二进制；尽量避免误处理
    binary_ext = {
        ".png",".jpg",".jpeg",".gif",".pdf",".zip",".tar",".gz",".bz2",".xz",
        ".woff",".woff2",".ttf",".eot",".ico",".mp3",".mp4",".mov",".avi"
    }
    if path.suffix.lower() in binary_ext:
        return False
    # 排除 .git 目录（虽然模板里默认不含）
    parts = set(path.parts)
    if ".git" in parts:
        return False
    return True

for p in root.rglob("*"):
    if p.is_file() and is_text_file(p):
        try:
            s = p.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if "__PROJECT_NAME__" in s:
            p.write_text(s.replace("__PROJECT_NAME__", project), encoding="utf-8")
PY

# scripts 可执行
if [[ -d "$DEST_DIR/scripts" ]]; then
  chmod +x "$DEST_DIR/scripts/"* || true
fi

# git init + 配置 pre-commit hook + 首次 commit
cd "$DEST_DIR"
git init -q
git config core.hooksPath .githooks
HOOK_PATH=".githooks/pre-commit"
if [[ ! -e "$HOOK_PATH" ]]; then
  echo "缺少必需 hook：$DEST_DIR/$HOOK_PATH"
  exit 2
fi
if ! chmod +x "$HOOK_PATH" 2>/dev/null; then
  echo "无法设置 hook 执行权限：$DEST_DIR/$HOOK_PATH"
  exit 2
fi
if [[ ! -x "$HOOK_PATH" ]]; then
  echo "hook 不可执行：$DEST_DIR/$HOOK_PATH"
  exit 2
fi
git add -A
git commit -q --no-verify -m "init: scaffold from universal-harness-kit ($LANG profile)"

echo "✅ 已创建项目：$DEST_DIR"
echo "下一步："
echo "  cd $DEST_DIR"
echo "  ./scripts/setup"
echo "  ./scripts/verify"
