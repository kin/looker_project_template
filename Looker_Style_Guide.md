# Looker Style Guide
___
> <a href="https://cloud.google.com/looker/docs/reference/lookml-quick-reference" target="_blank">Link to the Google Cloud Looker Documentation</a>

___
## Jump to Section

- [File Structure](#file-structure)
  - [Models](#models)
    - [Labels](#labels)
  - [Explores](#explores)
    - [Fields](#fields)
      - [Sets](#sets)
  - [Views](#views)
    - [Include and Refinements](#include-and-refinements)
    - [Datagroup Triggers](#datagroup-triggers)
- [Field Guidelines](#field-guidelines)
  - [Flags](#flags)
  - [Dimension Groups and Time Frames](#dimension-groups-and-time-frames)
  - [Measures](#measures)
  - [Value Formatting](#value-formatting)
  - [Ordering Dimensions](#ordering-dimensions)

# File Structure
___

## <a href="https://cloud.google.com/looker/docs/reference/param-model" target="_blank">Models</a>

### Layout

- Keep the **Model** file relatively short and concise
- Use in-line comments as section headers. Common section headers and their order include:
  - \## Model configuration
  - \## Explores
- When defining a Model, utilize the following framework and ensure there is adequate spacing between each section:

```
## Model Configuration

label:

connection:

access_grant: ## Use this to apply security policies at the model level

## Explores

explore:

  join:
```

<br>

### Labels

- Use the **Label** parameter to define custom labels at the Explore Menu level. Should there be more than one explore within the model, ensure that the model file is named simply and concisely
  - For instance, when applying a model label of **Market Research**, the result looks like so:

<img src="https://cloud.google.com/static/looker/docs/images/develop-label-model-custom-2206.png" width="50%" height="50%">

<br>

[Back to Top](#looker-style-guide)

___
## <a href="https://cloud.google.com/looker/docs/reference/param-explore" target="_blank">Explores</a>

- When defining a new explore, there are many parameters you _can_ use, but always utilize at least these following parameters:

```
explore: policies {
  label:
  description:
  join: {
    sql_on:
  }
  fields:
}
```

<br>

> Note that the **view_label** parameter is missing here. While it is definitely best practice to ensure that view_labels are created, due to the structure of our DBT based view files we should utilize view_labels within the **views** theselves. This ensures that we have a straightforward way of grouping multiple fields and dimensions together without relying on self-joins at the explore level to group things together.

<br>

### <a href="https://cloud.google.com/looker/docs/reference/param-explore-fields" target="_blank">Fields</a>

- **Fields** is one of the most important parameters to use in order to keep explores concise and focused
- The **Fields** parameter allows you to specify a group of individual "fields" (_dimensions and measures_) from a view file to pull into an explore
  - So rather than including all 100 dimensions and measures from an existing view, you can choose to select between 5-10 to pull into the explore and group accordingly
  - The syntax is as follows:

```
explore: policies {
  fields: [
    policy_id
    , full_policy_name
    , policy_created_date
    , premium_amount
  ]
}
```

<br>

#### <a href="https://cloud.google.com/looker/docs/reference/param-view-set" target="_blank">Sets</a>

Alternatively to selecting individual fields, you can utilize a set defined within the _view file_ to preemtively select a handful of fields to pull in at the explore level.

Creating _base sets_ should be the go-to standard as it makes modifying and updating fields within an explore incredibly easy without having to comb through all of the fields at the explore level.

**Within the Explore:**
<br>
```
explore: policies {
  fields:[base*]
}
```
<br>
**Within the View:**
<br>
```
view: policies_table
sql_table_name: dbt_policies

dimension: policy_id {}

dimension: full_policy_name {}

dimenision_group: policy_created_date {}

measure: premium_amount {}

... At the bottom of the view file:

set: base {
  fields: [
    policy_id
    , full_policy_name
    , policy_created_date
    , premium_amount
  ]
}

```

<br>

Doing something like the above would then expose only the fields defined in the **base set** within the explore of choice. This should be the standard process for exposing dimensions and measures.

> Note: Utilizing sets is most useful when joining tables into your base explore table, you likely will want all dimensions and measures within the core table but might only want a few dimensions and measures repurposed from another view elsewhere.

<br>

[Back to Top](#looker-style-guide)

___
## <a href="https://cloud.google.com/looker/docs/reference/param-view" target="_blank">Views</a>

View files can get incredibly large and incredibly messy. Utilize these standards to keep view files looking neat and readable in case other edits need to be made further down the line.

### Layout

Ensure your views are always laid out similarly to the following:

```
include:

view: marketing_view {
sql_table_name: dbt_marketing

  ## Primary Key
  dimension: person_id {}

  ## Parameters
  parameter: date_parameter {}

  ## Filters
  filter: marketing_filter {}

  ## Hidden Fields
  dimension: secret_helper_dim {
    hidden: yes
  }

  ## Timestamps
  dimension_group: person_created_date {}

  dimension_group: spend_date {}

  ## Flags
  dimension: is_eligible_lead {}

  ## Dimensions
  dimension: utm_source {}

  ## Measures
  measure: count_of_leads {}

  ## Sets
  set: base {
    fields: [
      person_id
      , person_created_date
      ...
    ]
  }
}
```

<br>

- Ensure that there is use of inline comments. Comments give clarity to the structure of the view file and allow for easier navigation
- Dimensions and Measures should be indented after the view configuration parameters

<br>

[Back to Top](#looker-style-guide)

___
### <a href="https://cloud.google.com/looker/docs/lookml-refinements" target="_blank">Include and Refinements</a>

- Use the **Include** parameter to include any other _.lkml_ files you might need at the **view** level. This also works at the **model** or **explore** level
  - This allows you to leverage the fields defined within the included lkml file in the new view
- You can use the include parameter in combination with a _**refinement**_ to effectively extend another view file to leverage its dimensions or measures, without modifying the underlying file
  - This is great for projects where you require specific dimensions and measures from a particular view, but need to either make some slight modifications or join it in a particular fashion
  - Its also great for keeping all of the work in once spot for future reference

#### Example

I need to create a custom analysis for a particular project to use on a dashboard but I don't want to modify the existing view to create these measures and dimensions.

Here's my starting view:

```
view: policies {
sql_table_name: dbt.policies

  dimension: policy_id {}

  dimension_group: created {}

  dimension: premium_amount {}
}
```

I can then include this view into a new view and leverage these dimensions and measures without modifying the existing policies view:

```
include: "views/policies.view.lkml"

view: +policies { ## The + sign here indicates that this view is a refinement of the Policies view

  ## Parameters

  parameter: example_1 {}

  ## Custom Measures

  measure: new_measure {
    type: sum
    sql: ${premium_amount}
    ## Note here that I don't have to make any view references to ${premium_amount}, I can use it directly in the view since its already been included into the file
  }
}
```

A good example of this process is the Finance Period Analysis View found in mart_data_castle within "views/derived_tables/finance_period_analysis.lkml".

<br>

[Back to Top](#looker-style-guide)

___
### <a href="https://cloud.google.com/looker/docs/reference/param-model-datagroup#usage" target="_blank">Datagroup Triggers</a>

- You can set this up at the model level, but the cleanest and likely best way to do this is likely within its own _.lkml_ file
- Create a _datagroups.lkml_ file within each project if one doesn't exist already
  - This file should include all of the required datagroup triggers that we would need to utilize within the view. This file can also be leveraged within the **model** to set sql_triggers at the model or explore level

```
## Datagroups.lkml

datagroup: daily {
 max_cache_age: "24 hours"
 sql_trigger: SELECT CURRENT_DATE();;
}

```

You can then reference the file like so:

```
## Model Configuration

include: "datagroups.lkml"

## Explores

explore: policies {
  persist_with: datagroup_trigger_24hrs
  from: dbt_policies
  ...
}
```

<br>

[Back to Top](#looker-style-guide)

# Field Guidelines
___

- Always ensure that descriptions are present in every dimension and measure
  - Descriptions should be clear enough that all non-technical Looker users can understand the intent of the dimension or measure

___
## Flags

- When naming _yesno_ fields, use an interrogative structure (e.g., “Is Eligible Lead” instead of “Eligible Lead”). This more naturally lends itself to the ‘yes’ or ‘no’ that appears in the column.
- Do not include “Yes/No” in the label of a _yesno_ (boolean) field. Looker includes this by default.
- Underlying data types for a yesno field must be either boolean (true/false) or integer (1/0). Otherwise you will need to pass the field through a case statement in the SQL parameter.


```
# Bad
  dimension: eligible_lead {
    type: yesno
    sql: ${is_kin_eligible_lead};;
    label: "Is Eligible Lead (Yes/No)"
  }

# Good
  dimension: is_eligible_lead {
    type: yesno
    sql: ${is_kin_eligible_lead};;
    label: "Is Eligible Lead"
  }
```

<br>

[Back to Top](#looker-style-guide)

___
## Dimension Groups and Timeframes

- Avoid the words at, **date** or **time** at the end of a dimension group field name. Looker appends each timeframe to the end of the dimension name: **created_date** becomes **created_date_date**, **created_date_month**, etc.
  - Instead use **created** which becomes **created_date**, **created_month**, etc.

```
# Bad
  dimension_group: created_at {
    type: time
    timeframes: [
      time,
      date,
      week,
      month,
      raw
    ]
    sql: ${TABLE}.created_at ;;
  }

# Good
  dimension_group: created {
    type: time
    timeframes: [
      time,
      date,
      week,
      month,
      raw
    ]
    sql: ${TABLE}.created_at ;;
  }
```

<br>

[Back to Top](#looker-style-guide)

___
## Measures

- Whenever possible measures should reference LookML dimensions rather than the source table.

```
# Bad
  measure: count_of_policies {
    type: count
    sql: ${TABLE}.policy_id
  }

# Good
  measure: count_of_policies {
    type: count
    sql: ${policy_id}
  }
```
<br>
- Use a common term to name <a href="https://docs.looker.com/reference/field-reference/measure-type-reference#measure_type_categories" target="_blank">aggregate measures</a>. For example:
  - Sum: total_measure
  - Count: count_measure
  - Average: avg_measure
  - Max: max_measure
  - Min: min_measure
  - Median: median_measure

<br>

[Back to Top](#looker-style-guide)

___
## <a href="https://docs.looker.com/reference/field-params/value_format" target="_blank">Value Formatting</a>


### Currencies
- By default cast currency values with no cents (e.g., **value_format_name: usd_0**)
- Display cents (e.g., **value_format_name: usd**) if they provide analytical value or are required

<br>

### Numbers
- By default cast numeric values with no decimals (e.g., **value_format_name: decimal_0**)
- Display decimals (e.g., **value_format_name: decimal_1**, **value_format_name: decimal_2**) if they provide analytical value or are required. The preference is to display the fewest number of decimals as needed to meet the business stakeholders' requirements.

<br>

### Percents
- By default cast percents with no decimals (e.g., **value_format_name: percent_0**)
- Display decimals (e.g., **value_format_name: percent_1**, **value_format_name: percent_2**) if they provide analytical value or are required. The preference is to display the fewest number of decimals as needed to meet the business stakeholders' requirements.

<br>

[Back to Top](#looker-style-guide)

___
## <a href="https://docs.looker.com/reference/field-params/order_by_field" target="_blank">Ordering Dimensions</a>

You can sort results of a dimension, dimension group, or measure using the order_by_field parameter in LookML. This can be particularly useful in some situations. For example, you can overwrite Looker’s default behavior to order **delivery_status** alphabetically and order results in based on business logic, instead.

| Sort alphabetically  | Sort according to business logic |
| :-------------: | :-------------: |
| (default behavior)    | (applying order_by_field) |
| Cancelled  | Pending  |
| Delivered  | Ordered  |
| Ordered  | Shipped  |
| Pending  | Delivered  |
| Shipped  | Cancelled  |

<br>

[Back to Top](#looker-style-guide)

___

_This style guide takes inspiration from the Brooklyn Data Co. <a href="https://github.com/brooklyn-data/co/blob/main/looker_style_guide.md#LookML-file-management" target="_blank">Looker Style Guide</a> as well as many other sources._
