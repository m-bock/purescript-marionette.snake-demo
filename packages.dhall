let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.4-20221214/packages.dhall
        sha256:e462fb4d932e4bbc522cb563a71d312d6514f97050125d1a3f95cc3a2df3bffb

in  upstream
  with marionette =
      { dependencies =
        [ "aff"
        , "console"
        , "datetime"
        , "effect"
        , "either"
        , "enums"
        , "foldable-traversable"
        , "maybe"
        , "newtype"
        , "node-readline"
        , "now"
        , "ordered-collections"
        , "prelude"
        , "refs"
        , "transformers"
        , "tuples"
        ]
      , repo =
          "https://github.com/thought2/purescript-marionette.git"
      , version =
          "main"
      }