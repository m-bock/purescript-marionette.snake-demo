module Snake.MVC.View where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.String as Str
import Marionette.Renderers.Commander (CliSurface(..), KeyPrompt(..), KeyboardUserInput(..), Output(..))
import Snake.Board (Tile(..))
import Snake.Board as Board
import Snake.Data.CharGrid as CharGrid
import Snake.Data.Direction as Dir
import Snake.Data.Grid as Grid
import Snake.Data.Vector (Vector(..))
import Snake.MVC.Model (Game(..), Msg(..), State(..), Config)

size :: Vector Int
size = Vec 21 11

view :: Config -> State -> CliSurface Msg
view cfg = case _ of
  State_Init -> CliSurface
    (TextOutput "")

    do
      KeyInput
        (KeyPrompt "Press 's' to start!")
        case _ of
          { name: "s" } -> Just Msg_Start
          _ -> Nothing

  State_Playing (Game { board, score }) -> CliSurface
    do
      TextOutput $ Str.joinWith ""
        [ board
            # Board.toGrid
            <#>
              case _ of
                Tile_Wall -> '#'
                Tile_Floor -> ' '
                Tile_Goodie -> 'x'
                Tile_SnakeHead -> '+'
                Tile_SnakeBody -> 'O'
            # CharGrid.toString
        , "  SCORE " <> show (unwrap score) <> "/" <> show cfg.maxScore
        ]

    do
      KeyInput
        (KeyPrompt "Up/Right/Down/Left p=pause")
        case _ of
          { name: "up" } -> Just $ Msg_Navigate Dir.Up
          { name: "right" } -> Just $ Msg_Navigate Dir.Right
          { name: "down" } -> Just $ Msg_Navigate Dir.Down
          { name: "left" } -> Just $ Msg_Navigate Dir.Left
          { name: "p" } -> Just $ Msg_Pause
          _ -> Nothing

  State_Error msg -> CliSurface
    (TextOutput $ "Error: " <> show msg)
    NoInput

  State_Paused _ -> CliSurface
    do
      TextOutput $
        Grid.fill (const '.') size
          # CharGrid.writeTextCenter "PAUSED"
          # CharGrid.toString

    do
      KeyInput
        (KeyPrompt "r=resume")
        case _ of
          { name: "r" } -> Just $ Msg_Resume
          _ -> Nothing

  State_Lost _ -> CliSurface
    do
      TextOutput $
        Grid.fill (const '.') size
          # CharGrid.writeTextCenter "YOU LOST!"
          # CharGrid.toString
    NoInput

  State_Won _ -> CliSurface
    do
      TextOutput $
        Grid.fill (const '.') size
          # CharGrid.writeTextCenter "YOU WON!"
          # CharGrid.toString

    NoInput
