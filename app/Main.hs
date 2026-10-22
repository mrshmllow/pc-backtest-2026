module Main (main) where

import Bluefin.Eff (runEff)
import Bluefin.Exception (try)
import Bluefin.IO (effIO)
import Control.Exception.Safe (throw, throwIO)
import Domain.Types
import Polymarket (eventBySlug, vlrMatchToPolymarketSlug)
import Relude
import System.Exit (ExitCode (ExitFailure))
import System.Log.FastLogger
  ( LogType' (LogStdout),
    TimedFastLogger,
    ToLogStr (..),
    defaultBufSize,
    newTimedFastLogger,
    simpleTimeFormat,
  )
import System.Log.FastLogger.Date (newTimeCache)
import Vlr (scrapeMatch)

logMsg :: (ToLogStr msg) => TimedFastLogger -> msg -> IO ()
logMsg logger msg = logger $ \formattedTime ->
  toLogStr formattedTime <> " [INFO] " <> toLogStr msg <> "\n"

main :: IO ()
main = runEff $ \io -> do
  timeCache <- effIO io $ newTimeCache simpleTimeFormat
  (logger, cleanUp) <- effIO io $ newTimedFastLogger timeCache (LogStdout defaultBufSize)

  let matchId = VlrMatchId 754737

  effIO io $ logMsg logger ("querying" <> show matchId :: String)

  matchReq <- try $ \ex -> scrapeMatch io ex $ matchId

  effIO io $ logMsg logger ("got " <> show matchReq :: String)

  matchMaybe <- case matchReq of
    Right a -> pure a
    Left ex -> effIO io $ throwIO ex

  match <- case matchMaybe of
    Just a -> pure a
    Nothing -> effIO io $ throwIO NothingFound

  slug <- case vlrMatchToPolymarketSlug match of
    Just a -> pure a
    Nothing -> effIO io $ throwIO TeamNotAdded

  effIO io $ logMsg logger ("slug: " <> show slug :: String)

  req <- try $ \ex -> eventBySlug io ex slug

  effIO io $ logMsg logger ("finally: " <> show req :: String)

  effIO io cleanUp
