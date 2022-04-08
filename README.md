# Media Type

Parse HTTP media types.

```coffeescript
import assert from "@dashkite/assert"
import { MediaType, Accept } from "@dashkite/media-type"

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

select = Accept.selector "text/*;q=0.3, text/html;q=0.7, text/html;level=1,
  text/html;level=2;q=0.4, */*;q=0.5"

assert.deepEqual select "text/html",
  type: 'text'
  subtype: 'html'
  parameters:
    q: '0.7'

```

