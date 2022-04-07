import * as P from "@dashkite/parse"
import Mime from "mime-types"

lowercase = (c) ->
  if c.rest?
    c.rest = c.rest.toLowerCase()
  c

# https://httpwg.org/specs/rfc7230.html#rule.token.separators
# simplification from the spec, since you probably don't actually
# want, say, tab characters in your media types
token = P.re /^[A-Za-z0-9\-\+\.]+/

type = P.pipe [
  token
  P.tag "type"
]

expandSubtype = (subtype) ->
  [ base, suffix ] = subtype.split "+"
  if suffix?
    supertype = parse (( Mime.lookup suffix ) ? "application/octet-stream" )
    {
      base
      suffix
      supertype...
    }

subtype = P.pipe [
  token
  P.map (subtype) ->
    if ( mime = expandSubtype subtype )?
      { subtype, mime }
    else
      { subtype }
]

# simplification from the spec
quotedText = P.re /^[^\\]+/

escapedPair = P.all [
  P.skip P.text "\\"
  # simplification from the spec
  P.re /^./
]

quoted = P.all [
  P.text '"'
  P.optional P.many P.any [
    quotedText
    escapedPair
  ]
]

# # https://httpwg.org/specs/rfc7231.html#media.type
# type = token
# subtype = token

parameter = P.pipe [
  P.all [
    token
    P.skip P.text "="
    P.any [
      token
      quoted
    ]
  ]
  P.map ([ key, value ]) -> [key]: value
]

delimiter = P.all [
  P.skip P.optional P.ws
  P.skip P.text ";"
  P.skip P.optional P.ws
]

parameters = P.pipe [
  P.many P.pipe [
    P.all [
      P.skip delimiter
      parameter
    ]
    P.first
  ]
  P.merge
  P.tag "parameters"
]

parse = P.parser P.pipe [
  lowercase
  P.all [
    P.pipe [
      P.all [
        type
        P.optional P.pipe [
          P.all [
            P.skip P.text "/"
            subtype
          ]
          P.first
        ]
      ]
      P.merge
    ]
    P.optional parameters
  ]
  P.merge
]

export default parse