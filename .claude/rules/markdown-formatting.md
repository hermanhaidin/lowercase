# Markdown Formatting

Notes are stored as markdown-formatted plain text files.

## Markdown Philosophy
- Markdown syntax remains visible
- Editor understands markdown tokens
- Syntax-aware rendering limited to possibilities of Geist Pixel Square font (no bold or italic)

## Shortcut Notation
In shortcut descriptions below, `|` represents the cursor position.

## Headings
- Syntax `#` up to `######`: `accent` color #BF98AB
- Text: `accent` color #BF98AB
- No bold heading text
- Shortcut button cycles: `# |` → `## |` → `### |` → `#### |` → `##### |` → `###### |` → plain text (no `#`)

```md
# heading 1
## heading 2
### heading 3
```

## Bold Text
- Syntax `** **` or `__ __`: `secondaryAccent` color #E6DEC2
- Text: `secondaryAccent` color #E6DEC2
- No bold text
- Shortcut toggles: adds `**|**`, pressing again removes markers → `|`

```md
**Bold text**
```

## Italic Text
- Syntax `* *` or `_ _`: `tertiaryAccent` color #70A6AD
- Text: `tertiaryAccent` color #70A6AD
- No italic text
- Shortcut toggles: adds `*|*`, pressing again removes markers → `|`

```md
*Italic text*
```

## Striked Out Text
- Syntax `~~ ~~`: `secondaryLabel` color #A6A6A6
- Text: `secondaryLabel` color #A6A6A6
- Strikethrough decoration on both syntax and text
- Shortcut toggles: adds `~~|~~`, pressing again removes markers → `|`

```md
~~Striked out text~~
```

## Inline Code
- Syntax `` ` ` ``: `accent` color #BF98AB
- Text: `accent` color #BF98AB, not monospaced
- Shortcut toggles: adds `` `|` ``, pressing again removes markers → `|`

```md
Text inside `backticks` on a line will be formatted like code.
```

## External Link
- Text in brackets `[]`: `secondaryLabel` color #A6A6A6
- URL in parentheses `()`: `tertiaryAccent` color #70A6AD, underlined
- `[]` and `()`: `label` color #FFFFFF, default
- Shortcut toggles: adds `[|]()`, pressing again removes markers only if both parts empty → `|`

```md
[aseprite](aseprite.org)
```

## Quote
- Syntax `>`: `secondaryLabel` color #A6A6A6
- Text: `secondaryLabel` color #A6A6A6
- Full line colored
- Shortcut toggles: adds `> |`, pressing again removes `> ` → `|`

```md
> this is a quote
```

## Lists

**Unordered list:**
- Syntax `- `: `accent` color #BF98AB (marker only)
- Text: `label` color #FFFFFF
- Shortcut toggles: adds `- |`, pressing again removes `- ` → `|`

```md
- First item
- Second item
- Third item
```

**Ordered list:**
- Syntax `1.` / `2.` / etc.: `accent` color #BF98AB (marker only)
- Text: `label` color #FFFFFF

```md
1. First item
2. Second item
3. Third item
```

**Nested lists:**
- Use indent shortcut buttons above keyboard to increase/decrease nesting level

## Horizontal Divider
- Syntax `***`, `* * *`, `---`, `- - -`, `___`, `_ _ _`: `accent` color #BF98AB
- Full line colored

```md
* * *
```

## Keyboard
- Auto-capitalization: **off**
- Auto-correction: **off**
- Smart quotes: **off**
- Text replacement: **off**

Capitalization is always intentional.
