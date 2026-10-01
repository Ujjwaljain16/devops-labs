# Assignment - Linux Fundamentals

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Linux Fundamentals (Session 01 & 02 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 01 & 02 tab

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task 1: Soft link vs. hard link.** Explain the conceptual difference between a symbolic link and a hard link, then demonstrate it hands on: create a file, link it both ways, inspect the inode numbers, delete the original, and show how each link behaves afterward.

**Task 2: `adduser` vs. `useradd`.** Explain the difference between the low level `useradd` binary and the interactive `adduser` wrapper script, then actually run `adduser` to create a real user and verify the resulting entry in `/etc/passwd`.

**Task 3: `journalctl`.** Learn the common `journalctl` flags for reading systemd journal logs, then run it against a real running service on the machine and read genuine log output from it.

**Task 4: Linux command cheat sheet.** Put together a categorized reference of the Linux commands used day to day in DevOps work: navigation, permissions, file inspection, process and system monitoring, and services and networking.

**Deliverables:** hands on command output for all three practical tasks, a command cheat sheet, screenshots, README.md.

## 2. Notes

The `adduser` step needed `sudo` and an interactive password prompt, which I could not run through an automated shell, so I ran that one myself directly in my own WSL terminal rather than skipping it or faking the output.

The real `adduser` session asked for optional GECOS fields (full name, room number, work phone, home phone), and I genuinely typed real values into the work phone and home phone fields during that run. Before committing the screenshot to this public repo, I covered both phone number fields with a black redaction bar. The verification step, `grep devops_test_user /etc/passwd`, still shows a real entry with the correct UID, GID, home directory, and shell, so the redaction does not affect what the task is actually checking.

For Task 3, I did not assume a convenient service was running. I checked `systemctl list-units` first and found `redis-server.service` genuinely active on the machine, so I read its real logs instead of a service that was not actually there. The `-- Boot <id> --` markers in the output are genuine, spanning several real reboots of this WSL instance across different days.

## 3. My completion checklist

- [x] Task 1: soft link vs. hard link, explained and demonstrated with real inode inspection and real deletion behavior
- [x] Task 2: `adduser` vs. `useradd`, explained and demonstrated with a real interactive `adduser` run (phone number fields redacted before committing)
- [x] Task 3: `journalctl`, explained and demonstrated against a real running service with real multi boot log output
- [x] Task 4: Linux command cheat sheet, covering navigation, permissions, file inspection, monitoring, and networking
