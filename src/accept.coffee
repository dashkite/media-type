import { metaclass } from "@dashkite/joy/metaclass"
import Parsers from "./parsers"
import { sort } from "./parsers/accept"

normalizeParameters = (p) -> { p..., q } = ( p ? {} ) ; p

matchParameters = ( candidate, target ) ->
  candidate = normalizeParameters candidate.parameters
  target = normalizeParameters target.parameters
  ( Object.entries candidate )
    .every ([ key, value ]) -> target[ key ] == value

class Accept extends metaclass()

  @make: ( candidates ) ->
    Object.assign ( new @ ), 
      candidates: sort candidates

  @parse: ( specifier ) -> 
    Object.assign ( new @ ),
      candidates: Parsers.accept specifier

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