import types from "./types"

extensions = do ->
  result = {}
  for type, extensions of types
    for extension in extensions
      result[ extension ] = type
  result

MIME =

  getType: ( extension ) ->
    extensions[ extension ]


export default MIME
  