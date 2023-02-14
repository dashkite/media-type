import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"

import { MediaType, Accept } from "../src"

do ->

  print await test "@dashkite/media-type", [


    test "MediaType", [

      test "fromPath", [
        
        test "./html.js", ->
          assert.deepEqual  { type: "text", subtype: "javascript" },
            MediaType.fromPath "./html.js"
        
        test "./css.js", ->
          assert.deepEqual  { type: "text", subtype: "javascript" },
            MediaType.fromPath "./css.js"

      ]
      
      test "Parse", do ({scenario, scenarios} = {}) ->
  
        scenario = (text, expected) ->
          test text, ->
            assert.deepEqual ( MediaType.parse text ), expected

        scenarios = (description, array, expected) ->
          test description,
            for text in array
              scenario text, expected

        [

          scenario "application/json",
            type: "application"
            subtype: "json"
          
          # https://httpwg.org/specs/rfc7231.html#rfc.section.3.1.1.1
          scenarios "case, quoting, and whitespace variations", [
              "text/html;charset=utf-8"  
              "text/html; charset=utf-8"
              "text/html;charset=UTF-8"
              'Text/HTML;Charset="utf-8"'
              'text/html; charset="utf-8"'
            ],
            type: "text"
            subtype: "html"
            parameters:
              charset: "utf-8"

          scenario "image/svg+xml",
            type: "image"
            subtype: "svg+xml"
            mime:
              base: "svg"
              suffix: "xml"
              type: "application"
              subtype: "xml"

          scenario "application/atom+xml; q=0.5",
            type: "application"
            subtype: "atom+xml"
            parameters: q: "0.5"
            mime:
              base: "atom"
              suffix: "xml"
              type: "application"
              subtype: "xml"
        ]
    ]

    test "Accepts", [
      
      test "Parse", do ({scenario, scenarios} = {}) ->
  
        scenario = (text, expected) ->
          test text, ->
            assert.deepEqual ( Accept.parse text ), expected

        [
          scenario "text/html,
            application/xhtml+xml,
            application/xml;q=0.9,
            image/webp, */*;q=0.8",
          [
            { type: 'text', subtype: 'html' },
            {
              type: 'application',
              subtype: 'xhtml+xml',
              mime: {
                base: 'xhtml',
                suffix: 'xml',
                type: 'application',
                subtype: 'xml'
              }
            },
            { type: 'image', subtype: 'webp' },
            { type: 'application', subtype: 'xml', parameters: { q: '0.9' } },
            { type: '*', subtype: '*', parameters: { q: '0.8' } }
          ]

          scenario "text/*, text/plain, text/plain;format=flowed, */*",
            [
              { type: 'text', subtype: 'plain', parameters: { format: 'flowed' } },
              { type: 'text', subtype: 'plain' },
              { type: 'text', subtype: '*' },
              { type: '*', subtype: '*' }
            ]
        ]

      test "Match", do ({scenario} = {}) ->

        scenario = (text, associations) ->
          select = Accept.selector text
          test text, do ->
            for [ target, type ] in associations
              test target, ->
                assert.deepEqual ( select target ), type

        [

          # https://httpwg.org/specs/rfc7231.html#rfc.section.5.3.2
          scenario "text/*;q=0.3, text/html;q=0.7, text/html;level=1,
            text/html;level=2;q=0.4, */*;q=0.5",
            [
              [
                "text/html;level=1"
                { type: 'text', subtype: 'html', parameters: { level: '1' } }
              ]
              [
                "text/html"	
                { type: 'text', subtype: 'html', parameters: { q: '0.7' } }
              ]
              [
                "text/plain"
                { type: 'text', subtype: '*', parameters: { q: '0.3' } }
              ]
              [
                "image/jpeg"
                { type: '*', subtype: '*', parameters: { q: '0.5' } }
              ]
              [
                "text/html;level=2"
                { type: 'text', subtype: 'html', parameters: { level: '2', q: '0.4' } }
              ]
              [
                "text/html;level=3"
                { type: 'text', subtype: 'html', parameters: { q: '0.7' } }
              ]
            ]

        ]
    ]
  ]