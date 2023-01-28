module Site exposing (config)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import MimeType
import Pages.Manifest as Manifest
import Pages.Url
import Route
import SiteConfig exposing (SiteConfig)


config : SiteConfig
config =
    { canonicalUrl = canonicalUrl
    , head = head
    }


type alias Data =
    { siteName : String
    }


data : BackendTask FatalError Data
data =
    BackendTask.map Data
        --(StaticFile.request "site-name.txt" StaticFile.body)
        (BackendTask.succeed "Dphones")


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.icon [ ( 32, 32 ) ] MimeType.Png (myIcon 32)
    , Head.icon [ ( 16, 16 ) ] MimeType.Png (myIcon 16)
    , Head.appleTouchIcon (Just 180) (myIcon 180)
    , Head.appleTouchIcon (Just 192) (myIcon 192)
    , Head.sitemapLink "/sitemap.xml"
    ]
        |> BackendTask.succeed


canonicalUrl : String
canonicalUrl =
    "https://comefile.me"


manifest : Data -> Manifest.Config
manifest static =
    Manifest.init
        { name = static.siteName
        , description = "DPhones - " ++ tagline
        , startUrl = Route.Index |> Route.toPath
        , icons =
            [ icon webp 192
            , icon webp 512
            , icon MimeType.Png 192
            , icon MimeType.Png 512
            ]
        }
        |> Manifest.withShortName "elm-pages"


tagline : String
tagline =
    "collecting the mixen of DJ Dope Inc."


webp : MimeType.MimeImage
webp =
    MimeType.OtherImage "webp"


icon :
    MimeType.MimeImage
    -> Int
    -> Manifest.Icon
icon format width =
    { src = myIcon width
    , sizes = [ ( width, width ) ]
    , mimeType = format |> Just
    , purposes = [ Manifest.IconPurposeAny, Manifest.IconPurposeMaskable ]
    }


myIcon : Int -> Pages.Url.Url
myIcon width =
    -- Cloudinary.urlSquare "v1603234028/elm-pages/elm-pages-icon" (Just ".png") width -- TODO
    Pages.Url.external ""
