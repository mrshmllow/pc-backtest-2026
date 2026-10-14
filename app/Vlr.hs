module Vlr
  ( VlrMatch,
    VlrMatchId (..),
    scrapeMatchData,
  )
where

import Control.Applicative (empty)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Time (UTCTime)
import Data.Time.Format (defaultTimeLocale, parseTimeM)
import Text.HTML.Scalpel (Scraper, Selector, attr, hasClass, scrapeURL, texts, (//), (@:))

newtype VlrMatchId = VlrMatchId Int deriving (Show)

data VlrMatch = MatchData
  { teamA :: Text,
    teamB :: Text,
    date :: UTCTime
  }
  deriving (Show)

vlrMatchUrl :: VlrMatchId -> String
vlrMatchUrl (VlrMatchId matchId) = "https://www.vlr.gg/" ++ show matchId

parseVlrTime :: [Char] -> Maybe UTCTime
parseVlrTime = parseTimeM True defaultTimeLocale "%Y-%m-%d %H:%M:%S"

vlrMatch :: Text -> Text -> Text -> Maybe VlrMatch
vlrMatch tA tB d =
  (\moment -> MatchData {teamA = T.strip tA, teamB = T.strip tB, date = moment})
    <$> parseVlrTime (T.unpack d)

scrapeMatchData :: VlrMatchId -> IO (Maybe VlrMatch)
scrapeMatchData matchId = scrapeURL (vlrMatchUrl matchId) match
  where
    match :: Scraper Text VlrMatch
    match = do
      (tA : tB : _) <- titleTeams
      timestamp <- momentUtc
      maybe empty pure (vlrMatch tA tB timestamp)

    momentUtc :: Scraper Text Text
    momentUtc = attr "data-utc-ts" momentSelector

    momentSelector :: Selector
    momentSelector = "div" @: [hasClass "match-header-date"] // "div" @: [hasClass "moment-tz-convert"]

    titleTeams :: Scraper Text [Text]
    titleTeams = texts $ "div" @: [hasClass "wf-title-med"]
