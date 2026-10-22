module Domain.Types (PolymarketTeamId (..), VlrTeamId (..), PolymarketData, PolymarketTeam, AppError (..), VlrMatch (..), VlrMatchId (..), VlrEntry (..), VlrEventId (..), VlrEvent (..)) where

import Data.Aeson (FromJSON)
import Data.Time (UTCTime)
import Network.HTTP.Simple (HttpException, JSONException)
import Relude

newtype PolymarketTeamId = PolymarketTeamId Int
  deriving (FromJSON) via Int
  deriving (Show, Eq, Ord)

newtype VlrTeamId = VlrTeamId Int
  deriving (FromJSON) via Int
  deriving (Show, Eq, Ord)

data PolymarketTeam = PolymarketTeam
  { id :: PolymarketTeamId,
    name :: Text,
    abbreviation :: Text
  }
  deriving (Show, Generic)

instance FromJSON PolymarketTeam

data PolymarketData = PolymarketData
  { id :: Text,
    teams :: [PolymarketTeam]
  }
  deriving (Show, Generic)

instance FromJSON PolymarketData

data AppError
  = InvalidSlug
  | InvalidVlrUrl
  | JsonException JSONException
  | Http HttpException
  | Unexpected SomeException
  deriving (Show)

data VlrMatch
  = MatchData
  { teamA :: VlrTeamId,
    teamB :: VlrTeamId,
    date :: UTCTime,
    matchId :: VlrMatchId
  }
  deriving (Show, Generic)

data VlrEvent
  = EventData
  { name :: Text,
    matches :: [VlrMatchId]
  }
  deriving (Show)

newtype VlrMatchId = VlrMatchId Int deriving (Show)

newtype VlrEventId = VlrEventId Int deriving (Show)

data VlrEntry = EntryEventId VlrEventId | EntryMatchId VlrMatchId deriving (Show)
