module OSL.Types.Token (Token (..)) where

import OSL.Types.Keyword (Keyword (..))
import OSL.Types.OSL (Name (..))

data Token
  = Var Name
  | Keyword Keyword
  | ThinArrow
  | Colon
  | Comma
  | OpenParen
  | CloseParen
  | Const Integer
  | LeftRightArrow
  | ConstN Integer
  | ConstZ Integer
  | ConstF Integer
  | ConstFin Integer
  | ProductOp
  | CoproductOp
  | AddNOp
  | MulNOp
  | AddZOp
  | MulZOp
  | AddFpOp
  | MulFpOp
  | MaxNOp
  | MaxZOp
  | MaxFpOp
  | Equal
  | Less
  | LessOrEqual
  | And
  | Or
  | Not
  | ForAll
  | ForSome
  | Lambda
  | ThickArrow
  | Congruent
  | DefEquals
  | Semicolon
  | Period
  | Caret
  | OpenBracket
  | CloseBracket
  | OpenBrace
  | CloseBrace
  | Top
  | Bottom
  deriving (Eq, Show)
