# This script summarizes the central commands to work with code in this R project
# using the Workflowr package.
# For details please refer to:
# https://jdblischak.github.io/workflowr/articles/wflow-01-getting-started.html

# commit regular changes (locally) and rebuild site
# this takes only changed files into account
wflow_publish(all = TRUE, message = "write published, unmasked column inventories of G19 to files")

# commit changes including _site.yml (locally) and rebuild site in the specified order
# you can also run this code with only some of the files. In this case remove the rebuild=TRUE command
wflow_publish(here::here(
  "analysis",
  c(
    "index.Rmd",
    "config_dependencies.Rmd",
    "config_parameterization.Rmd",
    "read_GCB.Rmd",
    "read_regions.Rmd",
    "read_World_Ocean_Atlas_2018.Rmd",
    "read_GLODAPv2_2016_MappedClimatologies.Rmd",
    "read_GLODAPv2_2021.Rmd",
    "read_Key_2004.Rmd",
    "read_Gruber_2019.Rmd",
    "read_Sabine_2004.Rmd",
    "read_CO2_atm.Rmd",
    "read_OceanSODA.Rmd",
    "read_RECCAP2_flux_products.Rmd"
  )
),
message = "added GCB data read-in and rebuild",
republish = TRUE)


# Push latest version to GitHub
wflow_git_push()
jens-daniel-mueller
