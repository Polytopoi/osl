{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedLabels #-}

module Halo2.Types.PolynomialConstraints
  ( PolynomialConstraints (PolynomialConstraints),
  )
where

import Halo2.Prelude
import Halo2.Types.Polynomial (Polynomial)
import Halo2.Types.PolynomialDegreeBound (PolynomialDegreeBound)

data PolynomialConstraints = PolynomialConstraints
  { constraints :: [Polynomial],
    degreeBound :: PolynomialDegreeBound
  }
  deriving (Eq, Ord, Show, Generic)

instance Semigroup PolynomialConstraints where
  p <> q =
    PolynomialConstraints
    ((p ^. #constraints) <> (q ^. #constraints))
    ((p ^. #degreeBound) `max` (q ^. #degreeBound))

instance Monoid PolynomialConstraints where
  mempty = PolynomialConstraints mempty 0
