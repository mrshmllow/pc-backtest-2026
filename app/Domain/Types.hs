module Domain.Types (PolymarketData, PolymarketTeam, AppError (..)) where

import Data.Aeson (FromJSON)
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

data AppError = InvalidSlug | JsonException JSONException | Http HttpException | Unexpected SomeException deriving (Show)
