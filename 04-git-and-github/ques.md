# Assignment - Git and GitHub Fundamentals

**Course:** SST DevOps & Cloud [SWE]
**Lecture:** Git and GitHub Fundamentals (Session 05 per the LMS schedule)
**Source:** "DevOps Homework" tracking doc, Session 05 tab

The commands, real output, and screenshots for everything below are in [README.md](README.md).

---

## 1. What's required

**Task 1: `git commit -a -m` vs. `git commit -m`.** Explain the conceptual difference between the two commit forms, then demonstrate it hands on: modify a tracked file, show `git commit -m` correctly refusing to commit it unstaged, then show `git commit -a -m` auto staging and committing it in one step.

**Task 2: Git cherry-pick.** Learn what `git cherry-pick` does, then demonstrate it end to end in a real scratch repository: create commits on `main`, branch off and create several commits on a feature branch, cherry-pick a single specific commit back onto `main`, and verify that only that commit's change made it across while the rest of the feature branch stays isolated.

**Deliverables:** real git command output for both tasks, a working cherry-pick walkthrough, screenshots, README.md, submission of the repo link.

## 2. Notes

I did all of this hands on in a disposable scratch repository (`~/git-cherry-pick-lab`) rather than describing it abstractly, so every commit hash in the README is real and was actually produced on this machine.

The cherry-pick step includes a genuine mistake that I kept in the writeup instead of quietly editing it out. On my first attempt I copy pasted the literal placeholder `<paste-that-hash-here>` straight into the terminal instead of substituting the real commit hash, and bash correctly rejected it as invalid redirection syntax. I think that is worth keeping visible since it is an honest, easy to make mistake, and the corrected re-run right after it with the actual hash (`d6fbec4`) shows the fix and the real resulting commit (`2307302`).

The final verification step confirms the cherry-pick did exactly what it should: `payment.js` is present on `main` under its own commit, while `auth.js` and `token.js` from the rest of the feature branch never appear there at all.

## 3. My completion checklist

- [x] Task 1: `git commit -a -m` vs. `git commit -m`, explained and demonstrated with real commit hashes
- [x] Task 2: commits created on `main`, then a feature branch with its own separate commits
- [x] Task 2: cherry-pick performed for real, including the genuine placeholder mistake and its correction, kept honest rather than edited out
- [x] Task 2: final verification that only the cherry-picked commit's file made it onto `main`
