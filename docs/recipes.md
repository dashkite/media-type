# Recipes

## Parsing a Media Type String

When receiving HTTP requests, you often need to understand the incoming `Content-Type` header.

The `@dashkite/media-type` package allows you to parse media type strings into structured objects. This enables you to easily inspect the type, subtype, and parameters without manual string manipulation.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType } from "@dashkite/media-type"

# retrieve header from request
header = "application/json; charset=utf-8"
type = MediaType.parse header

assert.equal type.data.type, "application"
assert.equal type.data.parameters.charset, "utf-8"
```

1. Import the `MediaType` class.
2. Provide the media type string to the `parse` method.
3. Access the structured components through the `data` property.

## Determining Media Type from a File Path

When serving static assets, you need to set the `Content-Type` header based on the file extension.

You can derive the correct media type for a given file path directly, avoiding the need for manual lookup tables.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType } from "@dashkite/media-type"

# determine path for a static asset
path = "./styles/main.css"
type = MediaType.fromPath path

assert.equal type.format(), "text/css"
```

1. Import the `MediaType` class.
2. Provide the relative or absolute file path to the `fromPath` method.
3. Format the resulting media type back into a string to use as an HTTP header value.

## Negotiating Content with Accept Headers

When a client requests a specific content format, you must negotiate the response type based on their `Accept` header and the formats your server supports.

The `Accept` class parses complex negotiation strings and can filter your supported formats to find preferred candidates.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType, Accept } from "@dashkite/media-type"

# client accept header
header = "text/*;q=0.3, text/html;q=0.7, application/json;q=0.8"
accept = Accept.parse header

# server supported formats
targets = [
  MediaType.parse "text/html"
  MediaType.parse "text/plain"
]

preferred = accept.preferred targets

assert.equal preferred.length, 2
assert.equal preferred[0].format(), "text/html"
assert.equal preferred[1].format(), "text/plain"
```

1. Import both `Accept` and `MediaType` classes.
2. Parse the client's `Accept` header string using `Accept.parse`.
3. Construct an array of `MediaType` instances representing the formats your server can produce.
4. Use the `preferred` method to filter the supported targets against the client's preferences.
