# @dashkite/media-type

*Parse HTTP Media Types in JavaScript*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

This package provides utilities for analyzing and managing HTTP media types. It enables developers to construct, format, and negotiate content types based on standard HTTP conventions.

## Features

- Construct and parse standard media types
- Evaluate complex `Accept` header configurations
- Analyze detailed MIME type structures
- Generate media types dynamically from file paths

## Installation

```bash
pnpm install @dashkite/media-type
```

## Usage

You can parse an incoming media type string into a structured representation and validate candidates against an `Accept` header.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType, Accept } from "@dashkite/media-type"

# Parse a media type string
description = MediaType.parse "application/atom+xml; q=0.5"

assert.deepEqual description.data,
  type: "application"
  subtype: "atom+xml"
  parameters: q: "0.5"
  mime:
    base: "atom"
    suffix: "xml"
    type: "application"
    subtype: "xml"

# Check if a target media type is supported
accept = Accept.parse "text/*;q=0.3, text/html;q=0.7"
target = MediaType.parse "text/html"

assert.ok accept.supported target
```

## Other Resources

- [Reference](docs/reference.md)
- [Recipes](docs/recipes.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
