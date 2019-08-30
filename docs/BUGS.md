# GentoDAD Documentation
## Bug Guide

Is there a problem with the script?  Something not working as expected?  Please file an Issue!  This guide will help.

### Issue elligability

Due to the mutability of this script requiring the user to configure some things on their own, I cannot provide support for modified **code** .
If you have discovered a problem with **base functionality** of the script, you may file an issue.

"Base functionality" elligable for an issue:

- Bash errors (invalid syntax, expected errors)
- Execution errors (scripts run when they aren't supposed to, infinite loops, or lock ups)
- Script doesn't work although it appears that it should
- Script causes another script in the chain to work incorrectly
- Modified configurations (not code) do not produce a working system

### Issues / Bug Reports

To report an issue, please use the following template:

    **Commit number:** [ Specify the commit number in which the issue occoured ]

```
# Bug Report
**Proposed importance:** - One word describing how important you think this bug is - i.e.: 'minor, major, critical'

TEXT

**Commit Number:** - The commit number which you are reporting this bug for:

TEXT

## Problem Summary
In a few sentences, describe the problem

TEXT

## Expected Outcome
Describe what should be happening where the issue occoured

TEXT

## Actual Outcome
Describe what is actually happening

TEXT

## Logs
Attach any logs, screenshots, or relevant information that may help

TEXT

```

### Colleting log output

Please run the script ``debug.sh`` and collect the output.

When run in **debug mode**, the installer will collect as it runs:

1.  bash stacktrace output in ``~/debug_trace.log`` on the host livecd.
2.  stderror and stdout contents in ``~/debug_out.log`` on the host livecd.

> **Note:** your issue may not be resolved if you don't provide proper log output.

