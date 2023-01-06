{-# LANGUAGE GADTs #-}
module Lambda where

data Type where
  Base   :: String -> Type
  App    :: Type -> Type -> Type deriving (Eq, Show)
data Term where
  Var    :: String -> Term
  Lambda :: Term -> Type -> Term -> Term
  Apply  :: Term -> Term -> Term 
  CC     :: Term
  Cont   :: [Term] -> Term deriving (Eq, Show)

token :: Int -> Int -> String
token i j = "bound" ++ show i ++ "," ++ show j

alpha_ :: Term -> Int -> Int -> Term
alpha_ (Lambda x ty t) i j = Lambda (Var $ token i j) ty (alpha_ t (i+1) j)
alpha_ (Apply (Lambda x ty t) (Var y)) i j =
  Apply (Lambda (Var $ token i j) ty (alpha_ t (i+1) j)) (Var y)
alpha_ (Apply a b) i j = Apply (alpha_ a (i+1) j) (alpha_ b i (j+1))
alpha_ (Var v) _ _ = Var v

alpha :: Term -> Term
alpha t = alpha_ t 0 0

beta :: Term -> Term -> Term -> Term 
beta a b (Var t) 
  | (Var t) == a = b
  | otherwise = Var t
beta a b (Lambda x ty t) = Lambda x ty $ beta a b t
beta a b (Apply t u) = Apply (beta a b t) (beta a b u)

initType :: Type -> Maybe Type
initType (Base _) = Nothing 
initType (App t1 (Base _)) = Just t1
initType (App t1 t2) = (initType t2) >>= (\x -> Just $ App t1 x)

tailType :: Type -> Maybe Type
tailType (Base _) = Nothing 
tailType (App (Base _) t2) = Just t2
tailType (App t1 t2) = (tailType t1) >>= (\x -> Just $ App x t2)
