+++
date = "2015-05-04T12:35:03+02:00"
draft = false
title = "Hugo - Static Site Generator"
slug = "hugo-static-site-generator"
description = "Why static site generation with Hugo can replace the database-backed machinery of a traditional CMS."
author = " G.Scacco"
tags = ["hugo", "web"]
categories = ["web"]
socialsharing = true
oglocale="en_US"
+++

An article does not change when a new reader arrives. Yet in a traditional CMS, the server rebuilds the page every time someone requests it.

The *Content Management Systems* (CMS) commonly used by bloggers are web applications backed by a database (usually MySQL) and implemented in a high-level language: PHP, Java, C#, and so on.

The database holds the articles, pages, and other information the CMS needs to operate.

When a user opens the site in a browser, the web server performs the following steps:

1. Parse the request.
2. Access and query the database.
3. Generate an HTML page.
4. Send the generated page.

All of this has a non-trivial cost in CPU, RAM, and I/O. As the number of connected users grows, the resources required grow with it.

The market has put a price on that requirement. Providers such as Aruba and HostGator charge an annual subscription whose cost increases with the performance requested.

But are all those resources *really* necessary?

Does every article page need to be generated on demand, or could it be generated once and served many times?

Static site generators reverse the model: generate once, serve many times.

## Hugo: generating instead of interpreting ⚡

{{< callout type="warning" title="A note on versions" >}}
This article was written in 2015. Commands using `yaourt`, the `hugo new post/...` path, and the `shiori` theme reflect Hugo and Arch Linux at that time. The current repository uses Nix, local templates, and a different configuration: this walkthrough explains the model, not how to reproduce the present publication step by step.
{{< /callout >}}

[Hugo](https://gohugo.io) is a static site generator written in Go. Its main characteristics are:

* Fast static rendering.
* Simple to use.
* Portable across platforms.
* Flexible.

Most importantly, it is open source.

## Installing Hugo and creating the site 📦

On Arch, there is an AUR package, so installing it is as simple as:

    $ yaourt hugo

Creating a site is then straightforward:

    $ mkdir my-blog
    $ cd my-blog
    $ hugo new site .

The `my-blog` directory will contain a site configuration file, `config.toml`. Edit it according to your needs. Its contents are simple and self-explanatory:

    baseurl = "http://yourSiteHere/"
    languageCode = "en-us"
    title = "My New Hugo Site"

We can now add the first article with:

    $ hugo new post/first-post.md

The command produces the following Markdown file:

    +++
    date = "2015-05-05T11:44:32+02:00"
    draft = true
    title = "First post"

    +++

Among the front matter fields, `draft` decides whether the content enters the generated site: if it is `true`, Hugo excludes it. The article text goes after the front matter, below the final `+++`.

Hugo can be customized with themes available on GitHub. To download them, run:

    $ git clone --recursive https://github.com/spf13/hugoThemes themes

## Previewing the site locally 👀

The application includes a small web server for previewing the site. Start it with:

    $ hugo server --theme=shiori --buildDrafts

The `theme` option selects the theme, while `buildDrafts` tells Hugo to include articles whose `draft` field is set to `true`.

## Generating the site 🚀

Once the article is complete, generate the final site with:

    $ hugo -t shiori

After this command, the `public` directory contains the files ready to publish.

## References 🔗

- [Hugo documentation](https://gohugo.io/documentation/)
- [Hugo themes](https://themes.gohugo.io/)
- [Nix flakes](https://wiki.nixos.org/wiki/Flakes)

