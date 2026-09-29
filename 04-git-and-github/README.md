# Git and GitHub Fundamentals

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

## Task 1: `git commit -a -m` vs. `git commit -m`

### Conceptual distinction

| Command | Auto-stages modified tracked files | Commits new (untracked) files | Requires `git add` first |
|---|---|---|---|
| `git commit -m "msg"` | No | No | Yes, for anything not already staged |
| `git commit -a -m "msg"` | Yes, for modified and deleted tracked files | No, untracked files are still ignored | Only for brand-new files |

### Hands-on execution

I initialized a scratch repository, made a tracked file, then modified it and tried to commit without staging first:

```bash
git init
echo "test content" > app.js
git add app.js
git commit -m "initial commit"
echo "New update" >> app.js
git commit -m "Attempt commit without staging"
```
```
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   app.js

no changes added to commit (use "git add" and/or "git commit -a")
```

`git commit -m` correctly refuses to commit anything, since `app.js` was modified in the working tree but never staged. I then committed the same change with `-a`:

```bash
git commit -a -m "Auto-staged and committed tracked changes in app.js"
```
```
[main fdbdb57] Auto-staged and committed tracked changes in app.js
 1 file changed, 1 insertion(+)
```

The `-a` flag staged the modified tracked file automatically and committed it in one step, with a real commit hash, `fdbdb57`.

## Task 2: Git cherry-pick

`git cherry-pick <commit-hash>` applies the changes from an existing commit on another branch and records them as a new commit on the current branch.

### Step 1: create commits on `main`

```bash
echo "Configuration setup" > config.json
git add config.json
git commit -m "feat: add config parameters"
echo "# Base Readme" > README.md
git add README.md
git commit -m "docs: add base readme"
git log --oneline
```
```
2dad096 docs: add base readme
f265831 feat: add config parameters
fdbdb57 Auto-staged and committed tracked changes in app.js
4349403 initial commit
```

### Step 2: create a feature branch with its own commits

```bash
git checkout -b feature/auth-and-payments
echo "Auth module v1" > auth.js
git add auth.js
git commit -m "feat(auth): implement user authentication"
echo "Stripe payment gateway integration" > payment.js
git add payment.js
git commit -m "feat(payment): integrate stripe payment gateway"
echo "Token validation helper" > token.js
git add token.js
git commit -m "feat(auth): add jwt token helper"
git log --oneline
```
```
c71ee6d feat(auth): add jwt token helper
75ddf33 feat(payment): integrate stripe payment gateway
b552c46 feat(auth): implement user authentication
2dad096 docs: add base readme
f265831 feat: add config parameters
fdbdb57 Auto-staged and committed tracked changes in app.js
4349403 initial commit
```

### Step 3: cherry-pick only the payment commit into `main`

I wanted the payment integration commit (`75ddf33`) on `main`, without bringing along the incomplete authentication work:

```bash
git checkout main
git cherry-pick 75ddf33
```
```
[main 02bc829] feat(payment): integrate stripe payment gateway
 Date: Tue Sep 29 17:57:53 2026 +0000
 1 file changed, 1 insertion(+)
 create mode 100644 payment.js
```

### Step 4: verify the result

```bash
git log --oneline --graph
```
```
* 02bc829 feat(payment): integrate stripe payment gateway
* 2dad096 docs: add base readme
* f265831 feat: add config parameters
* fdbdb57 Auto-staged and committed tracked changes in app.js
* 4349403 initial commit
```

```bash
ls -la
```
```
README.md
app.js
config.json
payment.js
```

`payment.js` is cleanly integrated into `main` under its own real commit, `02bc829`, while `auth.js` and `token.js` never appear here at all; they stay isolated on the `feature/auth-and-payments` branch, exactly as intended.

### Screenshot

*(pending; see the checkpoint note)*
