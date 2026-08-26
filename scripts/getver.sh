#!/usr/bin/env bash
export LANG=C
export LC_ALL=C
[ -n "$TOPDIR" ] && cd $TOPDIR

GET_REV=$1

try_version() {
	[ -f version ] || return 1
	REV="$(cat version)"
	[ -n "$REV" ]
}

try_git() {
	# 检查是否存在 git 目录
	git rev-parse --git-dir >/dev/null 2>&1 || return 1

	# 获取当前分支的总提交次数
	REV_COUNT="$(git rev-list --count HEAD 2>/dev/null)"
	
	# 获取当前提交的简短哈希值 (7位)
	REV_HASH="$(git rev-parse --short HEAD 2>/dev/null)"

	# 组合成 OpenWrt 标准格式: r数字-哈希
	if [ -n "$REV_COUNT" ]; then
		REV="r$REV_COUNT-$REV_HASH"
		return 0
	fi

	return 1
}

try_hg() {
	[ -d .hg ] || return 1
	REV="$(hg log -r-1 --template '{desc}' | awk '{print $2}' | sed 's/\].*//')"
	REV="${REV:+r$REV}"
	[ -n "$REV" ]
}

# 依次尝试从 version文件、Git仓库、Hg仓库获取版本号
try_version || try_git || try_hg || REV="unknown"

# 输出最终的版本号
echo "$REV"

