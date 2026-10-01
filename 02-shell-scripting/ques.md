# Assignment - Shell Scripting

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Shell Scripting (Session 03 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 03 tab

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task: System Information Script.** Write a Bash script that pulls together basic system information and logs it to a file. The script needed to print the current date and time, the system hostname, the logged-in username, filesystem disk usage, and running processes. It also had to use variables to store and manipulate that data, prompt me interactively with `read -p` for my name, roll number, a comment, and a target directory, create that directory with `mkdir -p`, create a log file inside it with `touch`, and then redirect the full process output into that log file with `>`.

**Deliverables:** the `sysinfo.sh` script itself, a terminal run showing the script executing end to end with real system output, a screenshot of that run, and a verification step showing the generated `process.log` with `cat`.

## 2. Notes

I wrote `sysinfo.sh` to cover every piece of the spec in one pass rather than splitting it into separate scripts: system info first, then the interactive prompts, then the directory and file creation, then the redirection into the log. I re-ran the script during a later audit of this repo, independently of my original run, and it reproduced the same real hostname, the same kind of process list, and a correctly generated `process.log`, so I know the output in the README is genuine and not a one-off.

## 3. My completion checklist

- [x] Script prints current date and time, hostname, and logged-in username
- [x] Script prints filesystem disk usage with `df -h` and running processes with `ps aux`
- [x] Script uses variables throughout to store and manipulate data
- [x] Script prompts for name, roll number, comment, and target directory with `read -p`
- [x] Script creates the target directory with `mkdir -p` and the log file with `touch`
- [x] Script redirects full process output into `process.log` with `>`
- [x] Terminal output and screenshot captured from a real run
- [x] Re-ran the script independently to confirm the output is reproducible and genuine
