port module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text, table, thead, tbody, tr, td, th, input)
import Html.Events exposing (onInput)
import Html.Attributes exposing (class, classList, type_)
import Json.Decode as D


port reqAllDocs : () -> Cmd msg


port recAllDocs : (String -> msg) -> Sub msg

                  
main =
  Browser.element { init = init
                  , view = view
                  , update = update
                  , subscriptions = subscriptions
                  }

      
type alias Model =
    { alldocs : List Row
    , displaydocs : List Row
    , search : String
    }

init : () -> ( Model, Cmd msg )
init =
  \_ -> ( Model [] [] "", reqAllDocs () )

type Msg = ReceivedAllDocs String | Search String

subscriptions : Model -> Sub Msg
subscriptions _ =
    recAllDocs ReceivedAllDocs

        
update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
  case msg of
      ReceivedAllDocs str ->
          let
              newrows = case (decodeRows str) of
                            Ok rows ->
                                rows
                            Err e ->
                                [ Row "" "" (Document "" e Nothing ) ]
          in
          ( { alldocs = newrows, displaydocs = newrows, search = "" }
          , Cmd.none )
      Search str ->
          let
              display =
                  List.filter
                      (\r -> String.startsWith str r.doc.wao) model.alldocs
          in
          ( { model | displaydocs = display, search = str }
          , Cmd.none )

view : Model -> Html Msg
view model =
    div [ classList [ ( "content", True )
                    , ( "is-large", True )
                    ]
        ] [ input [ class "input"
                  , type_ "text"
                  , onInput Search
                  ] []
          , table [ classList [ ( "table", True )
                              , ( "is-striped", True )
                              , ( "is-hoverable", True )
                              , ( "is-fullwidth", True )
                              ] ] [ thead []
                                        [ tr []
                                              [ th [] [ text "Wao" ]
                                              , th [] [ text "Esp" ]
                                              ]
                                        ]
                                  , tbody []
                                      (List.map viewRow model.displaydocs)
                                  ]
          ]
     

viewRow : Row -> Html Msg
viewRow row =
    tr []
        [ td [] [ text row.doc.wao ]
        , td [] [ text ( case row.doc.esp of
                             Nothing -> ""
                             Just x -> x
                       )
                ]
        ]
    
type alias Row =
    { id : String
    , key : String
    , doc : Document
    }

type alias Document =
    { dockey : String
    , wao : String
    , esp : Maybe String
    }

rowD : D.Decoder Row
rowD =
    D.map3 Row
        ( D.field "id" D.string )
        ( D.field "key" D.string )
        ( D.field "doc" documentD )

documentD : D.Decoder Document
documentD =
    D.map3 Document
        ( D.field "dockey" D.string )
        ( D.field "wao" D.string )
        ( D.field "esp" (D.nullable D.string) )

decodeRows : String -> Result String (List Row)
decodeRows instr =
    case (D.decodeString (D.list rowD) instr) of
        Ok rows ->
            Ok rows
        Err e ->
            Err (D.errorToString e)

