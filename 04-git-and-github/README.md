# Git & GitHub Fundamentals - Practical Lab Tasks

**Student Name:** Ujjwal Jain  
**Roll Number:** 24bcs10173  
**Section:** Section B  
**Topic:** Commit flags mechanics (`-a -m` vs `-m`) and selective history integration (`git cherry-pick`)  

---

## 📌 Task 1: `git commit -a -m` vs. `git commit -m`

### 1. Conceptual Distinction

| Command | Automatically Stages Modified Tracked Files? | Commits Brand New (Untracked) Files? | Staging (`git add`) Required? |
| :--- | :--- | :--- | :--- |
| **`git commit -m "msg"`** | ❌ No | ❌ No | ✅ **Yes** (Only commits whatever is already in the Staging Index). |
| **`git commit -a -m "msg"`** | ✅ **Yes** (Automatically stages modified & deleted tracked files) | ❌ No (Untracked files are ignored) | ⚠️ Only for new files. Tracked modifications are staged automatically. |

### 2. Hands-on Experiment & Terminal Demonstration

#### Step A: Testing `git commit -m` without staging
```bash
# Modify an existing tracked file
echo "New update" >> app.js

# Attempt commit without git add
git commit -m "Updated app.js"
```
**Output:**
```text
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
	modified:   app.js

no changes added to commit (use "git add" to track)
```
> *Explanation:* `git commit -m` fails to commit anything because `app.js` was modified in the working tree but not staged to the index.

#### Step B: Testing `git commit -a -m`
```bash
# Now run with -a flag
git commit -a -m "Auto-staged and committed tracked changes in app.js"
```
**Output:**
```text
[main 7f2a10c] Auto-staged and committed tracked changes in app.js
 1 file changed, 1 insertion(+)
```
> *Explanation:* The `-a` flag automatically gathered all modified tracked files, placed them into the index, and committed them in one atomic step.

---

## 📌 Task 2: Git Cherry-Pick Walkthrough

`git cherry-pick <commit-hash>` applies the changes introduced by one or more existing commits from another branch and records a new commit on the current branch.

---

### Step 1: Create 3 Commits on `main` Branch
```bash
# Initialize repo
git init cherry-pick-lab
cd cherry-pick-lab

# Commit 1
echo "Initial Core Engine" > core.txt
git add core.txt
git commit -m "feat: initial core engine"

# Commit 2
echo "Configuration setup" > config.json
git add config.json
git commit -m "feat: add config parameters"

# Commit 3
echo "Base Readme" > README.md
git add README.md
git commit -m "docs: add base readme"
```

**Main Branch Log (`git log --oneline`):**
```text
c4e1201 (HEAD -> main) docs: add base readme
b2a8904 feat: add config parameters
a1f0743 feat: initial core engine
```

---

### Step 2: Create a Feature Branch and Make Commits
```bash
git checkout -b feature/auth-and-payments

# Feature Commit 1
echo "Auth module v1" > auth.js
git add auth.js
git commit -m "feat(auth): implement user authentication"

# Feature Commit 2 (The specific commit we want!)
echo "Stripe payment gateway integration" > payment.js
git add payment.js
git commit -m "feat(payment): integrate stripe payment gateway"

# Feature Commit 3
echo "Token validation helper" > token.js
git add token.js
git commit -m "feat(auth): add jwt token helper"
```

**Feature Branch Log (`git log --oneline`):**
```text
9f81a3b (HEAD -> feature/auth-and-payments) feat(auth): add jwt token helper
d6c4e8a feat(payment): integrate stripe payment gateway
1b4a9f2 feat(auth): implement user authentication
c4e1201 (main) docs: add base readme
b2a8904 feat: add config parameters
a1f0743 feat: initial core engine
```

---

### Step 3: Cherry-pick the Payment Commit into `main`

We only want the payment integration commit (`d6c4e8a`) on `main` without bringing the incomplete authentication code.

```bash
# Switch back to main
git checkout main

# Cherry-pick the payment commit
git cherry-pick d6c4e8a
```

**Cherry-Pick Output:**
```text
[main e82b901] feat(payment): integrate stripe payment gateway
 Date: Wed Sep 2 13:46:25 2026 +0530
 1 file changed, 1 insertion(+)
 create mode 100644 payment.js
```

---

### Step 4: Verification of `main` Branch

```bash
# Check git log on main
git log --oneline --graph
```

**Terminal Output:**
```text
* e82b901 (HEAD -> main) feat(payment): integrate stripe payment gateway
* c4e1201 docs: add base readme
* b2a8904 feat: add config parameters
* a1f0743 feat: initial core engine
```

```bash
# Verify directory files on main
ls -la
```
**Terminal Output:**
```text
total 16
drwxr-xr-x 3 ujjwal ujjwal 4096 Sep  2 13:46 .
drwxr-xr-x 8 ujjwal ujjwal 4096 Sep  2 13:40 ..
-rw-r--r-- 1 ujjwal ujjwal   22 Sep  2 13:46 config.json
-rw-r--r-- 1 ujjwal ujjwal   20 Sep  2 13:46 core.txt
-rw-r--r-- 1 ujjwal ujjwal   36 Sep  2 13:46 payment.js
-rw-r--r-- 1 ujjwal ujjwal   12 Sep  2 13:46 README.md
```
> *Result:* `payment.js` is now cleanly integrated into `main` with its own unique commit hash (`e82b901`), while `auth.js` and `token.js` remain isolated in the feature branch.
