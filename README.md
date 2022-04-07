# Media Type

Parse HTTP media types.

```coffeescript
import assert from "@dashkite/assert"
import * as MediaType from "@dashkite/media-type"

description = MediaType.parse "text/html; charset=utf-8"

assert.deepEqual description,
  type: "text"
  subtype: "html"
  parameters:
    charset: "utf-8"

description = MediaType.parse "application/atom+xml; q=0.5"

assert.deepEqual description,
  type: "application"
  subtype: "atom+xml"
  parameters: q: "0.5"
  mime:
    base: "atom"
    suffix: "xml"
    type: "application"
    subtype: "xml"
```

