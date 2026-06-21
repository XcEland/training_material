# Git and GitHub Lab

This lab gives common Git and GitHub commands for tracking project work, committing changes, creating branches, pulling updates, and pushing work to GitHub.

Run commands from the project root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
```

On Windows PowerShell:

```powershell
cd "$env:USERPROFILE\Desktop\Trainingcred Institute"
```

## Check Git

```bash
git --version
git status
```

## First-Time Git Setup

Set your name and email:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Check your settings:

```bash
git config --global --list
```

## Check Project Status

Show changed, new, and deleted files:

```bash
git status
```

Show file changes:

```bash
git diff
```

Show staged changes:

```bash
git diff --staged
```

## Add and Commit Changes

Add one file:

```bash
git add "Module 1/README.md"
```

Add all changed files:

```bash
git add .
```

Commit staged changes:

```bash
git commit -m "Add Module 1 lab notes"
```

Recommended commit message style:

```text
Add Git lab commands
Update SQL connection README
Create capstone project structure
Fix Module 2 index demo
```

## View Commit History

Show recent commits:

```bash
git log --oneline
```

Show commits with branch graph:

```bash
git log --oneline --graph --decorate --all
```

## Branches

Show local branches:

```bash
git branch
```

Create a new branch:

```bash
git branch module-1-work
```

Switch to a branch:

```bash
git switch module-1-work
```

Create and switch in one command:

```bash
git switch -c module-1-work
```

Switch back to main:

```bash
git switch main
```

## Pull Latest Changes

Pull latest changes from GitHub:

```bash
git pull
```

Pull latest changes from the main branch:

```bash
git pull origin main
```

Use `git status` before pulling so you know whether you have local changes.

## Push Changes to GitHub

Push current branch:

```bash
git push
```

Push a new branch for the first time:

```bash
git push -u origin module-1-work
```

## Merge a Branch

Switch to main:

```bash
git switch main
```

Pull the latest main branch:

```bash
git pull origin main
```

Merge another branch into main:

```bash
git merge module-1-work
```

Push the updated main branch:

```bash
git push
```

## Stash Temporary Work

Save uncommitted changes temporarily:

```bash
git stash
```

List stashed changes:

```bash
git stash list
```

Bring back the latest stash:

```bash
git stash pop
```

## Undo Safely

Unstage a file but keep the changes:

```bash
git restore --staged "Module 1/README.md"
```

Discard changes in one file:

```bash
git restore "Module 1/README.md"
```

Be careful with discard commands because they remove local edits.

## Common Workflow

```bash
git status
git pull
git switch -c module-1-lab-updates
git add .
git commit -m "Update Module 1 lab files"
git push -u origin module-1-lab-updates
```

Then open a pull request on GitHub if the project uses pull requests.

## Useful GitHub Commands

Check the remote GitHub URL:

```bash
git remote -v
```

Add a remote repository:

```bash
git remote add origin https://github.com/username/repository-name.git
```

Change the remote URL:

```bash
git remote set-url origin https://github.com/username/repository-name.git
```

Clone a repository:

```bash
git clone https://github.com/username/repository-name.git
```

## Good Habits

- Run `git status` often.
- Pull before starting work.
- Commit small, meaningful changes.
- Use clear commit messages.
- Do not commit passwords, `.env` files, database backups, or large course PDFs.
- Push work regularly so it is backed up on GitHub.

