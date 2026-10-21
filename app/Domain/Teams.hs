module Domain.Teams where

import Data.Bimap
import Domain.Types (PolymarketTeamId (PolymarketTeamId), VlrTeamId (VlrTeamId))

vlrPolymarketIds :: Bimap VlrTeamId PolymarketTeamId
vlrPolymarketIds =
  fromList
    [ -- Team Heretics
      (VlrTeamId 1001, PolymarketTeamId 127319),
      -- Rex Regum Qeon
      (VlrTeamId 878, PolymarketTeamId 126413),
      -- LOUD
      (VlrTeamId 13581, PolymarketTeamId 126513),
      -- BBL Esports
      (VlrTeamId 397, PolymarketTeamId 127384),
      -- FULL SENSE
      (VlrTeamId 4050, PolymarketTeamId 127172),
      -- G2 Esports
      (VlrTeamId 11058, PolymarketTeamId 127415),
      -- Fnatic
      (VlrTeamId 2593, PolymarketTeamId 127418),
      -- T1
      (VlrTeamId 14, PolymarketTeamId 127298),
      -- EDward Gaming
      (VlrTeamId 1120, PolymarketTeamId 127041),
      -- NRG
      (VlrTeamId 1034, PolymarketTeamId 127495),
      -- Team Vitality
      (VlrTeamId 2059, PolymarketTeamId 127223),
      -- Paper Rex
      (VlrTeamId 624, PolymarketTeamId 127161),
      -- TYLOO
      (VlrTeamId 731, PolymarketTeamId 125835),
      -- Sentinels
      (VlrTeamId 2, PolymarketTeamId 127492),
      -- Team Liquid
      (VlrTeamId 474, PolymarketTeamId 127406),
      -- Crazy Raccoon
      (VlrTeamId 277, PolymarketTeamId 126936),
      -- All Gamers
      (VlrTeamId 1119, PolymarketTeamId 127047),
      -- KRÜ Esports
      (VlrTeamId 2355, PolymarketTeamId 127155),
      -- Gentle Mates
      (VlrTeamId 12694, PolymarketTeamId 125863),
      -- Trace Esports
      (VlrTeamId 12685, PolymarketTeamId 125823),
      -- Karmine Corp
      (VlrTeamId 8877, PolymarketTeamId 126341),
      -- Bilibili Gaming
      (VlrTeamId 12010, PolymarketTeamId 125824),
      -- MIBR
      (VlrTeamId 7386, PolymarketTeamId 126556),
      -- FUT Esports
      (VlrTeamId 1184, PolymarketTeamId 127381),
      -- JD Gaming
      (VlrTeamId 13576, PolymarketTeamId 125647),
      -- 100 Thieves
      (VlrTeamId 120, PolymarketTeamId 127333)
    ]
