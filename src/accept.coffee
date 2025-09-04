import { metaclass } from "@dashkite/joy/metaclass"
import * as Type from "@dashkite/joy/type"
import Parsers from "./parsers"
import { sort } from "./parsers/accept"
import MediaType from "./media-type"

normalizeCandidate = ( candidate ) ->
  if Type.isString candidate
    ( MediaType.parse candidate ).data
  else candidate

normalizeCandidates = ( candidates ) ->
  candidates.map normalizeCandidate

normalizeParameters = (p) -> { p..., q } = ( p ? {} ) ; p

matchParameters = ( candidate, target ) ->
  candidate = normalizeParameters candidate.parameters
  target = normalizeParameters target.parameters
  ( Object.entries candidate )
    .every ([ key, value ]) -> target[ key ] == value

class Accept extends metaclass()

  @make: ( candidates ) ->
    if Type.isString candidates
      @parse candidates
    else if Type.isArray candidates
      Object.assign ( new @ ), 
        candidates: sort normalizeCandidates candidates
    else
      throw new TypeError "accept: invalid argument"

  @parse: ( specifier ) -> 
    Object.assign ( new @ ),
      candidates: Parsers.accept specifier

  @format: ( value ) ->
    if value instanceof Accept
      value.format()
    else
      ( Accept.make value ).format()

  @matches: ( candidate, target ) ->
    ( candidate.type == "*" || candidate.type == target.type ) &&
      ( candidate.subtype == "*" || candidate.subtype == target.subtype ) &&
        matchParameters candidate, target

  @getters
    data: -> @candidates

  toJSON: -> @data

  format: ->
    (( MediaType.format candidate ) for candidate in @candidates ).join ", "

  supported: ( target ) ->
    @candidates.some ( candidate ) -> Accept.matches candidate, target
     
  preferred: ( targets ) ->
    Array.from new Set do =>
      @candidates
        .map ( candidate ) ->
          targets.filter ( target ) -> 
            Accept.matches candidate, target
        .flat()
      
export default Accept
export { Accept }