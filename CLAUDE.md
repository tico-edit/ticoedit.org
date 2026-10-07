# CLAUDE.md

This is the source for the tico editor project website, https://ticoedit.org.
The production site is served by GitHub Pages from the `docs/` directory.

## How the site is built

Pages are written in Markdown and turned into static HTML by `XOR`, the
maintainer's own Perl module (installed locally, not vendored in this repo).
`./build.pl` sets up XOR (`org => 'tico-edit'`, `site_name => 'tico'`) and runs the build.

```sh
./build.pl
```

The build needs network access: every run calls the GitHub API to regenerate
`docs/pod/`. If it fails in a sandbox or offline, that's the likely cause.

What the build does:

- Finds every `*.md` file under `docs/` (recursively) and writes a sibling `.html` file:
  `docs/foo.md` becomes `docs/foo.html`.
- If a page's first line is a Markdown heading, that heading becomes the page `<title>`
  and the header text. Otherwise the title falls back to the site name (`tico`).
- Uses the `simple` template by default. A file named `foo.NAME.md` renders with
  template `NAME` into `foo.html`. Templates are looked up in `./templates/NAME.html.tt`
  first, then in XOR's share dir (which provides `simple` and `wrapper`).
- Deletes `docs/pod/` and regenerates it from the POD in the release tarballs of the
  `tico-edit` GitHub org's repos.
- Copies a default `docs/favicon.ico` if one is missing.
- Regenerates `test.psgi`.

## Editing rules

- Edit the `.md` sources, never the generated `.html`. Run `./build.pl` afterward and
  commit both the `.md` and the regenerated `.html`, because GitHub Pages serves the
  committed HTML as-is and does not run the build.
- Don't hand-edit `test.psgi` or anything under `docs/pod/`. The build overwrites them.

## Local testing

`test.psgi` is a PSGI app (using `Plack::App::GitHubPages::Faux`) that serves `docs/`
roughly the way GitHub Pages does:

```sh
plackup test.psgi
```

It isn't a perfect copy of GitHub Pages, but it's close enough for the kinds of pages
on this site.

## CRT screenshots

Every page shows the toucan beside a white CRT monitor. The CRT shows tico editing
a small `hello.EXT` program, and a script in `templates/wrapper.html.tt` picks one
at random on each page load. Without JavaScript the page shows `hello-cxx-crt.png`.

The support files are in `extra/crt/`:

- `hello/hello.EXT`: the programs shown on the CRT. Each greets every name given
  on the command line, or "world" if there are none, and starts with a
  `hello.EXT: a friendly greeting from tico.` comment. A file must fit in tico's 20
  content rows and 80 columns.
- `crt.svg.in`: the CRT frame, drawn as SVG. `@SHOT@` is replaced by the 880x528
  screenshot, which sits on the screen at 1:1. The badge uses
  `docs/images/toucan-icon.svg`.
- `capture.sh`: runs `tico -I hello.EXT` in an 80x24 xterm (Bitstream Vera Sans
  Mono 13) under Xvfb, captures it, frames it, and writes
  `docs/images/hello-EXT-crt.png` (964x698). Give it extensions to redo only those
  (`extra/crt/capture.sh rs pl`); with no arguments it redoes every `hello.*`.

To add a language:

1. Write `extra/crt/hello/hello.EXT`, using an extension tico recognizes.
2. Have the user run `extra/crt/capture.sh EXT` themselves. Xvfb can't run inside
   Claude Code's sandbox, and the auto-mode classifier rejects opening it on a TCP
   port instead. Xvfb also needs `/tmp/.X11-unix` to exist and be owned by root; if
   it's missing, the user must run `sudo mkdir -m 1777 /tmp/.X11-unix` in a real
   terminal, since `sudo` can't prompt for a password from a `!` command.
3. Look at the image. Check that the whole file is on screen and the highlighting
   is right. If highlighting is wrong, it's probably a tico bug worth reporting.
4. Add `['EXT', 'a LANGUAGE program']` to the `hellos` list in
   `templates/wrapper.html.tt` (the second item completes the image's alt text),
   then run `./build.pl`.
5. Commit the source file, the PNG, the template, and the regenerated `.html`.
