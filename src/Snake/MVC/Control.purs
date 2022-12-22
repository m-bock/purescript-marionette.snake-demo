module Snake.MVC.Control where

import Prelude

import Control.Monad.State (modify_)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..))
import Data.Maybe (fromMaybe)
import Data.String as Str
import Data.Time.Duration (Milliseconds(..))
import Marionette.Controllers.Monadic (MarionetteT, sendMsg)
import Snake.Board (BoardEvent(..))
import Snake.Board as Board
import Snake.MVC.Model (Game(..), Msg(..), Score(..), State(..), StateError(..), Config)

type Env m =
  { delay :: Milliseconds -> m Unit
  , randomInt :: m Int
  }

level :: String
level = Str.joinWith "\n"
  [ "###########     #####"
  , "#                   #"
  , "#                   #"
  , "           +OOOO     "
  , "    x                "
  , "                     "
  , "                     "
  , "#                   #"
  , "#                   #"
  , "#                   #"
  , "###########     #####"
  ]



control :: forall m. Monad m => Env m -> Config -> Msg -> MarionetteT Msg State m Unit
control env cfg = case _ of
  Msg_Start -> do
    modify_ case _ of
      State_Init ->
        case Board.parse level of
          Right board ->
            State_Playing $ Game { board, score: Score 0 }

          Left msg ->
            State_Error $ ErrBoardParse $ show msg

      st -> st

    sendMsg Msg_Tick

  Msg_Resume -> do
    modify_ case _ of
      State_Paused game -> State_Playing game

      st -> st

  Msg_Pause -> do
    modify_ case _ of
      State_Playing game -> State_Paused game

      st -> st

  Msg_Navigate dir -> do
    modify_ case _ of
      State_Playing (Game game) -> State_Playing $ Game $ game
        { board = Board.setDirection dir game.board # fromMaybe game.board }

      st -> st

  Msg_Tick -> do
    randInt <- lift $ Board.RandInt <$> env.randomInt

    modify_ case _ of
      State_Playing (Game game) ->
        case Board.runBoard randInt game.board of
          Event_Continue newBoard ->
            State_Playing $ Game game { board = newBoard }

          Event_EatGoodie newBoard ->
            let
              newScore = game.score + Score 1
            in
              if newScore >= Score cfg.maxScore then
                State_Won newScore

              else
                State_Playing $ Game game { board = newBoard, score = newScore }

          Event_Collision ->
            State_Lost game.score

          Event_NoSpaceLeft -> State_Lost game.score

      st -> st

    lift $ env.delay (Milliseconds 200.0)

    sendMsg Msg_Tick
