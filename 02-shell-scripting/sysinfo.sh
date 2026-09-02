#!/bin/bash
# ==============================================================================
# Script Name : sysinfo.sh
# Purpose     : Collect system information, user details, disk usage,
#               and export running process snapshot using file redirection.
# Student     : Ujjwal Jain (Roll No: 24bcs10173)
# Class       : DevOps Engineering - Section B
# ==============================================================================

set -e

# --- 1. Variables Definition ---
CURRENT_DATE=$(date)
SYS_HOSTNAME=$(hostname)
SYS_USERNAME=$(whoami)

echo "=================================================="
echo "          SYSTEM INFORMATION & LOG REPORT         "
echo "=================================================="

# --- 2. Print System Details ---
echo "Current Date & Time : ${CURRENT_DATE}"
echo "System Hostname     : ${SYS_HOSTNAME}"
echo "Logged-in User      : ${SYS_USERNAME}"
echo "--------------------------------------------------"

# --- 3. Disk Usage ---
echo "[+] Current Filesystem Disk Usage (df -h):"
df -h
echo "--------------------------------------------------"

# --- 4. Process Snapshot Preview ---
echo "[+] Top Running Processes (ps aux):"
ps aux | head -n 10
echo "--------------------------------------------------"

# --- 5. Interactive User Input (read -p) ---
echo "[?] Student Details & Export Configuration"
read -p "Enter your name: " STUDENT_NAME
read -p "Enter your roll number: " ROLL_NO
read -p "Enter your comment: " COMMENT
read -p "Enter directory name to store process logs [default: system_reports]: " TARGET_DIR

TARGET_DIR=${TARGET_DIR:-"system_reports"}
STUDENT_NAME=${STUDENT_NAME:-"Ujjwal Jain"}
ROLL_NO=${ROLL_NO:-"24bcs10173"}
COMMENT=${COMMENT:-"DevOps Shell Scripting Homework Completed"}

# --- 6. Directory & File Creation (mkdir & touch) ---
mkdir -p "${TARGET_DIR}"
LOG_FILE="${TARGET_DIR}/process.log"
touch "${LOG_FILE}"

# --- 7. Output Redirection (>) ---
{
    echo "=================================================="
    echo "         DEVOPS PROCESS SNAPSHOT LOG              "
    echo "=================================================="
    echo "Generated On   : ${CURRENT_DATE}"
    echo "Hostname       : ${SYS_HOSTNAME}"
    echo "User           : ${SYS_USERNAME}"
    echo "Student Name   : ${STUDENT_NAME}"
    echo "Roll Number    : ${ROLL_NO}"
    echo "Comment        : ${COMMENT}"
    echo "=================================================="
    echo ""
    ps aux
} > "${LOG_FILE}"

echo "--------------------------------------------------"
echo "Student Name : ${STUDENT_NAME}"
echo "Roll Number  : ${ROLL_NO}"
echo "Comment      : ${COMMENT}"
echo "=================================================="
echo "[SUCCESS] Process log successfully generated: ${LOG_FILE}"
echo "Total lines saved: $(wc -l < "${LOG_FILE}")"
echo "=================================================="
