+++
date = "2026-06-15T14:00:00+02:00"
draft = false
title = "cronx and the Value of Keeping Things Simple"
tags = ["cron", "go", "cronx", "task"]
categories = ["programming", "go"]
socialsharing = true
+++

# cronx and the Value of Keeping Things Simple

## Introduction

Scheduled tasks are one of those things that seem deceptively simple. Run a command at a particular time, repeat it periodically, and make sure it finishes.

The traditional `cron` utility has been doing exactly this for decades. Its simplicity is one of its greatest strengths. However, as soon as scheduled tasks become part of a more structured workflow, a few limitations start to emerge.

What happens when a job takes longer than expected? What if the previous execution is still running when the next one is triggered? What happens when a task fails, or when the scheduler itself is restarted? And, perhaps more importantly, how do we know what actually happened?

There are many sophisticated scheduling systems that address these problems. Some introduce databases, distributed components, message brokers, web interfaces, and additional infrastructure.

But not every scheduling problem needs a distributed platform.

**cronx started with a different question: how much functionality can we add while keeping the operational model as simple as possible?**

## The cost of unnecessary infrastructure

A scheduler should not become a project of its own.

For a small application, a development workstation, or a single Linux server, introducing a database server or a dedicated orchestration platform just to execute a few periodic tasks can be difficult to justify.

The infrastructure required to manage scheduled jobs can eventually become more complicated than the jobs themselves.

cronx takes a deliberately local approach. It is a small Go application built around four components:

- One executable.
- One TOML configuration file.
- One local SQLite database.
- One shared log file.

There is no database server, no network service, and no dedicated daemon manager.

The scheduler runs in the foreground. If it needs to remain active permanently, the operating system's service manager can take care of that responsibility.

This separation is intentional. Process supervision is an operating system concern, not necessarily something every application needs to reinvent.

The result is a tool that can be copied to a machine, configured, started, and inspected without introducing additional infrastructure.

## Configuration as an explicit contract

A scheduler needs to know two things about every job: when it should run and what it should execute.

In cronx, both are described in a single TOML file.

For example:

```toml
[scheduler]
max_parallel_jobs = 2

[jobs.backup]
schedule = "0 3 * * *"
command = "/usr/local/bin/backup"
args = ["--incremental"]
timeout = "30m"
retry = 2
overlap = "skip"
working_directory = "/var/lib/backup"
env = { TIER = "production" }
```

The configuration describes not only the schedule, but also the execution policy.

A job can have its own timeout, retry strategy, working directory, environment variables, and overlap behaviour.

This is important because scheduling and execution are different concerns.

Knowing that a task should start at 3 AM does not tell us what should happen if it is still running at 3:05 AM. Should another instance start? Should the new execution be discarded? Should it wait?

These decisions should be explicit rather than left to accidental behaviour.

cronx validates the entire configuration before starting anything, reporting configuration errors together instead of discovering them one execution at a time.

The configuration file also remains the source of truth. The scheduler reads it but never modifies it.

## Predictability is a security feature

One of the most important design decisions concerns how commands are executed.

Traditional shell-based scheduling often relies on command strings. This is convenient, but it also introduces an additional interpretation layer.

A command containing spaces, quotes, pipes, variable substitutions, or other shell metacharacters can have a meaning different from what its author intended.

cronx avoids this ambiguity.

A job is executed directly through the operating system's process API. The executable and its arguments are passed as separate values, without invoking a shell.

The executable must be specified using an absolute path, and arguments are passed verbatim.

This means that characters such as `;`, `|`, `$`, and `*` are treated as ordinary argument content rather than instructions to be interpreted.

The execution environment is also deliberately restricted. Jobs do not inherit the scheduler's environment variables. They receive a minimal environment and must explicitly declare any additional variables they need.

Each job runs in its own process group, allowing timeouts and scheduler shutdowns to terminate the processes started by that job rather than leaving background processes behind.

These decisions do not turn cronx into a sandbox. Jobs still run with the operating-system identity and filesystem permissions of the scheduler.

The objective is more modest, but important: make execution behaviour explicit, reduce unintended interactions, and avoid introducing unnecessary interpretation mechanisms.

Predictability is not a substitute for isolation, but it is a useful foundation for secure execution.

## Execution history is part of the system

Another important distinction between a basic scheduler and a more reliable one is the ability to understand what happened after a job was triggered.

A successful process launch does not necessarily mean a successful task.

A job might terminate with an error, exceed its timeout, be interrupted, or require multiple attempts before completing successfully.

cronx therefore treats execution history as a first-class part of its architecture.

Every execution attempt is recorded in a local SQLite database, including its status, start time, duration, exit code, and associated log information.

Retries are recorded individually, making it possible to distinguish an initial failure from a subsequent successful attempt.

Job output is collected in a shared log file. Each line is associated with its timestamp, job name, execution identifier, and process identifier.

The command-line interface provides several ways to inspect this information:

- `cronx list` shows configured jobs and their next execution times.
- `cronx status` reports the latest outcome of each job.
- `cronx history` displays previous execution attempts.
- `cronx logs` retrieves job output, with filtering and follow options.

This approach makes the scheduler relatively easy to inspect without requiring a monitoring platform or a graphical interface.

The database and logs are also ordinary local files. They can be examined with standard tools when necessary.

The underlying idea is simple: a system should not only execute tasks, but also leave enough evidence to explain its behaviour.

## Reliability without becoming a distributed system

Even a local scheduler needs to deal with failure.

The scheduler may be stopped unexpectedly. A job may take longer than expected. Two executions may overlap. A configuration may change while the scheduler is running.

cronx addresses these situations without introducing distributed coordination.

A maximum parallelism limit controls how many jobs can execute simultaneously. Each job defines its own overlap policy: `skip`, `allow`, or `queue`.

Timeouts stop jobs that exceed their configured execution time. The scheduler first sends `SIGTERM`, allowing processes to terminate gracefully, and then uses `SIGKILL` after the configured grace period.

When the scheduler restarts, executions left in progress by a previous process are closed in the history. Missed activations are not replayed by default, although individual jobs can request a single catch-up execution.

A lease on the local state prevents two scheduler instances from running against the same state simultaneously.

Configuration changes can also be applied without restarting the scheduler. Sending `SIGHUP` causes cronx to reload the configuration, while an invalid replacement is rejected without stopping the currently running scheduler.

None of these mechanisms requires a distributed architecture. They are local coordination problems, and a local solution is sufficient for the intended use cases.

## A small tool with a deliberate scope

There is a temptation in software development to keep adding features until a small tool gradually becomes a platform.

cronx deliberately avoids that direction.

It is not intended to replace Kubernetes, Airflow, or enterprise workflow orchestration systems. It does not provide distributed execution, job dependencies, or a central management interface.

Its purpose is narrower: provide dependable scheduling and execution management on a single machine, with a small operational footprint.

The implementation is written in Go and produces a self-contained executable. SQLite uses a pure Go driver, so there is no external C dependency.

Nix is available as an optional development and packaging environment, providing reproducible builds and a pinned toolchain without becoming a runtime requirement.

The project is still evolving, and its current 0.5.0 release should be considered an early release. Nevertheless, its core design is already usable for personal and single-machine deployments.

## Conclusion

The interesting part of building a small scheduler is not implementing another cron expression parser.

It is deciding where complexity belongs.

Some complexity is unavoidable. Jobs fail, processes overlap, configurations become invalid, and systems restart. Pretending these problems do not exist does not make a scheduler simpler; it merely makes its behaviour less predictable.

The alternative is to address these problems explicitly, while resisting the temptation to introduce infrastructure that does not solve a real requirement.

cronx follows this principle by combining a simple configuration model, direct process execution, local persistence, and an inspectable command-line interface.

The goal is not to build the most powerful scheduler.

**It is to build a scheduler that does what it is supposed to do, makes its behaviour understandable, and does not require an infrastructure project to keep it running.**

[cronx on GitHub](https://github.com/gscacco/cronx)
