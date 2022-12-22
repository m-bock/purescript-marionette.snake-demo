module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class.Console (logShow)
import Effect.Random (randomInt)
import Marionette (Config, Program, defaultConfig)
import Marionette as Mar
import Marionette.Controllers.Monadic as Monadic
import Marionette.Renderers.Commander as Commander
import Snake.MVC.Control (Env, control)
import Snake.MVC.Model (Msg, State(..))
import Snake.MVC.Model as Model
import Snake.MVC.View (view)

env :: Env Aff
env =
  { delay: Aff.delay
  , randomInt: liftEffect $ randomInt bottom top
  }

config :: Config Msg State
config =
  defaultConfig

appConfig :: Model.Config
appConfig = { maxScore: 3 }

program :: Program Msg State
program =
  { initialState: State_Init
  , renderer: Commander.mkRenderer (view appConfig) $ Commander.defaultConfig
      { separator = Just ""
      }
  , controller: Monadic.mkController $ control env appConfig
  }

main :: Effect Unit
main = launchAff_ do
  res <- Mar.runProgram program config
  logShow res
  pure unit
