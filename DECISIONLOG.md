# Decision Log

## URLs included in URL report
In the source `tweet_url` table, there is am `index` field, which refers to the URL's place amongst the list of URLs included in a tweet, as a tweet may include multiple links. In the package's `twitter_ads__url_report` model, however, in order to maintain the integrity of aggregated metrics at the URL grain, we have chosen to only report on the _first_ URL in a tweet. We've chosen the first one specifically because a tweet with multiple links will only showcase a link preview-box for the first URL.

## Age ranges in `twitter_ads__campaign_age_report`
Twitter reports audience age as a range string, such as `18 to 24`. The oldest range is open-ended (`over 65`), and the youngest is `AGE_UNDER_13`.

We keep the raw value as `age_range` and parse it into `min_age` and `max_age` integer columns:
- A range such as `18 to 24` maps to `min_age = 18` and `max_age = 24`.
- `over 65` maps to `min_age = 65` and `max_age = 100`. We use 100 as the upper bound so you can filter and bucket ages with `between min_age and max_age`.
- `AGE_UNDER_13` maps to `min_age = 0` and `max_age = 12`.
- Any other value gets `null` for both.
