module Capabilities.Polymarket (bySlug, test) where

import Bluefin.Eff (Eff, runEff, (:>))
import Bluefin.Exception (Exception, throw, try)
import Bluefin.IO (IOE, effIO)
import Control.Exception.Safe (SomeException, fromException, tryAny)
import Data.ByteString.Lazy (ByteString)
import Domain.Types (AppError (..))
import Network.HTTP.Client.Conduit (Response)
import Network.HTTP.Simple (HttpException, httpLbs, parseRequest)

bySlug :: (io :> es, ex :> es) => IOE io -> Exception AppError ex -> String -> Eff es (Response ByteString)
bySlug io ex url = do
  result <- effIO io $ tryAny $ do
    req <- parseRequest url
    httpLbs req

  either (throw ex . classify) pure result
  where
    classify e = maybe (Unexpected e) Http (fromException e)

test :: String -> IO (Either AppError (Response ByteString))
test str = runEff $ \io -> do
  req <- try $ \ex -> bySlug io ex str

  pure $ req
