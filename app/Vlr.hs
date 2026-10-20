module Vlr
  ( scrapeMatch,
    mkScrapeUrl,
    scrapeEvent,
  )
where

import Control.Lens
import Data.Text qualified as T
import Data.Time (UTCTime)
import Data.Time.Format (defaultTimeLocale, parseTimeM)
import Domain.Types
import GHC.IO.Exception (userError)
import Relude
import Text.HTML.Scalpel
  ( Scraper,
    Selector,
    attr,
    chroots,
    hasClass,
    scrapeURL,
    text,
    texts,
    (//),
    (@:),
  )
import Text.URI (URI)
import Text.URI qualified as URI
import Text.URI.Lens (unRText, uriPath, uriQuery)
import Text.URI.QQ qualified as QQ

vlrBaseUrl :: URI
vlrBaseUrl = [QQ.uri|https://www.vlr.gg/|]

mkScrapeUrl :: VlrEntry -> Maybe URI
mkScrapeUrl (EntryMatchId (VlrMatchId matchId)) = URI.mkPathPiece (show matchId) >>= \p -> pure $ vlrBaseUrl & uriPath |>~ p
mkScrapeUrl (EntryEventId (VlrEventId eventId)) = do
  ps <- mapM URI.mkPathPiece ["event", "matches", show eventId]
  k <- URI.mkQueryKey "series_id"
  v <- URI.mkQueryValue "all"

  pure $ vlrBaseUrl & uriPath <>~ ps & uriQuery |>~ URI.QueryParam k v

parseVlrTime :: [Char] -> Maybe UTCTime
parseVlrTime = parseTimeM True defaultTimeLocale "%Y-%m-%d %H:%M:%S"

vlrMatch :: VlrMatchId -> Text -> Text -> Text -> Maybe VlrMatch
vlrMatch matchId tA tB d =
  (\moment -> MatchData {teamA = T.strip tA, teamB = T.strip tB, date = moment, matchId})
    <$> parseVlrTime (toString d)

scrapeMatch :: VlrMatchId -> IO (Maybe VlrMatch)
scrapeMatch matchId = do
  case mkScrapeUrl (EntryMatchId matchId) of
    Nothing -> pure Nothing
    Just uri -> scrapeURL (URI.renderStr uri) match
  where
    match :: Scraper Text VlrMatch
    match = do
      (tA : tB : _) <- titleTeams
      timestamp <- momentUtc
      maybe empty pure (vlrMatch matchId tA tB timestamp)

    momentUtc :: Scraper Text Text
    momentUtc = attr "data-utc-ts" momentSelector

    momentSelector :: Selector
    momentSelector = "div" @: [hasClass "match-header-date"] // "div" @: [hasClass "moment-tz-convert"]

    titleTeams :: Scraper Text [Text]
    titleTeams = texts $ "div" @: [hasClass "wf-title-med"]

matchUrlToId :: [Text] -> Either SomeException [Int]
matchUrlToId ts = do
  uris <- mapM URI.mkURI ts
  let pathPieces = uris ^.. traversed . uriPath . _head . unRText :: [Text]

  traverse parseInt pathPieces
  where
    parseInt t = maybe (Left (toException (userError ("not an int: " <> show t)))) Right (readMaybe $ toString t)

scrapeEvent :: VlrEventId -> IO (Maybe VlrEvent)
scrapeEvent eventId = do
  case mkScrapeUrl (EntryEventId eventId) of
    Nothing -> pure Nothing
    Just uri -> scrapeURL (URI.renderStr uri) match
  where
    match :: Scraper Text VlrEvent
    match = do
      matchUrls <- matchAs
      name <- titleH1
      -- todo: this does not reveal the error to the caller...
      matchIds <- case matchUrlToId matchUrls of
        Left _ -> empty
        Right val -> pure val

      pure $ EventData {name = T.strip name, matches = matchIds}

    titleH1 :: Scraper Text Text
    titleH1 = text $ "h1" @: [hasClass "event-header-main-title"]

    matchAs :: Scraper Text [Text]
    matchAs = chroots ("div" @: [hasClass "wf-card"]) matchA

    matchA :: Scraper Text Text
    matchA = attr "href" $ "a" @: [hasClass "wf-module-item", hasClass "match-item"]
