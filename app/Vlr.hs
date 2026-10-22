module Vlr where

import Bluefin.Eff (Eff, (:>))
import Bluefin.Exception (Exception, throw)
import Bluefin.IO (IOE, effIO)
import Control.Exception.Safe (tryAny)
import Control.Lens
import Data.Text qualified as T
import Data.Time (UTCTime)
import Data.Time.Format (defaultTimeLocale, parseTimeM)
import Domain.Types
import GHC.IO.Exception (userError)
import Relude hiding (Exception)
import Text.HTML.Scalpel
  ( Scraper,
    Selector,
    attr,
    attrs,
    chroots,
    hasClass,
    scrapeURL,
    text,
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

vlrMatch :: VlrMatchId -> VlrTeamId -> VlrTeamId -> Text -> Maybe VlrMatch
vlrMatch matchId tA tB d =
  (\moment -> MatchData {teamA = tA, teamB = tB, date = moment, matchId})
    <$> parseVlrTime (toString d)

scrapeMatch :: (io :> es, ex :> es) => IOE io -> Exception AppError ex -> VlrMatchId -> Eff es (Maybe VlrMatch)
scrapeMatch io ex matchId = do
  uri <- case mkScrapeUrl (EntryMatchId matchId) of
    Just a -> pure a
    Nothing -> throw ex InvalidVlrUrl

  scrapedEx <- effIO io $ tryAny $ scrapeURL (URI.renderStr uri) match
  scrapedMaybe <- case scrapedEx of
    Left exception -> throw ex (Unexpected exception)
    Right mayb -> pure $ mayb

  (tALink, tBLink, timestamp) <- maybe (throw ex InvalidVlrUrl) pure scrapedMaybe
  ta <- maybe (throw ex InvalidVlrUrl) pure (teamUrlToId tALink)
  tb <- maybe (throw ex InvalidVlrUrl) pure (teamUrlToId tBLink)

  pure $ vlrMatch matchId ta tb timestamp
  where
    match :: Scraper Text (Text, Text, Text)
    match = do
      -- (tA : tB : _) <- titleTeams
      (tALink : tBLink : _) <- teamLinks
      timestamp <- momentUtc

      pure $ (tALink, tBLink, timestamp)

    momentUtc :: Scraper Text Text
    momentUtc = attr "data-utc-ts" momentSelector

    momentSelector :: Selector
    momentSelector = "div" @: [hasClass "match-header-date"] // "div" @: [hasClass "moment-tz-convert"]

    -- titleTeams :: Scraper Text [Text]
    -- titleTeams = texts $ "div" @: [hasClass "wf-title-med"]

    teamLinks :: Scraper Text [Text]
    teamLinks = attrs "href" $ "a" @: [hasClass "match-header-link"]

teamUrlToId :: Text -> Maybe VlrTeamId
teamUrlToId ts = do
  uris <- URI.mkURI ts
  let pathPiece = uris ^. uriPath . ix 1 . unRText

  VlrTeamId <$> (readMaybe $ toString pathPiece)

matchUrlToId :: [Text] -> Either SomeException [VlrMatchId]
matchUrlToId ts = do
  uris <- mapM URI.mkURI ts
  let pathPieces = uris ^.. traversed . uriPath . _head . unRText :: [Text]

  traverse parseMatchId pathPieces
  where
    parseMatchId t = maybe (Left (toException (userError ("not an int: " <> show t)))) Right (VlrMatchId <$> (readMaybe $ toString t))

scrapeEvent :: (io :> es, ex :> es) => IOE io -> Exception AppError ex -> VlrEventId -> Eff es (Maybe VlrEvent)
scrapeEvent io ex eventId = do
  uri <- case mkScrapeUrl (EntryEventId eventId) of
    Just uri -> pure uri
    Nothing -> throw ex InvalidVlrUrl

  scrapedEx <- effIO io $ tryAny $ scrapeURL (URI.renderStr uri) match
  scraped <- either (throw ex . Unexpected) pure scrapedEx

  (name, matchUrls) <- case scraped of
    Just a -> pure a
    Nothing -> throw ex InvalidVlrUrl

  matches <- case matchUrlToId matchUrls of
    Left exception -> throw ex (Unexpected exception)
    Right val -> pure val

  pure $ Just EventData {name = T.strip name, matches}
  where
    match :: Scraper Text (Text, [Text])
    match = do
      matchUrls <- matchAs
      name <- titleH1

      pure $ (name, matchUrls)

    titleH1 :: Scraper Text Text
    titleH1 = text $ "h1" @: [hasClass "event-header-main-title"]

    matchAs :: Scraper Text [Text]
    matchAs = chroots ("div" @: [hasClass "wf-card"]) matchA

    matchA :: Scraper Text Text
    matchA = attr "href" $ "a" @: [hasClass "wf-module-item", hasClass "match-item"]
