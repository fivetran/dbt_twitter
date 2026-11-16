
{% docs _fivetran_synced -%}
When the record was last synced by Fivetran.
{%- enddocs %}

{% docs created_at %}
The timestamp the account was created.
{% enddocs %}

{% docs updated_at -%}
The timestamp the account was last updated.
{%- enddocs %}

{% docs deleted -%}
Whether the record has been deleted or not.
{%- enddocs %}

{% docs source_relation %}
The source of the record if the unioning functionality is being used. If not this field will be empty.
{% enddocs %}

{% docs country %}
Long-form name of the country being reported on.
{% enddocs %}

{% docs region %}
Long-form name of the geopgraphic region being reported on.
{% enddocs %}

{% docs age_range %}
Audience age range, such as `18 to 24`, `25 to 34`, `over 65`, or `AGE_UNDER_13`.
{% enddocs %}

{% docs min_age %}
Lower bound of the audience age range, parsed from `age_range`. For example, `18 to 24` and `over 65` return 18 and 65, and `AGE_UNDER_13` returns 0. Null when the age range isn't in a recognized format.
{% enddocs %}

{% docs max_age %}
Upper bound of the audience age range, parsed from `age_range`. For example, `18 to 24` returns 24, `AGE_UNDER_13` returns 12, and the open-ended `over 65` returns 100. Null when the age range isn't in a recognized format.
{% enddocs %}

{% docs gender %}
Audience gender, such as `Female` or `Male`.
{% enddocs %}
