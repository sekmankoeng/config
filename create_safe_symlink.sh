#!/bin/bash
set -euo pipefail  # 严格模式：未定义变量报错/管道失败整体报错/非0退出立即终止

# ===================== 配置区（可按需调整） =====================
# 软链接目标目录（家目录）
LINK_TARGET_DIR="${HOME}"
# 日志文件路径（自动创建，记录操作明细）
LOG_FILE="${HOME}/create_symlink_$(date +%Y%m%d%H%M%S).log"
# 备份后缀（若目标存在真实文件/目录，自动备份）
BACKUP_SUFFIX=".bak_$(date +%Y%m%d%H%M%S)"
# ===================== 函数定义区 =====================

# 日志输出函数（同时打印到终端+写入日志）
log() {
    local LEVEL="$1"
    local MSG="$2"
    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$TIMESTAMP] [$LEVEL] $MSG" | tee -a "${LOG_FILE}"
}

# 校验参数是否为空
check_params() {
    if [ $# -eq 0 ]; then
        log "ERROR" "未传入任何文件参数！用法：$0 <文件1> <文件2> ..."
        exit 1
    fi
}

# 校验文件是否存在且为普通文件
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

# 创建软链接核心逻辑
create_symlink() {
    local SRC_FILE="$1"          # 源文件绝对路径
    local LINK_NAME="$2"         # 软链接名称（与源文件同名）
    local LINK_PATH="${LINK_TARGET_DIR}/${LINK_NAME}"  # 软链接完整路径

    # 1. 若目标是已存在的软链接：强制覆盖
    if [ -L "${LINK_PATH}" ]; then
        log "INFO" "发现已存在的软链接，强制覆盖：${LINK_PATH}"
        ln -sf "${SRC_FILE}" "${LINK_PATH}"
        return 0
    fi

    # 2. 若目标是真实文件/目录：先备份再创建
    if [ -f "${LINK_PATH}" ] || [ -d "${LINK_PATH}" ]; then
        local BACKUP_PATH="${LINK_PATH}${BACKUP_SUFFIX}"
        log "WARNING" "目标是真实文件/目录，先备份：${LINK_PATH} → ${BACKUP_PATH}"
        mv "${LINK_PATH}" "${BACKUP_PATH}" || {
            log "ERROR" "备份失败：${LINK_PATH}"
            return 1
        }
    fi

    # 3. 目标不存在/已备份：创建软链接
    ln -s "${SRC_FILE}" "${LINK_PATH}" || {
        log "ERROR" "创建软链接失败：${SRC_FILE} → ${LINK_PATH}"
        return 1
    }
    log "SUCCESS" "软链接创建成功：${SRC_FILE} → ${LINK_PATH}"
    return 0
}

# ===================== 主程序 =====================
# 初始化日志文件
touch "${LOG_FILE}" && chmod 600 "${LOG_FILE}"  # 仅当前用户可读写
log "INFO" "脚本启动，日志文件：${LOG_FILE}"

# 校验输入参数
check_params "$@"

# 遍历所有传入的文件参数
for FILE in "$@"; do
    # 步骤1：获取文件绝对路径（处理相对路径/当前目录）
    ABS_SRC_FILE=$(realpath -e "${FILE}" 2>/dev/null)
    if [ -z "${ABS_SRC_FILE}" ]; then
        log "ERROR" "无法获取绝对路径：${FILE}"
        continue
    fi

    # 步骤2：校验源文件合法性
    if ! check_file_exists "${ABS_SRC_FILE}"; then
        continue
    fi

    # 步骤3：提取文件名（用于软链接命名）
    FILE_NAME=$(basename "${ABS_SRC_FILE}")

    # 步骤4：创建软链接
    create_symlink "${ABS_SRC_FILE}" "${FILE_NAME}"
done

# 脚本结束
log "INFO" "脚本执行完成，详见日志：${LOG_FILE}"
exit 0
