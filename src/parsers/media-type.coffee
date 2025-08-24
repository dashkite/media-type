import * as P from "@dashkite/parse"

lowercase = (c) ->
  if c.rest?
    c.rest = c.rest.toLowerCase()
  c

# https://httpwg.org/specs/rfc7230.html#rule.token.separators
# simplification from the spec, since you probably don't actually
# want, say, tab characters in your media types
token = P.re /^[A-Za-z0-9\-\+\.\*]+/

type = P.pipe [
  token
  P.tag "type"
]

mimeLookup = (suffix) ->
  switch suffix
    when "js" then "text/javascript"
    when "json" then "application/json"
    when "txt" then "text/plain"
    when "html" then "text/html"
    when "css" then "text/css"
    when "svg" then "image/svg+xml"
    when "xml" then "application/xml"
    when "jpg", "jpeg" then "image/jpeg"
    when "png" then "image/png"
    else "application/octet-stream"

expandSubtype = (subtype) ->
  [ base, suffix ] = subtype.split "+"
  if suffix?
    mime = parse mimeLookup suffix
    {
      base
      suffix
      mime...
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
quotedText = P.re /^[^"\\]+/

escapedPair = P.all [
  P.skip P.text "\\"
  # simplification from the spec
  P.re /^./
]

# quoted values are the same as unquoted
# so we simply discard the quotes
# https://httpwg.org/specs/rfc7231.html#rfc.section.3.1.1.1
quoted = P.pipe [
  P.all [
    P.skip P.text '"'
    P.optional P.many P.any [
      quotedText
      escapedPair
    ]
    P.skip P.text '"'
  ]
  P.flatten
  P.first
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

parameterDelimiter = P.all [
  P.skip P.optional P.ws
  P.skip P.text ";"
  P.skip P.optional P.ws
]

parameters = P.pipe [
  P.many P.pipe [
    P.all [
      P.skip parameterDelimiter
      parameter
    ]
    P.first
  ]
  P.merge
  P.tag "parameters"
]

mediaType = P.pipe [
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
  P.map ( description ) ->
    { type: "*", subtype: "*", description... }
]

acceptDelimiter = P.skip P.all [
  P.optional P.ws
  P.text ","
  P.optional P.ws
]

parse = P.parser mediaType

export default mediaType