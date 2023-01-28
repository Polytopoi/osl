{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE IncoherentInstances #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MonoLocalBinds #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module OSL.FromHaskell
  ( ToOSLType (toOSLType),
    AddToOSLContext (addToOSLContext),
    addToOSLContextM
  ) where

import Control.Monad.State (State, state)
import Data.Fixed (Fixed (..), HasResolution (resolution))
import Data.Kind (Type)
import qualified Data.Map as Map
import Data.Proxy (Proxy (Proxy))
import Data.Text (pack)
import Data.Time (Day (..), LocalTime (..))
import Data.Time.LocalTime (TimeOfDay (..))
import GHC.Generics (Generic, Rep, U1, (:*:), (:+:), M1, D, C, S, K1, R, Meta (MetaData))
import GHC.TypeLits (KnownNat, KnownSymbol, symbolVal)
import qualified OSL.Types.OSL as OSL

deriving instance Generic Day
deriving instance Generic LocalTime
deriving instance Generic TimeOfDay
deriving instance Generic (Fixed n)

class ToOSLType a where
  toOSLType :: Proxy a -> OSL.ValidContext 'OSL.Global () -> OSL.Type ()

class GToOSLType (a :: Type) (ra :: Type -> Type) where
  gtoOSLType :: Proxy a -> Proxy ra -> OSL.ValidContext 'OSL.Global () -> OSL.Type ()

instance GToOSLType t U1 where
  gtoOSLType _ _ _ = OSL.Fin () 1

instance GToOSLType t a => GToOSLType t (M1 D m a) where
  gtoOSLType (Proxy :: Proxy t) (Proxy :: Proxy (M1 D m a)) c =
    gtoOSLType (Proxy :: Proxy t) (Proxy :: Proxy a) c

instance GToOSLType t a => GToOSLType t (M1 C m a) where
  gtoOSLType (Proxy :: Proxy t) (Proxy :: Proxy (M1 C m a)) c =
    gtoOSLType (Proxy :: Proxy t) (Proxy :: Proxy a) c

instance GToOSLType t a => GToOSLType t (M1 S m a) where
  gtoOSLType (Proxy :: Proxy t) (Proxy :: Proxy (M1 S m a)) c =
    gtoOSLType (Proxy :: Proxy t) (Proxy :: Proxy a) c

instance GToOSLType t (Rep a) => GToOSLType t (K1 R a) where
  gtoOSLType (Proxy :: Proxy t) (Proxy :: Proxy (K1 R a)) c =
    gtoOSLType (Proxy :: Proxy t) (Proxy :: Proxy (Rep a)) c

instance ( GToOSLType a ra, GToOSLType b rb )
           => GToOSLType (a, b) (ra :*: rb) where
  gtoOSLType (Proxy :: Proxy (a, b)) (Proxy :: Proxy (ra :*: rb)) c =
    OSL.Product ()
      (gtoOSLType (Proxy :: Proxy a) (Proxy :: Proxy ra) c)
      (gtoOSLType (Proxy :: Proxy b) (Proxy :: Proxy rb) c)

-- Records with two fields
instance ( GToOSLType a (Rep a), GToOSLType b (Rep b) )
           => GToOSLType t (M1 S ma (K1 R a) :*: M1 S mb (K1 R b)) where
  gtoOSLType (Proxy :: Proxy t)
             (Proxy :: Proxy (M1 S ma (K1 R a) :*: M1 S mb (K1 R b)))
              c =
    OSL.Product ()
      (gtoOSLType (Proxy :: Proxy a) (Proxy :: Proxy (Rep a)) c)
      (gtoOSLType (Proxy :: Proxy b) (Proxy :: Proxy (Rep b)) c)

-- Records with three fields
instance ( GToOSLType a (Rep a), GToOSLType b (Rep b), GToOSLType c (Rep c) )
           => GToOSLType t (M1 S ma (K1 R a) :*: (M1 S mb (K1 R b) :*: M1 S mc (K1 R c))) where
  gtoOSLType (Proxy :: Proxy t)
             (Proxy :: Proxy (M1 S ma (K1 R a)
                         :*: (M1 S mb (K1 R b)
                          :*: M1 S mc (K1 R d))))
              c =
    OSL.Product ()
      (gtoOSLType (Proxy :: Proxy a) (Proxy :: Proxy (Rep a)) c)
      (OSL.Product ()
        (gtoOSLType (Proxy :: Proxy b) (Proxy :: Proxy (Rep b)) c)
        (gtoOSLType (Proxy :: Proxy d) (Proxy :: Proxy (Rep d)) c))

-- Records with four fields
instance ( GToOSLType a (Rep a),
           GToOSLType b (Rep b),
           GToOSLType d (Rep d),
           GToOSLType e (Rep e) )
  => GToOSLType t
       ((M1 S ma (K1 R a) :*:
         M1 S mb (K1 R b)) :*:
        (M1 S md (K1 R d) :*:
         M1 S me (K1 R e))) where
  gtoOSLType
    (Proxy :: Proxy t)
    (Proxy :: Proxy ((M1 S ma (K1 R a)
                       :*: M1 S mb (K1 R b))
                 :*: (M1 S md (K1 R d)
                       :*: M1 S me (K1 R e))))
    c =
    OSL.Product ()
      (gtoOSLType (Proxy :: Proxy a) (Proxy :: Proxy (Rep a)) c)
      (OSL.Product ()
        (gtoOSLType (Proxy :: Proxy b) (Proxy :: Proxy (Rep b)) c)
        (OSL.Product ()
          (gtoOSLType (Proxy :: Proxy d) (Proxy :: Proxy (Rep d)) c)
          (gtoOSLType (Proxy :: Proxy e) (Proxy :: Proxy (Rep e)) c)))

instance ( GToOSLType a ra, GToOSLType b rb )
           => GToOSLType (Either a b) (ra :+: rb) where
  gtoOSLType (Proxy :: Proxy (Either a b)) (Proxy :: Proxy (ra :+: rb)) c =
    OSL.Coproduct ()
      (gtoOSLType (Proxy :: Proxy a) (Proxy :: Proxy ra) c)
      (gtoOSLType (Proxy :: Proxy b) (Proxy :: Proxy rb) c)

instance GToOSLType Integer a where
  gtoOSLType _ _ _ = OSL.Z ()

instance GToOSLType Int a where
  gtoOSLType _ _ _ = OSL.Z ()

instance GToOSLType Day a where
  gtoOSLType _ _ _ = OSL.N ()

instance HasResolution n => GToOSLType (Fixed n) a where
  gtoOSLType (Proxy :: Proxy (Fixed n)) _ _ =
    OSL.Fin () (resolution (Proxy @n))

instance KnownNat n => GToOSLType (Fixed n) a where
  gtoOSLType (Proxy :: Proxy (Fixed n)) _ _ =
    OSL.Fin () (resolution (Proxy @n))

instance GToOSLType a (Rep a) => ToOSLType a where
  toOSLType (Proxy :: Proxy a) = gtoOSLType (Proxy @a) (Proxy @(Rep a))

class AddToOSLContext a where
  addToOSLContext ::
    Proxy a ->
    OSL.ValidContext 'OSL.Global () ->
    OSL.ValidContext 'OSL.Global ()

class GAddToOSLContext (a :: Type) (ra :: Type -> Type) where
  gAddToOSLContext :: Proxy a -> Proxy ra -> OSL.ValidContext 'OSL.Global () -> OSL.ValidContext 'OSL.Global ()

-- newtypes
instance
  ( KnownSymbol n, GToOSLType t (Rep t) ) =>
  GAddToOSLContext t (M1 D (MetaData n m p True) a) where
  gAddToOSLContext
    (Proxy :: Proxy t)
    (Proxy :: Proxy (M1 D (MetaData name moduleName packageName True) a))
    c =
    c <> OSL.ValidContext
           (Map.singleton
              (OSL.Sym (pack (symbolVal (Proxy @name))))
              (OSL.Data (toOSLType (Proxy @t) c)))

instance GAddToOSLContext a (Rep a) => AddToOSLContext a where
  addToOSLContext (Proxy :: Proxy a) = gAddToOSLContext (Proxy @a) (Proxy @(Rep a))

addToOSLContextM ::
  AddToOSLContext a =>
  Proxy a ->
  State (OSL.ValidContext 'OSL.Global ()) ()
addToOSLContextM p = state (((),) . addToOSLContext p)
