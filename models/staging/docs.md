
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