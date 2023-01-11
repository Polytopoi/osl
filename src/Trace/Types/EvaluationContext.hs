{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StandaloneKindSignatures #-}

module Trace.Types.EvaluationContext (EvaluationContext (EvaluationContext), ContextType (Global, Local)) where

import Data.Kind (Type)
import Data.Map (Map)
import Data.Set (Set)
import GHC.Generics (Generic)
import Halo2.Types.ColumnIndex (ColumnIndex)
import Halo2.Types.LookupTableColumn (LookupTableColumn)
import OSL.Types.OSL (ContextType (Global, Local))
import Trace.Types (Case)
import Stark.Types.Scalar (Scalar)

type EvaluationContext :: ContextType -> Type
data EvaluationContext t =
  EvaluationContext
  { globalMappings :: Map (Case, ColumnIndex) Scalar,
    localMappings :: Map ColumnIndex Scalar,
    lookupTables :: Map (Set LookupTableColumn) (Set (Map LookupTableColumn Scalar))
  }
  deriving Generic
