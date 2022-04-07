import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"

import parse from "../src"

do ->

  print await test "media-type", [

    test "application/json", ->
      assert.deepEqual ( parse "application/json" ),
        type: "application"
        subtype: "json"
    
    test "text/html; charset=utf-8", ->
      assert.deepEqual ( parse "text/html; charset=utf-8" ),
        type: "text"
        subtype: "html"
        parameters:
          charset: "utf-8"

    test "image/svg+xml", ->
      assert.deepEqual ( parse "image/svg+xml" ),
        type: "image"
        subtype: "svg+xml"
        mime:
          base: "svg"
          suffix: "xml"
          type: "application"
          subtype: "xml"

    test "application/atom+xml; q=0.5", ->
      assert.deepEqual ( parse "application/atom+xml; q=0.5" ),
        type: "application"
        subtype: "atom+xml"
        parameters: q: "0.5"
        mime:
          base: "atom"
          suffix: "xml"
          type: "application"
          subtype: "xml"
  ]

