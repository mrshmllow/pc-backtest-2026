module Polymarket (PolymarketData, gammaBaseUrl, eventBySlugUrl, eventBySlug) where

import Bluefin.Eff (Eff, (:>))
import Bluefin.Exception (Exception, throw)
import Bluefin.IO (IOE, effIO)
import Control.Exception.Safe (tryAny)
import Control.Lens
import Domain.Types (AppError (..), PolymarketData, VlrMatch)
import Network.HTTP.Simple
  ( getResponseBody,
    httpJSONEither,
    parseRequest,
  )
import Relude hiding (Exception)
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

vlrMatchToPolymarketSlug :: VlrMatch -> Text
vlrMatchToPolymarketSlug = undefined
