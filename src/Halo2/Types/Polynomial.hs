{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Halo2.Types.Polynomial (Polynomial (Polynomial)) where

import Halo2.Prelude
import Halo2.Types.Coefficient (Coefficient)
import Halo2.Types.PowerProduct (PowerProduct)

newtype Polynomial = Polynomial {monos :: Map PowerProduct Coefficient}
  deriving (Eq, Ord, Show, Generic)
