#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools
pip install -r integration_tests/requirements.txt
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
dbt seed --target "$db" --full-refresh
dbt run --target "$db" --full-refresh
dbt test --target "$db"
dbt run --vars '{twitter_ads__using_keywords: false, ad_reporting__url_report__using_null_filter: false, twitter_ads__using_campaign_locations_report: true, twitter_ads__using_campaign_regions_report: true}' --target "$db" --full-refresh
dbt test --vars '{twitter_ads__using_keywords: false, ad_reporting__url_report__using_null_filter: false, twitter_ads__using_campaign_locations_report: true, twitter_ads__using_campaign_regions_report: true}' --target "$db"

dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"
