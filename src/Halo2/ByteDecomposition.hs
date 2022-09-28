{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoImplicitPrelude #-}


module Halo2.ByteDecomposition
  ( decomposeBytes
  , composeBytes
  ) where


import Cast (intToInteger)
import Halo2.Prelude
import Halo2.Types.FieldElement (FieldElement (..))
import Halo2.Types.BitsPerByte (BitsPerByte (..))
import Halo2.Types.Byte (Byte (..))
import Halo2.Types.ByteDecomposition (ByteDecomposition (..))


decomposeBytes :: BitsPerByte -> FieldElement -> ByteDecomposition
decomposeBytes (BitsPerByte b) (FieldElement x) =
  case x `quotRem` intToInteger (2 ^ b) of
    (0, r) -> ByteDecomposition [Byte r]
    (x', r) -> decomposeBytes (BitsPerByte b) (FieldElement x')
            <> ByteDecomposition [Byte r]


composeBytes :: BitsPerByte -> ByteDecomposition -> FieldElement
composeBytes _ (ByteDecomposition []) = 0
composeBytes (BitsPerByte b) (ByteDecomposition (Byte x : xs)) =
  (FieldElement (x * (2 ^ intToInteger (b * length xs))))
    + composeBytes (BitsPerByte b) (ByteDecomposition xs)
