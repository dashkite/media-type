# Reference

## MediaType

### make

$make: specifier \to mediatype$

Returns a `MediaType` instance from either a string or an object. 

```coffeescript
import assert from "@dashkite/assert"
import { MediaType } from "@dashkite/media-type"

type = MediaType.make "text/html"
assert.equal type.data.type, "text"
```

### parse

$parse: specifier \to mediatype$

Parses a string specifier and constructs a new `MediaType` instance.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType } from "@dashkite/media-type"

type = MediaType.parse "text/html"
assert.equal type.data.type, "text"
```

### format

$format: value \to string$

Formats an existing `MediaType` instance or string back into a standard media type string representation.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType } from "@dashkite/media-type"

type = MediaType.parse "text/html; charset=utf-8"
assert.equal ( MediaType.format type ), "text/html; charset=utf-8"
```

### fromPath

$frompath: path \to mediatype$

Determines the media type from a provided file path extension.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType } from "@dashkite/media-type"

type = MediaType.fromPath "./hello.svg"
assert.equal type.data.type, "image"
```

### data

$data \to object$

Retrieves the structured underlying properties of the `MediaType` instance.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType } from "@dashkite/media-type"

type = MediaType.parse "text/html"
assert.deepEqual type.data, { type: "text", subtype: "html" }
```

### toJSON

$tojson: \to object$

Provides a standard serialization mechanism by returning the structured data.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType } from "@dashkite/media-type"

type = MediaType.parse "text/html"
assert.deepEqual type.toJSON(), { type: "text", subtype: "html" }
```

### format

$format: \to string$

Generates the media type string representation from the instance.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType } from "@dashkite/media-type"

type = MediaType.parse "text/html"
assert.equal type.format(), "text/html"
```

## Accept

### make

$make: candidates \to accept$

Creates an `Accept` instance from a string, an array, or an object.

```coffeescript
import assert from "@dashkite/assert"
import { Accept } from "@dashkite/media-type"

accept = Accept.make "text/html, application/json"
assert.equal accept.data.length, 2
```

### parse

$parse: specifier \to accept$

Parses an HTTP Accept header string and produces an `Accept` instance representing the preferred candidates.

```coffeescript
import assert from "@dashkite/assert"
import { Accept } from "@dashkite/media-type"

accept = Accept.parse "text/html, application/json"
assert.equal accept.data.length, 2
```

### format

$format: value \to string$

Formats an `Accept` configuration back into a comma-separated string of media types.

```coffeescript
import assert from "@dashkite/assert"
import { Accept } from "@dashkite/media-type"

accept = Accept.parse "text/html, application/json"
assert.equal ( Accept.format accept ), "text/html, application/json"
```

### matches

$matches: candidate, target \to boolean$

Evaluates whether a target media type aligns with the specified candidate.

```coffeescript
import assert from "@dashkite/assert"
import { Accept, MediaType } from "@dashkite/media-type"

candidate = { type: "*", subtype: "*" }
target = MediaType.parse "text/html"
assert.ok Accept.matches candidate, target
```

### data

$data \to array$

Retrieves the list of candidate objects maintained by the `Accept` instance.

```coffeescript
import assert from "@dashkite/assert"
import { Accept } from "@dashkite/media-type"

accept = Accept.parse "text/html"
assert.equal accept.data[0].type, "text"
```

### toJSON

$tojson: \to array$

Serializes the candidate list into a generic array.

```coffeescript
import assert from "@dashkite/assert"
import { Accept } from "@dashkite/media-type"

accept = Accept.parse "text/html"
assert.equal accept.toJSON()[0].type, "text"
```

### format

$format: \to string$

Serializes the `Accept` configurations as a standard HTTP header value.

```coffeescript
import assert from "@dashkite/assert"
import { Accept } from "@dashkite/media-type"

accept = Accept.parse "text/html"
assert.equal accept.format(), "text/html"
```

### supported

$supported: target \to boolean$

Evaluates if a target `MediaType` instance is supported by any candidate within the `Accept` collection.

```coffeescript
import assert from "@dashkite/assert"
import { Accept, MediaType } from "@dashkite/media-type"

accept = Accept.parse "text/html, application/json"
target = MediaType.parse "text/html"
assert.ok accept.supported target
```

### preferred

$preferred: targets \to array$

Filters the provided collection of targets and returns a subset that aligns with the preferences outlined by the candidates.

```coffeescript
import assert from "@dashkite/assert"
import { Accept, MediaType } from "@dashkite/media-type"

accept = Accept.parse "text/*;q=0.3, text/html;q=0.7"
targets = [
  MediaType.parse "text/html"
  MediaType.parse "image/jpeg"
]
preferred = accept.preferred targets
assert.equal preferred.length, 1
```
