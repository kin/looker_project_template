## This is an explore file, it should house all of your explore related parameters and joins
## Each explore file should only refer to a single explore. Your project will have multiple explore files for multiple explores.

## Include
include: "/3_views/**/*.view" ## This will include all relevant view files for selection in this explore

## Access Grants
access_grant: example_permissions { ## Use access grants to limit viewing to the data. Remove if unnecessary.
  user_attribute: department
  allowed_values: [""]
}

## Explore Definitions
explore: example_explore { ## This is how you define the explore and include required views for joining
  from: example_view
  label: "The surfaced name of the explore"
  description: "The contextual description for the explore"
  fields: [ALL_FIELDS*] ## This is where you can specifiy what fields to expose in the base view
  required_access_grants: [example_permissions] ## Remove this if you don't need security
}
