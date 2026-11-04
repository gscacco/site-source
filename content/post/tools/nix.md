+++
date = "2026-11-04T00:00:00+00:00"
draft = false
title = "Nix, Docker, and the Difference Between a Build and an Environment"
subtitle = "A container preserves a system; Nix describes how that system was produced."
description = "Why reproducible builds depend on explicit inputs, and why Nix and Docker answer different questions."
categories = ["tools"]
tags = ["nix", "docker", "reproducible builds", "build systems"]
socialsharing = true
+++

This publication is a static site, which makes it sound simpler than it is. Markdown, templates, fonts, shortcodes, taxonomies, syntax highlighting, and RSS all pass through a specific version of Hugo. The result is not merely content. It is the output of a toolchain.

That distinction becomes important when the toolchain is installed globally on a machine. The command remains `hugo`, but the version behind it may change. A build can still succeed while producing subtly different HTML, links, or code highlighting. Months later, the question is no longer only whether the site builds. It is whether the pages can be reconstructed from the same starting conditions.

Nix is used here to make those starting conditions explicit.

## The build must know its inputs 🔧

The repository contains a `flake.nix` and a `flake.lock`. The first defines the development shell and the package that builds the site. The second pins the exact revision of `nixpkgs` from which that toolchain comes.

There is no instruction to install Hugo globally. Instead, the project brings its toolchain with it:

{{< terminal title="shell" >}}
$ nix develop
$ hugo server --buildDrafts --port 8080

$ nix build
{{< /terminal >}}

The development shell contains Hugo and the dependencies needed to run it. `nix build` produces the generated site as an output whose identity is derived from the source tree and the locked dependency graph.

The important part is not the command itself. It is the contract behind it: the build declares what it needs, and it does not quietly borrow a different compiler, library, or command-line tool from the host system.

For a publication, this is closer to editorial infrastructure than developer convenience. The archive should remain legible not only as text, but also as a build that can be repeated.

## What reproducibility actually means 🧱

A reproducible build begins with the same sources and the same declared inputs, and arrives at the same result. Nix provides the mechanisms to make those inputs explicit, isolate the build environment, and address outputs in the Nix store.

It does not make an arbitrary program deterministic by decree.

A compiler or generator can still depend on timestamps, locale, random values, unavailable network resources, or the order in which files are read. Nix makes the environment less mysterious; it does not remove every source of variation. Bit-for-bit reproducibility remains a property to test, not a label to assume.

For this site, the useful guarantee is narrower and more practical: the source, the Hugo version, and the build logic are all declared in one place. A future build does not have to begin with an improvised environment.

{{< callout type="note" title="A precise distinction" >}}
Nix controls the inputs and the construction environment. It cannot repair non-deterministic software or incorrect content. Reproducibility is an engineering property of the build, not a statement about the quality of what is built.
{{< /callout >}}

## Docker answers a different question 🐳

Docker and Nix are often compared because both can isolate dependencies. That similarity obscures a more fundamental difference in what they model.

A Dockerfile usually describes a sequence of operations that assembles a filesystem: start from a base image, update package indexes, install packages, copy files, and set a command. The resulting container image is an artifact. It can be tagged, distributed, and run consistently.

That image can be an excellent answer to a deployment problem. It does not, by itself, explain how it was produced. A build that starts with a mutable base tag or runs `apt-get update` depends on the state of remote repositories at that moment. Two builds of the same Dockerfile may therefore produce different images. Digests and careful pinning can reduce that gap, but Docker's primary abstraction remains the environment or artifact, not the derivation of that artifact from its inputs.

Nix inverts the centre of gravity. A derivation describes how an output is produced from declared inputs. The build is treated as a function of those inputs, and the resulting store path reflects that derivation. The output may be cached or rebuilt, but the recipe remains the unit of meaning.

{{< pullquote >}}
Docker records the world in which a program runs. Nix records how that world was constructed.
{{< /pullquote >}}

This is not an argument that Docker is unnecessary. Containers are useful for runtime isolation and deployment. Nix can build container images, and a container can contain software produced by Nix. The tools can be complementary precisely because they answer different questions: one packages an environment, the other describes its construction.

## Why this site uses Nix 📚

The publication does not need a container to serve static HTML. It needs to know which Hugo built the pages and how to return to that toolchain when the site is rebuilt.

The flake supplies the authoring shell and the reproducible build. The lock file turns a dependency update into a deliberate change rather than an invisible side effect. The Pages workflow still pins its own Hugo version for deployment, so keeping the two declarations aligned is part of maintenance. Nix is not a claim that every part of publishing has become reproducible; it is the part that makes the software boundary visible.

That boundary is modest, but it matters. A publication about software should be able to explain how its own pages are made. Nix is a precise answer to that small question, and a useful reminder that a container is not the same thing as a build.
