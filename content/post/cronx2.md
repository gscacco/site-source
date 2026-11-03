+++
date = "2026-06-16T14:00:00+02:00"
draft = false
title = "Beyond Shell Commands: Designing Safer Process Execution"
description = "Designing process execution without a shell, with explicit environments, process groups, and timeouts."
tags = ["cron", "go", "cronx", "task"]
categories = ["programming", "go"]
socialsharing = true
+++

A command line is not a list of arguments. It is a small program for a shell.

Consider a scheduled task:

```bash
/usr/local/bin/backup --incremental
```

When entered in a terminal, this is not simply a program name followed by a list of arguments. It is an expression interpreted by a shell. The shell parses the command, expands variables, interprets special characters, and eventually starts the requested program.

That behaviour is convenient for an interactive user. It is less convenient for an application that already knows which program it wants to run.

Applications use external processes for tasks that would otherwise require additional libraries, complex integrations, or platform-specific implementations. The operating system already provides a direct mechanism: create a process, pass it arguments, wait for completion, and collect its output. Inserting a shell adds a second language between the application and that mechanism.

Shells are powerful tools. They provide command composition, pipelines, variable expansion, redirection, and a rich scripting language. Those capabilities are useful when writing scripts. They are not always necessary when an application simply needs to execute a program.

Using a shell when it is not required adds an interpretation layer, with all the ambiguity that comes with it. This matters most for applications that execute commands based on configuration files, user-defined parameters, or dynamically generated input.

The design of cronx provides an opportunity to explore a different approach: **treat process execution as an operating system operation, not as a shell scripting operation.**

## The hidden complexity of a command string 🧵

Consider a command containing user-controlled input:

```bash
/usr/bin/tool --name "some value"
```

If the application constructs this command by concatenating strings, the resulting behaviour may depend on how the shell interprets the input.

Characters such as `;`, `|`, `$`, backticks, and parentheses have special meanings in many shells.

An input that was intended to be a simple argument may become part of a shell expression.

This is the underlying mechanism behind command injection vulnerabilities.

The problem is not that shells are inherently insecure. The problem is that their interpretation capabilities are often introduced without a real requirement.

## Separating the executable from its arguments 🧩

Operating systems already provide a direct mechanism for creating processes.

On Unix-like systems, this functionality is based on the `exec` family of system calls. Windows provides equivalent process creation facilities.

Instead of passing a command string to be interpreted, an application can provide the executable and its arguments separately.

In Go, this is straightforward:

```go
cmd := exec.Command(
    "/usr/local/bin/backup",
    "--incremental",
)

err := cmd.Run()
```

The executable path and the arguments are passed as separate values.

No shell is started, and no shell parsing takes place.

An argument containing a semicolon remains an argument containing a semicolon. It does not become a command separator.

This distinction is fundamental.

The application is no longer asking another interpreter to decide what should be executed. It explicitly defines the process it wants to create.

This does not eliminate every possible security problem associated with process execution. For example, an attacker who can control the executable path may still cause an unintended program to run.

However, it removes an entire class of vulnerabilities associated with shell interpretation.

## Making execution explicit ⚙️

Avoiding the shell is only the first step.

A reliable process execution model should also make the execution context explicit.

A process inherits several characteristics from its parent, including environment variables, the current working directory, and operating-system permissions.

These inherited properties can introduce unexpected dependencies.

For example, a scheduled job might work correctly when executed manually but fail when started by a service because the service has a different environment or working directory.

The opposite situation is also possible: a job might accidentally inherit credentials or configuration values that were never intended to be available to it.

A more predictable execution model explicitly defines the relevant parameters:

- Executable path.
- Argument list.
- Working directory.
- Environment variables.
- Execution timeout.
- Output handling.
- Process termination behaviour.

cronx follows this approach.

The executable must be specified using an absolute path, avoiding ambiguities caused by differences in `PATH` between interactive sessions and background services.

Jobs receive a minimal environment rather than automatically inheriting the scheduler's environment. Additional variables must be explicitly declared in the configuration.

The working directory can also be specified independently for each job.

The result is a more deterministic execution context, with fewer dependencies on the environment in which the scheduler happens to run.

## Process groups and controlled termination 🛑

Starting a process is relatively easy. Stopping it reliably is a different problem.

Consider a scheduled job that starts another program:

```text
cronx
  └── backup.sh
        ├── compression-tool
        └── upload-tool
```

If the scheduler only tracks the initial process, terminating that process does not necessarily terminate all the processes it started.

This can leave orphaned processes running after the job has supposedly been stopped.

Timeouts introduce a similar problem. A process that exceeds its execution limit should be terminated, but simply sending a termination signal to the initial process may not be sufficient.

On Unix-like systems, process groups provide a useful mechanism for addressing this problem.

A process can be started in its own process group, allowing the scheduler to signal the group rather than only the initial process.

cronx uses this mechanism to manage the lifecycle of a job and its child processes.

When a timeout occurs or the scheduler shuts down, the termination sequence is controlled:

1. Send `SIGTERM` to the process group.
2. Allow a configurable grace period for processes to terminate.
3. Send `SIGKILL` if processes are still running.

This gives processes an opportunity to perform cleanup operations while still providing a deterministic upper bound on termination time.

There are platform-specific details involved in implementing this correctly, particularly on Windows, where process management uses different operating-system mechanisms.

The important architectural principle is that process ownership and process termination should be considered together.

## Timeouts are part of the execution contract ⏱️

A scheduled job should not be allowed to consume resources indefinitely simply because it was configured to run periodically.

Without timeouts, a task that becomes blocked or enters an unexpected state can remain active forever.

Eventually, it may prevent subsequent executions, consume available resources, or interfere with other jobs.

A timeout establishes an explicit execution boundary.

For example:

```toml
[jobs.backup]
schedule = "0 3 * * *"
command = "/usr/local/bin/backup"
timeout = "30m"
```

The configuration now expresses not only when the job should run, but also how long it is allowed to execute.

This is an important distinction.

A scheduler is not merely responsible for triggering processes. It is also responsible for managing their lifecycle.

Timeouts, termination signals, and process groups form part of the same execution contract.

## Execution control is not sandboxing 🚧

There is an important distinction worth making.

Avoiding shell interpretation, restricting inherited environment variables, and managing process groups improve the predictability and security of process execution.

However, these mechanisms do not isolate a process from the operating system.

A job executed by cronx still runs with the operating-system identity and permissions of the scheduler.

It can access files, network resources, and other system facilities according to those permissions.

In other words, cronx does not provide a sandbox.

A stronger isolation model would require operating-system facilities such as Linux namespaces, seccomp, mandatory access control, or dedicated execution identities.

These mechanisms address a different problem: restricting what an executed process is allowed to do, rather than controlling how it is started and terminated.

Keeping these responsibilities separate is important.

A scheduler should not claim to provide isolation merely because it avoids invoking a shell.

## A smaller contract 🧱

The most useful change in this design is not a new mechanism. It is a smaller contract.

A command string asks a shell to decide what the application meant. An executable path, an argument list, an explicit environment, a working directory, and a timeout state that meaning directly. The process can still fail, but it fails at the layer responsible for starting it.

That is why the absence of a shell matters. It is not a claim that the process is safe; it is a claim that the application no longer delegates interpretation it never asked for.

**Security often starts by removing unnecessary interpretation and making implicit behaviour explicit.**

The same reasoning applies to build systems, automation tools, application servers, and any software that executes external processes.

The objective is not to replace the shell.

It is to use the shell when its capabilities are actually needed, rather than making it an invisible dependency of every process execution.

The rule of thumb is modest but useful: if you need a language, use a shell; if you need a process, call the process API. The distinction is small in code and large in the number of surprises it removes.

## References 🔗

- [cronx on GitHub](https://github.com/gscacco/cronx)
- [cronx and the Value of Keeping Things Simple]({{< relref "/post/cronx.md" >}})
- [Making Scheduled Jobs Observable]({{< relref "/post/cronx3.md" >}})
- [Go `os/exec`](https://pkg.go.dev/os/exec)
- [OWASP: Command Injection](https://owasp.org/www-community/attacks/Command_Injection)
- [Linux `setpgid(2)`](https://man7.org/linux/man-pages/man2/setpgid.2.html)
