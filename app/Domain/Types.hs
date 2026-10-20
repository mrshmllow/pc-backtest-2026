module Domain.Types (PolymarketData, PolymarketTeam, AppError (..), VlrMatch (..), VlrMatchId (..), VlrEntry (..), VlrEventId (..), VlrEvent (..)) where

import Data.Aeson (FromJSON)
import Data.Time (UTCTime)
import Network.HTTP.Simple (HttpException, JSONException)
import Relude

data PolymarketTeam = PolymarketTeam
  { id :: Int,
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

data AppError = InvalidSlug | InvalidVlrUrl | JsonException JSONException | Http HttpException | Unexpected SomeException deriving (Show)

data VlrMatch
  = MatchData
  { teamA :: Text,
    teamB :: Text,
    date :: UTCTime,
    matchId :: VlrMatchId
  }
  deriving (Show)

data VlrEvent
  = EventData
  { name :: Text,
    matches :: [Int]
  }
  deriving (Show)

newtype VlrMatchId = VlrMatchId Int deriving (Show)

newtype VlrEventId = VlrEventId Int deriving (Show)

data VlrEntry = EntryEventId VlrEventId | EntryMatchId VlrMatchId deriving (Show)
