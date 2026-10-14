module Main (main) where

import Bluefin.Eff (runEff)
import Bluefin.Exception (try)
import Bluefin.IO (effIO)
import Polymarket (eventBySlug)
import System.Log.FastLogger (LogType' (LogStdout), TimedFastLogger, ToLogStr (..), defaultBufSize, newTimedFastLogger, simpleTimeFormat)
import System.Log.FastLogger.Date (newTimeCache)

logMsg :: (ToLogStr msg) => TimedFastLogger -> msg -> IO ()
logMsg logger msg = logger $ \formattedTime ->
  toLogStr formattedTime <> " [INFO] " <> toLogStr msg <> "\n"

main :: IO ()
main = runEff $ \io -> do
  timeCache <- effIO io $ newTimeCache simpleTimeFormat
  (logger, cleanUp) <- effIO io $ newTimedFastLogger timeCache (LogStdout defaultBufSize)

  effIO io $ logMsg logger ("hello world" :: String)

  req <- try $ \ex -> eventBySlug io ex "val-vit-loud-2026-10-16"

  effIO io $ logMsg logger (show req :: String)
  effIO io $ cleanUp
