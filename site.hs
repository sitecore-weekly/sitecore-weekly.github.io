--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
  match "images/*" $ do
    route idRoute
    compile copyFileCompiler

  match "css/*" $ do
    route idRoute
    compile compressCssCompiler

  match "posts/*" $ do
    route $ setExtension "html"
    compile
      $   pandocCompiler
      >>= loadAndApplyTemplate "templates/post.html"    postCtx
      >>= saveSnapshot "content"
      >>= loadAndApplyTemplate "templates/default.html" postCtx
      >>= relativizeUrls

  match "404.html" $ do
    route idRoute
    compile
      $   pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" defaultContext

  -- create ["rss.xml"] $ do
  --   route idRoute
  --   compile $
  --     loadAllSnapshots "posts/*" "content"
  --     >>= fmap (take 10)
  --     .   recentFirst
  --     >>= renderRss (feedConfiguration "All posts") feedCtx

  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let indexCtx =
            listField "posts" postCtx (return posts)
              `mappend` constField "title" "Home"
              `mappend` defaultContext

      getResourceBody
        >>= applyAsTemplate indexCtx
        >>= loadAndApplyTemplate "templates/default.html" indexCtx
        >>= relativizeUrls

  match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" `mappend` defaultContext

feedCtx :: Context String
feedCtx = mconcat
    [ bodyField "description"
    , defaultContext
    ]
feedConfiguration :: String -> FeedConfiguration
feedConfiguration title = FeedConfiguration
        { feedTitle       = "Sitecore Weekly - " ++ title
        , feedDescription = "Sitecore Weekly is a free hand-picked links to interesting content about Sitecore from around the web."
        , feedAuthorName  = "Alexandr Serogin"
        , feedAuthorEmail = "alexandrserogin@gmail.com"
        , feedRoot        = "http://sitecore-weekly.github.io"
        }
    




