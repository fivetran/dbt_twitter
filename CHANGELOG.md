# dbt_twitter v0.10.0

[PR #32](https://github.com/fivetran/dbt_twitter/pull/32) includes the following updates:

## Breaking Change for dbt Core < 1.9.6
> *Note: This is not relevant to Fivetran Quickstart users.*

Migrated `freshness` from a top-level source property to a source `config` in alignment with [recent updates](https://github.com/dbt-labs/dbt-core/issues/11506) from dbt Core ([Source PR #31](https://github.com/fivetran/dbt_twitter_source/pull/31)). This will resolve the following deprecation warning that users running dbt >= 1.9.6 may have received:

```
[WARNING]: Deprecated functionality
Found `freshness` as a top-level property of `twitter_ads` in file
`models/src_twitter_ads.yml`. The `freshness` top-level property should be moved
into the `config` of `twitter_ads`.
```

**IMPORTANT:** Users running dbt Core < 1.9.6 will not be able to utilize freshness tests in this release or any subsequent releases, as older versions of dbt will not recognize freshness as a source `config` and therefore not run the tests.

If you are using dbt Core < 1.9.6 and want to continue running Twitter Ads freshness tests, please elect **one** of the following options:
  1. (Recommended) Upgrade to dbt Core >= 1.9.6
  2. Do not upgrade your installed version of the `twitter_ads` package. Pin your dependency on v0.9.0 in your `packages.yml` file.
  3. Utilize a dbt [override](https://docs.getdbt.com/reference/resource-properties/overrides) to overwrite the package's `twitter_ads` source and apply freshness via the [old](https://github.com/fivetran/dbt_twitter_source/blob/v0.9.0/models/src_twitter_ads.yml#L10-L12) top-level property route. This will require you to copy and paste the entirety of the `src_twitter_ads.yml` [file](https://github.com/fivetran/dbt_twitter_source/blob/v0.9.0/models/src_twitter_ads.yml#L4-L710) and add an `overrides: twitter_ads_source` property.

## Under the Hood
- Updated the package maintainer PR template.

# dbt_twitter v0.9.0

This release includes the following updates:

## Schema Changes
**6 total changes • 0 possible breaking changes**
| **Model** | **Change type** | **Old name** | **New name** | **Notes** |
| ---------------- | --------------- | ------------ | ------------ | --------- |
| [twitter_ads__campaign_country_report](https://fivetran.github.io/dbt_twitter/#!/model/model.twitter_ads.twitter_ads__campaign_country_report) | New Transform Model |   |   |  Each record in this table represents the daily performance of ads at the account, campaign, and ad-placement level, segmented by country.  |
| [twitter_ads__campaign_region_report](https://fivetran.github.io/dbt_twitter/#!/model/model.twitter_ads.twitter_ads__campaign_region_report) | New Transform Model |   |   | Each record in this table represents the daily performance of ads at the account, campaign, and ad-placement level, segmented by geographic region.   |
| stg_twitter_ads__campaign_locations_report | New Staging Model |   |   |  Uses `campaign_locations_report` source table  |
| stg_twitter_ads__campaign_locations_report_tmp | New Staging Model |   |   | Uses `campaign_locations_report` source table   |
| stg_twitter_ads__campaign_regions_report | New Staging Model |   |   |  Uses `campaign_regions_report` source table  |
| stg_twitter_ads__campaign_regions_report_tmp | New Staging Model |   |   | Uses `campaign_regions_report` source table   |

## Feature Updates
- Added the `twitter_ads__using_campaign_locations_report` and `twitter_ads__using_campaign_regions_report` variables, which can be used to enable or disable the above transformations related to the `campaign_locations_report` and `campaign_regions_report` tables. ([#31](https://github.com/fivetran/dbt_twitter/pull/31))
  - These variables are dynamically set for Fivetran Quickstart users, but **false** by default otherwise. See [README](https://github.com/fivetran/dbt_twitter?tab=readme-ov-file#country-and-region-reports) for more details.
- Introduced the `twitter_ads__campaign_locations_report_passthrough_metrics` and `twitter_ads__campaign_regions_report_passthrough_metrics` passthrough column variables, which can be used to pass through additional metrics fields from their respective source reports to downstream models (`twitter_ads__campaign_country_report` and `twitter_ads__campaign_region_report`, respectively). See [README](https://github.com/fivetran/dbt_twitter?tab=readme-ov-file#passing-through-additional-metrics) for more details. ([#31](https://github.com/fivetran/dbt_twitter/pull/31))

## Documentation
- Added Quickstart model counts to README. ([#30](https://github.com/fivetran/dbt_twitter/pull/30))
- Corrected references to connectors and connections in the README. ([#30](https://github.com/fivetran/dbt_twitter/pull/30))
- Fixed broken links to dbt model documentation in the README. ([#29](https://github.com/fivetran/dbt_twitter/pull/29))
- Applied minor formatting improvements to the README. ([#29](https://github.com/fivetran/dbt_twitter/pull/29))
- Updated LICENSE. ([#31](https://github.com/fivetran/dbt_twitter/pull/31))

## Under the Hood
- Added data validation tests for the new country and region report end models. ([#31](https://github.com/fivetran/dbt_twitter/pull/31))

# dbt_twitter v0.8.0

[PR #26](https://github.com/fivetran/dbt_twitter/pull/26) includes the following **BREAKING CHANGE** updates:

## Feature Updates: Native Conversion Support
We have added more robust support for conversions in our data models by doing the following:
- Created the `twitter_ads__conversion_fields` and `twitter_ads__conversion_sale_amount_fields` variables to pass through conversion metrics (total number and monetary value, respectively). Conversion metrics are split into these 2 variables due to the N:1 relationship between Twitter conversions and their conversion value fields.
  - By default, `twitter_ads__conversion_fields` will include `conversion_purchases_metric` and `conversion_custom_metric`.
  - By default, `twitter_ads__conversion_sale_amount_fields` will include `conversion_purchases_sale_amount` and `conversion_custom_sale_amount`.
  - These conversion fields will be included in each end model report. Additionally, they will be summed up into new `total_conversions` and `total_conversions_sale_amount` columns.
  - See [README](https://github.com/fivetran/dbt_twitter?tab=readme-ov-file#customizing-types-of-conversions) for more details on how to configure these variables.

## Under the Hood
- Ensured the above changes maintain backwards compatibility with [existing passthrough column variables](https://github.com/fivetran/dbt_twitter?tab=readme-ov-file#passing-through-additional-metrics). 
  - Added a new [version](https://github.com/fivetran/dbt_twitter_ads/blob/main/macros/twitter_ads_persist_pass_through_columns.sql) of the `persist_pass_through_columns()` [macro](https://github.com/fivetran/dbt_fivetran_utils/blob/v0.4.10/macros/persist_pass_through_columns.sql) in which we can include coalesces and properly check between conversion field values and the existing passthrough columns.
- Added integrity and consistency validation tests within `integration_tests` for the Twitter Ads transformation models.

## Documentation
- Highlighted all metrics included in the package by default. Previously, `url_clicks` and `spend_micro` were missing from this README [section](https://github.com/fivetran/dbt_twitter?tab=readme-ov-file#passing-through-additional-metrics).
- Documented how to configure the new `twitter_ads__conversion_fields` and `twitter_ads__conversion_sale_amount_fields` variables [here](https://github.com/fivetran/dbt_twitter?tab=readme-ov-file#customizing-types-of-conversions).
- Added Contributors [subsection](https://github.com/fivetran/dbt_twitter?tab=readme-ov-file#contributors) to README.

## Contributors
- [Seer Interactive](https://www.seerinteractive.com/?utm_campaign=Fivetran%20%7C%20Models&utm_source=Fivetran&utm_medium=Fivetran%20Documentation)

# dbt_twitter v0.7.0
[PR #21](https://github.com/fivetran/dbt_twitter/pull/21) includes the following updates:
## Feature update 🎉
- Unioning capability! This adds the ability to union source data from multiple twitter connectors. Refer to the [Union Multiple Connectors README section](https://github.com/fivetran/dbt_twitter/blob/main/README.md#union-multiple-connectors) for more details.

## Under the hood 🚘
- In the source package, updated tmp models to union source data using the `fivetran_utils.union_data` macro. 
- To distinguish which source each field comes from, added `source_relation` column in each staging and downstream model and applied the `fivetran_utils.source_relation` macro.
  - The `source_relation` column is included in all joins in the transform package. 
- Updated tests to account for the new `source_relation` column.

[PR #18](https://github.com/fivetran/dbt_twitter/pull/18) includes the following updates:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request [templates](/.github).

# dbt_twitter v0.6.0

## 🚨 Breaking Changes 🚨:
[PR #14](https://github.com/fivetran/dbt_twitter/pull/14) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

## 🎉 Features 🎉
- For use in the [dbt_ad_reporting package](https://github.com/fivetran/dbt_ad_reporting), users can now allow records having nulls in url fields to be included in the `ad_reporting__url_report` model. See the [dbt_ad_reporting README](https://github.com/fivetran/dbt_ad_reporting) for more details. [#17](https://github.com/fivetran/dbt_twitter/pull/17) 
## 🚘 Under the Hood 🚘
- Disabled the `not_null` test for `twitter_ads__url_report` when null urls are allowed. [#17](https://github.com/fivetran/dbt_twitter/pull/17)

# dbt_twitter v0.5.1
## Fixes
- Fix the package name in the README ([#16](https://github.com/fivetran/dbt_twitter/pull/16))

## Feature Enhancement
- Addition of the `keyword_id` to the `twitter_ads__keyword_report` model. ([#15](https://github.com/fivetran/dbt_twitter/pull/15))

## Under the Hood
- BuildKite testing integration. ([#15](https://github.com/fivetran/dbt_twitter/pull/15))

## Contributors
- [@johnf](https://github.com/johnf) ([#16](https://github.com/fivetran/dbt_twitter/pull/16))

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
