# opengrok-css

OpenGrok CSS theme patches and a small local verification harness.

This repository does not fork OpenGrok UI code. It keeps OpenGrok's original stylesheet intact and appends small override files for dark/light themes, syntax colors, and an optional toolbar theme switcher.

## What's Included

- `dist/default/style-1.0.4.css`: local working stylesheet, built from the original OpenGrok CSS plus a selected theme override.
- `dist/default/style-1.0.4.original.css`: unmodified OpenGrok base stylesheet.
- `dist/default/theme-toggle.js`: optional `dark | light` toolbar switcher.
- `examples/themes/*.css`: ready-to-append theme overrides.
- `scripts/apply-theme.sh`: rebuilds the local working stylesheet from the base CSS plus a selected theme.
- `docker-compose.yml` and `docker/nginx.conf`: local OpenGrok verification only.

## Default Theme

The default local theme is:

```text
material-deepforest-light
```

It provides:

- `dark`: Material Theme Deepforest
- `light`: Material Theme Light
- a `dark | light` switcher in the right-aligned toolbar action area

In UI terminology, that top-right area is commonly called `trailing actions`, `right-aligned toolbar actions`, or a `toolbar end slot`.

## Apply A Theme Locally

```sh
./scripts/apply-theme.sh material-deepforest-light
```

Available themes:

```text
material-deepforest-light
synthwave84
monokai-dark
dracula
nord-dark
vscode-dark-plus
github-dark
```

The script creates:

```text
dist/default/style-1.0.4.css
```

from:

```text
dist/default/style-1.0.4.original.css
+ examples/themes/<theme>.css
```

## Local Verification

Prepare any source tree for OpenGrok to index. By default the script expects:

```text
src/openfoam-dev
```

Example:

```sh
mkdir -p src
git clone <your-source-repo> src/openfoam-dev
./scripts/opengrok-dev-up.sh
```

Or point to a source tree outside this repository:

```sh
OPENGROK_SOURCE_DIR=/path/to/source ./scripts/opengrok-dev-up.sh
```

Open:

```text
http://localhost:8081/xref/openfoam-dev/
```

The unmodified OpenGrok container is available at:

```text
http://localhost:8080/
```

CSS changes do not require reindexing. Edit `dist/default/style-1.0.4.css` and refresh the browser.

## Production Patch From OpenGrok Source

Starting from a clean OpenGrok clone:

```sh
git clone https://github.com/oracle/opengrok.git
cd opengrok
```

Patch this exact source file:

```text
opengrok-web/src/main/webapp/default/style-1.0.4.css
```

Recommended production flow:

1. Keep the original OpenGrok CSS.
2. Append one override from `examples/themes/*.css` to the end of `style-1.0.4.css`.
3. If using the `dark | light` switcher, copy `dist/default/theme-toggle.js` to `opengrok-web/src/main/webapp/default/theme-toggle.js`.
4. If using the switcher, add the small script hooks below to OpenGrok JSP fragments.
5. Build/package OpenGrok normally so `style-1.0.4.min.css` is regenerated.

Example CSS patch:

```sh
cat \
  opengrok-web/src/main/webapp/default/style-1.0.4.css \
  /path/to/opengrok-css/examples/themes/material-deepforest-light.css \
  > /tmp/style-1.0.4.css

mv /tmp/style-1.0.4.css opengrok-web/src/main/webapp/default/style-1.0.4.css
```

## Production Switcher Patch

For OpenGrok 1.14.x, add the initial theme script in:

```text
opengrok-web/src/main/webapp/httpheader.jspf
```

Place it inside `<head>`, before stylesheet links:

```html
<script>
(function(){
  try {
    document.documentElement.setAttribute("data-og-theme", localStorage.getItem("opengrok-theme") || "dark");
  } catch (e) {
    document.documentElement.setAttribute("data-og-theme", "dark");
  }
})();
</script>
```

Then add the switcher script in:

```text
opengrok-web/src/main/webapp/foot.jspf
```

Place it after `<%= PageConfig.get(request).getScripts() %>` and before `</body>`:

```html
<script src="<%= PageConfig.get(request).getCssDir() %>/theme-toggle.js"></script>
```

For local verification, the nginx proxy injects these two hooks automatically.

## Patching A Deployed Webapp

Prefer source patching when possible. If you must patch an already deployed webapp or Docker image, replace the file the browser actually requests:

```text
default/style-1.0.4.min.css
```

In the official Docker image this is typically under:

```text
/usr/local/tomcat/webapps/ROOT/default/style-1.0.4.min.css
```

This approach is harder to review and easier to lose during image upgrades.

## Creating A New Theme

The safest minimal change is to append an override block at the end of OpenGrok's existing CSS. Do not rewrite JSP files, JavaScript, or image paths unless the theme needs runtime switching or custom assets.

For most themes, change only:

- Page chrome: `body`, `#page`, `#content`, `#whole_header`, `#sbar`, `#bar`, `footer#footer`
- Tables and project lists: `table`, `thead`, `#dirlist`, `#results`, row hover and even rows
- Form controls: `input`, `select`, `textarea`, `button`, `.btn`, `input.q`
- Code background and line numbers: `div[id^='src']`, `pre`, `code`, `.l`, `.hl`
- Code syntax colors: `.c`, `.s`, `.n`, `.k`, `b`, `.b`, `a.xf`, `a.xm`, `a.xv`, etc.
- Optional switcher: `#bar ul`, `.og-theme-switcher`, `.og-theme-toggle`

OpenGrok syntax selector cheat sheet:

```text
div[id^='src'] .c       comments
div[id^='src'] .s       strings
div[id^='src'] .n       numbers
div[id^='src'] .k       keywords when emitted as classed spans
div[id^='src'] b        many C/C++ keywords such as const, void
div[id^='src'] .b       bold syntax tokens
a.xf, a.xmt, a.xsr      functions / methods
a.xm                    macros
a.xv                    variables
a.xfld, a.xmb           fields / members
a.xc, a.xt, a.xts       classes / types
a.xlbl                  labels
.l, .hl                 line number columns
```

## Using VS Code Themes

VS Code themes cannot be used directly as OpenGrok CSS because VS Code theme JSON uses TextMate scopes, while OpenGrok emits HTML classes. Copy the palette and map it to OpenGrok selectors.

Map VS Code `colors`:

```text
editor.background              -> --og-bg
editor.foreground              -> --og-text
editorLineNumber.foreground    -> --og-muted
editor.selectionBackground     -> --og-selection
sideBar.background             -> --og-panel
panel.background               -> --og-panel
input.background               -> input/select background
focusBorder                    -> --og-accent or --og-link
textLink.foreground            -> --og-link
```

Map VS Code `tokenColors` or semantic token colors:

```text
comment                        -> div[id^='src'] .c
string                         -> div[id^='src'] .s
constant.numeric               -> div[id^='src'] .n
keyword, storage               -> div[id^='src'] .k and div[id^='src'] b
entity.name.function           -> a.xf, a.xmt, a.xsr
entity.name.type, support.type -> a.xc, a.xt, a.xts
variable                       -> a.xv
variable.other.member          -> a.xfld, a.xmb
entity.name.tag, meta.macro    -> a.xm
```

## Spacing Terminology

- `padding`: inner space inside a control or container
- `margin`: outer space around an element
- `gap`: space between flex/grid children
- `gutter`: repeated spacing between columns or major layout tracks
- `alignment`: how items sit along the row or column axis

## Reindex

CSS changes do not require indexing. If the indexed source tree changes:

```sh
./scripts/opengrok-reindex.sh
```

Watch progress:

```sh
docker logs -f portfolio-opengrok
```

## Git Hygiene

This repository intentionally ignores local source trees and upstream clones:

```text
src/
vendor/
.opengrok/
```

Keep only theme patches, scripts, and documentation in Git.
