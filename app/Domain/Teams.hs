module Domain.Teams where

import Data.Bimap
import Data.Text (Text)
import Domain.Types (PolymarketTeamId (PolymarketTeamId), VlrTeamId (VlrTeamId))
import Relude qualified as Relude
import Relude.Container (Map)

vlrPolymarketIds :: Bimap VlrTeamId PolymarketTeamId
vlrPolymarketIds =
  Data.Bimap.fromList
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

polymarketTeamAbbrv :: Map PolymarketTeamId Text
polymarketTeamAbbrv =
  Relude.fromList
    [ -- Team Heretics
      (PolymarketTeamId 127319, "th1"),
      -- Rex Regum Qeon
      (PolymarketTeamId 126413, "rrq1"),
      -- LOUD
      (PolymarketTeamId 126513, "loud"),
      -- BBL Esports
      (PolymarketTeamId 127384, "bbl1"),
      -- FULL SENSE
      (PolymarketTeamId 127172, "fs1"),
      -- G2 Esports
      (PolymarketTeamId 127415, "g21"),
      -- Fnatic
      (PolymarketTeamId 127418, "fnc1"),
      -- T1
      (PolymarketTeamId 127298, "t1"),
      -- EDward Gaming
      (PolymarketTeamId 127041, "edg1"),
      -- NRG
      (PolymarketTeamId 127495, "nrg"),
      -- Team Vitality
      (PolymarketTeamId 127223, "vit"),
      -- Paper Rex
      (PolymarketTeamId 127161, "pr1"),
      -- TYLOO
      (PolymarketTeamId 125835, "tyloo"),
      -- Sentinels
      (PolymarketTeamId 127492, "sen"),
      -- Team Liquid
      (PolymarketTeamId 127406, "tl1"),
      -- Crazy Raccoon
      (PolymarketTeamId 126936, "cr"),
      -- All Gamers
      (PolymarketTeamId 127047, "ag1"),
      -- KRÜ Esports
      (PolymarketTeamId 127155, "kru1"),
      -- Gentle Mates
      (PolymarketTeamId 125863, "gm"),
      -- Trace Esports
      (PolymarketTeamId 125823, "te"),
      -- Karmine Corp
      (PolymarketTeamId 126341, "kc3"),
      -- Bilibili Gaming
      (PolymarketTeamId 125824, "blg"),
      -- MIBR
      (PolymarketTeamId 126556, "mibr"),
      -- FUT Esports
      (PolymarketTeamId 127381, "fut1"),
      -- JD Gaming
      (PolymarketTeamId 125647, "jdg"),
      -- 100 Thieves
      (PolymarketTeamId 127333, "100t1")
    ]
