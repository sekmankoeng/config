#!/bin/bash
set -euo pipefail  # 严格模式（macOS bash 3.2 兼容）

# ===================== 配置区 =====================
LINK_TARGET_DIR="${HOME}"
LOG_FILE="${HOME}/create_symlink_$(date +%Y%m%d%H%M%S).log"
BACKUP_SUFFIX=".bak_$(date +%Y%m%d%H%M%S)"
# ===================== 函数定义区 =====================

# 日志输出函数
log() {
    local LEVEL="$1"
    local MSG="$2"
    # local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    # echo -e "[$TIMESTAMP] [$LEVEL] $MSG" | tee -a "${LOG_FILE}"
    echo -e "[$LEVEL] $MSG"
}

# 校验参数
check_params() {
    if [ $# -eq 0 ]; then
        log "ERROR" "未传入任何文件参数！用法：$0 <文件1> <文件2> ..."
        exit 1
    fi
}

# 校验文件存在且为普通文件
check_file_exists() {
    local FILE_PATH="$1"
    if [ ! -e "${FILE_PATH}" ]; then
        log "ERROR" "文件不存在：${FILE_PATH}"
        return 1
    elif [ ! -f "${FILE_PATH}" ]; then
        log "ERROR" "不是普通文件（可能是目录/设备文件）：${FILE_PATH}"
        return 1
    fi
    return 0
}

# 跨平台获取文件绝对路径（替换 Linux 的 realpath -e）
get_abs_path() {
    local FILE_PATH="$1"
    # macOS 用 python 替代 realpath（macOS 自带 python3）
    if [[ "$(uname -s)" == "Darwin" ]]; then
        ABS_PATH=$(python3 -c "import os; print(os.path.realpath('${FILE_PATH}'))" 2>/dev/null)
    else
        # Linux 保留 realpath
        ABS_PATH=$(realpath -e "${FILE_PATH}" 2>/dev/null)
    fi
    echo "${ABS_PATH}"
}

# 创建软链接核心逻辑
create_symlink() {
    local SRC_FILE="$1"
    local LINK_NAME="$2"
    local LINK_PATH="${LINK_TARGET_DIR}/${LINK_NAME}"

    # 覆盖已存在的软链接
    if [ -L "${LINK_PATH}" ]; then
        log "INFO" "发现已存在的软链接，强制覆盖：${LINK_PATH}"
        ln -sf "${SRC_FILE}" "${LINK_PATH}"
        return 0
    fi

    # 备份真实文件/目录
    if [ -f "${LINK_PATH}" ] || [ -d "${LINK_PATH}" ]; then
        local BACKUP_PATH="${LINK_PATH}${BACKUP_SUFFIX}"
        log "WARNING" "目标是真实文件/目录，先备份：${LINK_PATH} → ${BACKUP_PATH}"
        mv "${LINK_PATH}" "${BACKUP_PATH}" || {
            log "ERROR" "备份失败：${LINK_PATH}"
            return 1
        }
    fi

    # 创建软链接
    ln -s "${SRC_FILE}" "${LINK_PATH}" || {
        log "ERROR" "创建软链接失败：${SRC_FILE} → ${LINK_PATH}"
        return 1
    }
    log "SUCCESS" "软链接创建成功：${SRC_FILE} → ${LINK_PATH}"
    return 0
}

# ===================== 主程序 =====================
# 初始化日志（macOS 权限兼容）
#touch "${LOG_FILE}" && chmod 600 "${LOG_FILE}"
#log "INFO" "脚本启动，日志文件：${LOG_FILE}"

# 校验参数
check_params "$@"

# 遍历文件参数
for FILE in "$@"; do
    # 跨平台获取绝对路径
    ABS_SRC_FILE=$(get_abs_path "${FILE}")
    if [ -z "${ABS_SRC_FILE}" ]; then
        log "ERROR" "无法获取绝对路径：${FILE}"
        continue
    fi

    # 校验文件合法性
    if ! check_file_exists "${ABS_SRC_FILE}"; then
        continue
    fi

    # 提取文件名
    FILE_NAME=$(basename "${ABS_SRC_FILE}")

    # 创建软链接
    create_symlink "${ABS_SRC_FILE}" "${FILE_NAME}"
done

#log "INFO" "脚本执行完成，详见日志：${LOG_FILE}"
log "INFO" "脚本执行完成。"
exit 0
