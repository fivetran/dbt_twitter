# Decision Log

## URLs included in URL report
In the source `tweet_url` table, there is am `index` field, which refers to the URL's place amongst the list of URLs included in a tweet, as a tweet may include multiple links. In the package's `twitter_ads__url_report` model, however, in order to maintain the integrity of aggregated metrics at the URL grain, we have chosen to only report on the _first_ URL in a tweet. We've chosen the first one specifically because a tweet with multiple links will only showcase a link preview-box for the first URL. 
## Account currency in the account report
Twitter (X) ad accounts have no currency field in the source data, but every campaign carries the account's currency. `twitter_ads__account_report` takes `currency` from the latest version of each of the account's campaigns. Deleted campaigns are included: X fixes an account's currency when the account is created, and changing it creates a new account, so a deleted campaign still reflects the account's currency. If an account's campaigns ever disagree, `currency` is left null rather than guessed.
