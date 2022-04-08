import * as Text from "@dashkite/joy/text"
import * as P from "@dashkite/parse"
import Mime from "mime-types"

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
  ( Mime.lookup suffix ) ? "application/octet-stream"

expandSubtype = (subtype) ->
  [ base, suffix ] = subtype.split "+"
  if suffix?
    mime = MediaType.parse mimeLookup suffix
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
]

MediaType = parse: P.parser mediaType

acceptDelimiter = P.skip P.all [
  P.optional P.ws
  P.text ","
  P.optional P.ws
]

normalizeParameters = (p) -> { p..., q } = ( p ? {} ) ; p

mostParameters = (a, b) ->
  p = Object.keys normalizeParameters a.parameters
  q = Object.keys normalizeParameters b.parameters
  if p > q then -1 else ( if p < q then 1 else 0 )

highestSpecificityFor = (key, a, b) ->
  if a[key] == "*"
    if b[key] == "*" then 0 else 1
  else ( if b[key] == "*" then -1 else 0 )

highestSpecificity = (a, b) ->
  ( highestSpecificityFor "type", a, b ) ||
    ( highestSpecificityFor "subtype", a, b ) ||
      mostParameters a, b

getQuality = (value) ->
  if value.parameters?.q?
    Text.parseNumber value.parameters.q
  else
    1

highestQuality = (a, b) ->
  p = getQuality a
  q = getQuality b
  if p > q then -1 else ( if p < q then 1 else 0 )

sortByPrecedence = (list) ->
  list.sort (a, b) ->
     ( highestSpecificity a, b ) || ( highestQuality a, b )

accept = P.pipe [
  P.list acceptDelimiter, mediaType
  P.map sortByPrecedence
]

matchParameters = (query, target) ->
  query = normalizeParameters query.parameters
  target = normalizeParameters target.parameters
  ( Object.entries query )
    .every ([ key, value ]) -> target[ key ] == value

Accept = 

  parse: P.parser accept
  
  matches: (query, value) ->
    ( query.type == "*" || query.type == value.type ) &&
      ( query.subtype == "*" || query.subtype == value.subtype ) &&
        matchParameters query, value

  selector: (text) ->
    options = Accept.parse text
    (target) ->
      target = MediaType.parse target
      options.find (option) ->
        Accept.matches option, target


export { MediaType, Accept }