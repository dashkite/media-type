import * as Text from "@dashkite/joy/text"
import * as P from "@dashkite/parse"
import mediaType from "./media-type"

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

export { sortByPrecedence as sort }
export default accept