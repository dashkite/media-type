import * as Type from "@dashkite/joy/type"
import { metaclass } from "@dashkite/joy/metaclass"
import Parsers from "./parsers"
import MIME from "./mime"

hasSuffix = ( text ) -> /\+\w+$/.test text

class MediaType extends metaclass()

  @make: ( specifier ) ->
    if Type.isString specifier
      @parse specifier
    else
      Object.assign ( new @ ), specifier
  
  @parse: ( specifier ) -> 
    MediaType.make Parsers.mediaType specifier
  
  @format: ( value ) ->
    if value instanceof MediaType
      value.format()
    else
      ( MediaType.make value ).format()

  @fromPath: ( path ) ->
    if ( extension = ( path.match /.([0-9a-z]+)$/i )?[1] )?
      MediaType.parse MIME.getType extension

  @getters

    data: -> { @... }

  toJSON: -> @data

  format: ->
    result = "#{@type}/#{@subtype}"
    if @mime?.suffix? && !( hasSuffix @subtype )
      result += "+#{ @mime.suffix }"
    if @parameters?
      for key, value of @parameters
        result += "; #{key}=#{value}"
    result

export default MediaType
export { MediaType }