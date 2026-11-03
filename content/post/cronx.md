+++
date = "2026-06-15T14:00:00+02:00"
draft = false
title = "cronx and the Value of Keeping Things Simple"
description = "A small Go scheduler built around explicit configuration, local persistence, and a deliberately narrow scope."
tags = ["cron", "go", "cronx", "task"]
categories = ["programming", "go"]
socialsharing = true
+++

Consider a backup scheduled for 3 AM. At 3:05 it is still running, and the next scheduler tick is due. Does the second run start? Does it wait? Does it get discarded? The command itself says nothing about the answer.

Scheduled tasks are one of those things that seem deceptively simple. Run a command at a particular time, repeat it periodically, and make sure it finishes.

The traditional `cron` utility has been doing exactly this for decades. Its simplicity is one of its greatest strengths. However, as soon as scheduled tasks become part of a more structured workflow, a few limitations start to emerge.

What happens when a job takes longer than expected? What if the previous execution is still running when the next one is triggered? What happens when a task fails, or when the scheduler itself is restarted? And, perhaps more importantly, how do we know what actually happened?

There are many sophisticated scheduling systems that address these problems. Some introduce databases, distributed components, message brokers, web interfaces, and additional infrastructure.

But not every scheduling problem needs a distributed platform.

**cronx started with a different question: how much functionality can we add while keeping the operational model as simple as possible?**

## The cost of unnecessary infrastructure 🧱

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

{{< diagram name="cronx-architecture" number="1" wide="true" caption="cronx keeps the scheduler local: one configuration file, one history database, one shared log, and a CLI that can inspect both stores." >}}

## Configuration as an explicit contract 📜

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

Knowing that a task should start at 3 AM does not tell us what should happen if it is still running at 3:05 AM. The overlap policy makes that decision explicit.

These decisions should be explicit rather than left to accidental behaviour.

cronx validates the entire configuration before starting anything, reporting configuration errors together instead of discovering them one execution at a time.

The configuration file also remains the source of truth. The scheduler reads it but never modifies it.

## Predictability is a security feature 🔒

One design decision shapes almost everything else: cronx does not hand command strings to a shell. It passes the executable and its arguments separately to the operating system, requires an absolute path, and gives each job a minimal environment.

Characters such as `;`, `|`, `$`, and `*` become ordinary argument content rather than instructions for another interpreter. Each job also runs in its own process group, so a timeout can stop the process tree instead of only the process that happened to be started first.

This removes a class of accidental behaviour, but it does not create a sandbox. Jobs still run with the scheduler's operating-system identity and permissions. Predictability and isolation are different goals, and conflating them is how small tools acquire misleading security claims.

The [next article]({{< relref "/post/cronx2.md" >}}) follows the execution path in detail, from `exec` to process groups and timeouts. Here the architectural point is enough: execution policy should be explicit rather than hidden in shell syntax.

## Execution history is part of the system 🧾

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

That evidence has two forms, because execution metadata and process output answer different questions. The [third article]({{< relref "/post/cronx3.md" >}}) examines how cronx stores them, how retries appear in the history, and what happens when the scheduler itself stops before recording a result.

## Reliability without becoming a distributed system 🛠️

Even a local scheduler needs to deal with failure.

The scheduler may be stopped unexpectedly. A job may take longer than expected. Two executions may overlap. A configuration may change while the scheduler is running.

cronx addresses these situations without introducing distributed coordination.

A maximum parallelism limit controls how many jobs can execute simultaneously. Each job defines its own overlap policy: `skip`, `allow`, or `queue`.

Timeouts stop jobs that exceed their configured execution time. The scheduler first sends `SIGTERM`, allowing processes to terminate gracefully, and then uses `SIGKILL` after the configured grace period.

When the scheduler restarts, executions left in progress by a previous process are closed in the history. Missed activations are not replayed by default, although individual jobs can request a single catch-up execution.

A lease on the local state prevents two scheduler instances from running against the same state simultaneously.

Configuration changes can also be applied without restarting the scheduler. Sending `SIGHUP` causes cronx to reload the configuration, while an invalid replacement is rejected without stopping the currently running scheduler.

None of these mechanisms requires a distributed architecture. They are local coordination problems, and a local solution is sufficient for the intended use cases.

## A small tool with a deliberate scope 🎯

There is a temptation in software development to keep adding features until a small tool gradually becomes a platform.

cronx deliberately avoids that direction.

It is not intended to replace Kubernetes, Airflow, or enterprise workflow orchestration systems. It does not provide distributed execution, job dependencies, or a central management interface.

Its purpose is narrower: provide dependable scheduling and execution management on a single machine, with a small operational footprint.

The implementation is written in Go and produces a self-contained executable. SQLite uses a pure Go driver, so there is no external C dependency.

Nix is available as an optional development and packaging environment, providing reproducible builds and a pinned toolchain without becoming a runtime requirement.

The project is still evolving, and its current 0.5.0 release should be considered an early release. Nevertheless, its core design is already usable for personal and single-machine deployments.

## Where the complexity belongs 🧭

The interesting part of building a small scheduler is not implementing another cron expression parser.

It is deciding where complexity belongs.

Some complexity is unavoidable. Jobs fail, processes overlap, configurations become invalid, and systems restart. Pretending these problems do not exist does not make a scheduler simpler; it merely makes its behaviour less predictable.

The alternative is to address them explicitly, while resisting the temptation to introduce infrastructure that does not solve a real requirement. cronx does that locally: explicit configuration, direct process execution, durable history, and a CLI that can inspect the result.

A local scheduler is not a lesser scheduler. It is a different scope with different obligations. The failure modes should fit on one machine, and the tools for investigating them should fit there too.

The goal is not to build the most powerful scheduler.

**It is to build a scheduler that does what it is supposed to do, makes its behaviour understandable, and does not require an infrastructure project to keep it running.**

## References 🔗

- [cronx on GitHub](https://github.com/gscacco/cronx)
- [Beyond Shell Commands: Designing Safer Process Execution]({{< relref "/post/cronx2.md" >}})
- [Making Scheduled Jobs Observable]({{< relref "/post/cronx3.md" >}})
- [Go `os/exec`](https://pkg.go.dev/os/exec)
- [SQLite](https://www.sqlite.org/)
- [TOML](https://toml.io/)
