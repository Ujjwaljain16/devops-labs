#!/bin/bash
# ==============================================================================
# Script Name : sysinfo.sh
# Purpose     : Collect and display system information, accept user input,
#               and export running process snapshot using file redirection.
# Author      : Ujjwal Jain
# ==============================================================================

# Ensure script halts on unhandled errors
set -e

# --- 1. Variables Definition ---
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
SYS_HOSTNAME=$(hostname)
SYS_USERNAME=$(whoami)

echo "=================================================="
echo "          SYSTEM INFORMATION REPORT               "
echo "=================================================="

# --- 2. Print Basic System Details ---
echo "Timestamp    : ${CURRENT_DATE}"
echo "Hostname     : ${SYS_HOSTNAME}"
echo "Current User : ${SYS_USERNAME}"
echo "--------------------------------------------------"

# --- 3. Print Disk Usage ---
echo "[+] Current Filesystem Disk Usage (df -h):"
df -h
echo "--------------------------------------------------"

# --- 4. Print Running Processes ---
echo "[+] Top Running Processes Snapshot (ps aux):"
ps aux | head -n 10
echo "--------------------------------------------------"

# --- 5. Interactive User Input (read -p) ---
echo "[?] Log Export Configuration"
read -p "Enter directory name to store process logs: " TARGET_DIR
read -p "Enter file name (e.g., process_report.txt): " TARGET_FILE

# Default fallback if user presses Enter
TARGET_DIR=${TARGET_DIR:-"system_reports"}
TARGET_FILE=${TARGET_FILE:-"process_report.txt"}

# --- 6. Directory and File Creation (mkdir & touch) ---
echo "[*] Creating directory: ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

FULL_PATH="${TARGET_DIR}/${TARGET_FILE}"
echo "[*] Creating target file: ${FULL_PATH}"
touch "${FULL_PATH}"

# --- 7. Output Redirection (>) ---
echo "[*] Storing running processes snapshot into ${FULL_PATH}..."
{
    echo "=================================================="
    echo "  PROCESS SNAPSHOT LOG - ${CURRENT_DATE}"
    echo "  Generated on: ${SYS_HOSTNAME} by ${SYS_USERNAME}"
    echo "=================================================="
    echo ""
    ps aux
} > "${FULL_PATH}"

echo "=================================================="
echo "[SUCCESS] Process log successfully saved to: ${FULL_PATH}"
echo "Total lines written: $(wc -l < "${FULL_PATH}")"
echo "=================================================="
