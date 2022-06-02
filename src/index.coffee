import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
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
    when "xml" then "application/xml"
    else "application/octet-stream"

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

isBinary = (value) ->
  ( Type.isType ArrayBuffer, value ) ||
    do ->
      try
        # i could have sworn this was available in Node?
        Type.isType Blob, value
      catch
        false

isJSONSerializable = (value) ->
  try
    JSON.stringify value
    true
  catch
    false

isStringSerializable = (value) ->
  try
    value.toString()
    true
  catch
    false

MediaType =

  fromPath: (path) ->
    if ( suffix = ( path.match /.([0-9a-z]+)$/i )?[1] )?
      MediaType.parse mimeLookup suffix

  parse: P.parser mediaType

  format: ({type, subtype, parameters, mime}) ->
    result = "#{type}/#{subtype}"
    if mime?.suffix?
      result += "+#{mime.suffix}"
    if parameters?
      for key, value of parameters
        result += "; #{key}=#{value}"
    result

  wrap: (value) ->
    if Type.isString value then MediaType.parse value
    else if Type.isObject then value
    else throw new TypeError "expected media type string or description"

  category: (value) ->
    value = MediaType.wrap value
    if MediaType.isText value then "text"
    else if MediaType.isJSON value then "json"
    else if MediaType.isBinary value then "binary"

  isText: (value) ->
    value = MediaType.wrap value
    value.type == "text" || value.mime?.type == "text"

  isJSON: (value) ->
    value = MediaType.wrap value
    ( value.subtype == "json" ) || ( value.mime?.subtype == "json" )

  isBinary: (value) ->
    value = MediaType.wrap value
    ( value.subtype == "octet-stream" ) ||
      ( value.mime?.subtype == "octet-stream" ) ||
      ( /(image|audio|video)/.test value.type ) ||
      ( /(image|audio|video)/.test value.mime?.type )

  infer: (value) ->
    if Type.isString value
      "text"
    else if isBinary value
      "binary"
    else if isJSONSerializable value
      "json"
    else if isStringSerializable value
      "text"

Accept =

  parse: P.parser accept
  
  wrap: (value) -> 
    if Type.isString value then Accept.parse value
    else if Type.isArray then value.map MediaType.wrap
    else throw new TypeError "expected accept string or candidate array"

  selectors:
    text: (candidates) -> (Accept.wrap candidates).find MediaType.isText
    json: (candidates) -> (Accept.wrap candidates).find MediaType.isJSON
    binary: (candidates) -> (Accept.wrap candidates).find MediaType.isBinary

  matches: (query, value) ->
    ( query.type == "*" || query.type == value.type ) &&
      ( query.subtype == "*" || query.subtype == value.subtype ) &&
        matchParameters query, value

  selector: (candidates) ->
    candidates = Accept.wrap candidates
    (target) ->
      target = MediaType.parse target
      candidates.find (candidate) ->
        Accept.matches candidate, target

  selectByCategory: (category, candidates) ->
    Accept.selectors[ category ]? candidates

  selectByContent: (content, candidates) ->
    if ( category = MediaType.infer content )?
      Accept.selectByCategory category, candidates

export { MediaType, Accept }