{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE EmptyDataDeriving #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Halo2.Types.RowCount (RowCount (RowCount, getRowCount)) where

import Halo2.Prelude
import Stark.Types.Scalar (Scalar)

newtype RowCount = RowCount {getRowCount :: Scalar}
  deriving (Eq, Ord, Show, Generic, Num)
