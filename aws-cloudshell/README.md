# AWS CloudShell Cache Cleanup Script

## Overview

A Bash-based temporary file cleanup utility developed and tested in AWS CloudShell (Amazon Linux 2023).

This project demonstrates Linux file management, shell scripting, automated cleanup, dry-run execution, user confirmation, and activity logging in an AWS-managed shell environment.

## Environment

- Platform: AWS CloudShell
- Operating System: Amazon Linux 2023
- Shell: Bash
- Tools: find, rm, date, tee

## Features

- Scans a dedicated test directory.
- Identifies `.tmp` files older than 7 days.
- Dry-run mode by default.
- Requires explicit confirmation before deletion.
- Records cleanup activity in timestamped log files.
- Preserves recent temporary files.

## Project Structure

```text
aws-cloudshell/
├── cleanup.sh
├── README.md
├── logs/
└── test-cache/
    └── .gitkeep
