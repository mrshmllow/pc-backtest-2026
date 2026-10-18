module Capabilities.Polymarket (bySlug) where

import Bluefin.Eff (Eff, (:>))
import Bluefin.Exception (Exception, throw)
import Bluefin.IO (IOE, effIO)
import Control.Exception.Safe (tryAny)
import Domain.Types (AppError (..))
import Network.HTTP.Client.Conduit (Response)
import Network.HTTP.Simple (httpBS, parseRequest)
import Relude hiding (Exception)

bySlug :: (io :> es, ex :> es) => IOE io -> Exception AppError ex -> String -> Eff es (Response ByteString)
bySlug io ex url = do
  result <- effIO io $ tryAny $ do
    req <- parseRequest url
    httpBS req

  either (throw ex . classify) pure result
  where
    classify e = maybe (Unexpected e) Http (fromException e)
