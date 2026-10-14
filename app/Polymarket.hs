module Polymarket (PolymarketData, gammaBaseUrl, eventBySlugUrl, eventBySlug, test) where

import Bluefin.Eff (Eff, runEff, (:>))
import Bluefin.Exception (Exception, throw, try)
import Bluefin.IO (IOE, effIO)
import Control.Exception.Safe (fromException, tryAny)
import Control.Lens
import Data.Text (Text)
import Domain.Types (AppError (..), PolymarketData, PolymarketTeam)
import Network.HTTP.Simple (JSONException, Response, getResponseBody, httpJSONEither, parseRequest)
import Text.URI (URI)
import Text.URI qualified as URI
import Text.URI.Lens
import Text.URI.QQ qualified as QQ

gammaBaseUrl :: URI
gammaBaseUrl = [QQ.uri|https://gamma-api.polymarket.com/events/slug|]

urlAddPath :: URI -> [Text] -> Maybe URI
urlAddPath url slugs = mapM URI.mkPathPiece slugs <&> (url &) . (uriPath <>~)

eventBySlugUrl :: [Text] -> Maybe URI
eventBySlugUrl = urlAddPath gammaBaseUrl

eventBySlug :: (io :> es, ex :> es) => IOE io -> Exception AppError ex -> Text -> Eff es PolymarketData
eventBySlug io ex slug = do
  url <- maybe (throw ex InvalidSlug) pure (eventBySlugUrl [slug])

  result <- effIO io $ tryAny $ do
    req <- parseRequest $ (URI.renderStr url)
    httpJSONEither req

  json <- either (throw ex . classifyReq) pure result

  either (throw ex . JsonException) pure (getResponseBody json)
  where
    classifyReq e = maybe (Unexpected e) Http (fromException e)

test :: Text -> IO (Either AppError (PolymarketData))
test str = runEff $ \io -> do
  req <- try $ \ex -> eventBySlug io ex str

  pure $ req
