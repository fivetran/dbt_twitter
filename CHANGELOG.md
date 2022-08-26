# dbt_twitter v0.5.0

PR [#12](https://github.com/fivetran/dbt_twitter/pull/12) includes the following changes:
## 🚨 Breaking Changes 🚨
- The `twitter__ad_adapter` has been refactored and renamed to `twitter_ads__url_report`.
- The `twitter__campaign_report` has been refactored and renamed to `twitter_ads__campaign_report`.
- The `twitter__line_item_report` has been refactored and renamed to `twitter_ads__line_item_report`.

## 🎉 Feature Enhancements 🎉
- Addition of the following new end models:
  - `twitter_ads__promoted_tweet_report`
    - Each record in this table represents the daily performance at the promoted tweet level.
  - `twitter_ads__account_report`
    - Each record in this table represents the daily performance at the advertiser account level.
  - `twitter_ads__line_item_report`
    - Each record in this table represents the daily performance at the line item (ad group) level.
  - `twitter_ads__keyword_report`
    - Each record in this table represents the daily performance at line item level for keywords. This can be disabled by setting the `twitter_ads__using_keywords` variable to `False`.
  - `twitter_ads__campaign_report`
    - Each record in this table represents the daily performance at the campaign level.
  - `twitter_ads__url_report`
    - Each record in this table represents the daily performance at the URL level.

- Inclusion of passthrough metrics:
  - `twitter_ads__line_item_report_passthrough_metrics`
  - `twitter_ads__campaign_report_passthrough_metrics`
  - `twitter_ads__line_item_keywords_report_passthrough_metrics`
  - `twitter_ads__promoted_tweet_report_passthrough_metrics` - _These metrics will be passed to the account report as well._
> This applies to all passthrough columns within the `dbt_twitter` package and not just the `twitter_ads__line_item_report_passthrough_metrics` example.
```yml
vars:
  twitter_ads__line_item_report_passthrough_metrics:
    - name: "my_field_to_include" # Required: Name of the field within the source.
      alias: "field_alias" # Optional: If you wish to alias the field within the staging model.
```

- README updates for easier navigation and use of the package.
- Included grain uniqueness tests for each end model.

# dbt_twitter v0.4.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_twitter_source`. Additionally, the latest `dbt_twitter_source` package has a dependency on the latest `dbt_fivetran_utils`. Further, the latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_twitter v0.1.0 -> v0.3.0
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
