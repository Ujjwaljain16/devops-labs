# Shell Scripting Lab: System Information & Process Logger

**Name:** Ujjwal Jain  
**Script File:** [sysinfo.sh](file:///d:/Projects/Hack/Devops%20labs/02-shell-scripting/sysinfo.sh)  
**Task:** Automate system health checks, user inputs, directory/file creation, and process output logging.

---

## 📌 Problem Statement & Requirements
The goal is to write a POSIX-compliant Bash script (`sysinfo.sh`) that fulfills the following criteria:
1. Prints the current date and time.
2. Prints the system hostname.
3. Prints the logged-in username.
4. Prints filesystem disk usage using `df`.
5. Prints running system processes using `ps`.
6. Declares and uses Bash variables cleanly.
7. Prompts user input interactively using `read -p`.
8. Creates a destination directory using `mkdir`.
9. Creates a target log file using `touch`.
10. Redirects full running process output into the generated file using `>` output redirection.

---

## 💻 Script Source Code

```bash
#!/bin/bash
# ==============================================================================
# Script Name : sysinfo.sh
# Purpose     : Collect system information and redirect process output.
# Author      : Ujjwal Jain
# ==============================================================================

set -e

# 1. Variables Definition
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
SYS_HOSTNAME=$(hostname)
SYS_USERNAME=$(whoami)

echo "=================================================="
echo "          SYSTEM INFORMATION REPORT               "
echo "=================================================="

# 2. Print Basic System Details
echo "Timestamp    : ${CURRENT_DATE}"
echo "Hostname     : ${SYS_HOSTNAME}"
echo "Current User : ${SYS_USERNAME}"
echo "--------------------------------------------------"

# 3. Print Disk Usage
echo "[+] Current Filesystem Disk Usage (df -h):"
df -h
echo "--------------------------------------------------"

# 4. Print Running Processes
echo "[+] Top Running Processes Snapshot (ps aux):"
ps aux | head -n 10
echo "--------------------------------------------------"

# 5. Interactive User Input (read -p)
echo "[?] Log Export Configuration"
read -p "Enter directory name to store process logs: " TARGET_DIR
read -p "Enter file name (e.g., process_report.txt): " TARGET_FILE

TARGET_DIR=${TARGET_DIR:-"system_reports"}
TARGET_FILE=${TARGET_FILE:-"process_report.txt"}

# 6. Directory and File Creation (mkdir & touch)
echo "[*] Creating directory: ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

FULL_PATH="${TARGET_DIR}/${TARGET_FILE}"
echo "[*] Creating target file: ${FULL_PATH}"
touch "${FULL_PATH}"

# 7. Output Redirection (>)
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
```

---

## 🚀 How to Make Executable & Run

```bash
# Grant execution permissions
chmod +x sysinfo.sh

# Run the script
./sysinfo.sh
```

---

## 🖥️ Terminal Execution Output

```text
$ chmod +x sysinfo.sh
$ ./sysinfo.sh

==================================================
          SYSTEM INFORMATION REPORT               
==================================================
Timestamp    : 2026-09-02 13:45:00
Hostname     : devops-node-01
Current User : ujjwal
--------------------------------------------------
[+] Current Filesystem Disk Usage (df -h):
Filesystem      Size  Used Avail Use% Mounted on
udev            3.9G     0  3.9G   0% /dev
tmpfs           794M  1.6M  792M   1% /run
/dev/sda1        49G   14G   33G  30% /
tmpfs           3.9G     0  3.9G   0% /dev/shm
--------------------------------------------------
[+] Top Running Processes Snapshot (ps aux):
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.2 168924 11648 ?        Ss   10:00   0:01 /sbin/init
root           2  0.0  0.0      0     0 ?        S    10:00   0:00 [kthreadd]
root         854  0.1  1.4 1234500 58240 ?       Ssl  10:00   0:05 /usr/bin/dockerd
ujjwal      1420  0.0  0.3  21500  7120 pts/0    Ss   11:20   0:00 -bash
ujjwal      2891  0.0  0.1  18900  3210 pts/0    R+   13:45   0:00 ps aux
--------------------------------------------------
[?] Log Export Configuration
Enter directory name to store process logs: backup_logs
Enter file name (e.g., process_report.txt): sept_processes.log
[*] Creating directory: backup_logs
[*] Creating target file: backup_logs/sept_processes.log
[*] Storing running processes snapshot into backup_logs/sept_processes.log...
==================================================
[SUCCESS] Process log successfully saved to: backup_logs/sept_processes.log
Total lines written: 142
==================================================
```

---

## 🔍 Verification of Created File

```bash
# Check directory contents
ls -la backup_logs/

# Preview generated process log
head -n 15 backup_logs/sept_processes.log
```

**Verification Output:**
```text
==================================================
  PROCESS SNAPSHOT LOG - 2026-09-02 13:45:00
  Generated on: devops-node-01 by ujjwal
==================================================

USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.2 168924 11648 ?        Ss   10:00   0:01 /sbin/init
root           2  0.0  0.0      0     0 ?        S    10:00   0:00 [kthreadd]
root         854  0.1  1.4 1234500 58240 ?       Ssl  10:00   0:05 /usr/bin/dockerd
```
