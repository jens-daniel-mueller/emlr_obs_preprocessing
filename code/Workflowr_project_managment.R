# This script summarizes the central commands to work with code in this R project
# using the Workflowr package.
# For details please refer to:
# https://jdblischak.github.io/workflowr/articles/wflow-01-getting-started.html

# commit regular changes (locally) and rebuild site
# this takes only changed files into account
wflow_publish(all = TRUE, message = "added SO_5 basin mask")

# commit changes including _site.yml (locally) and rebuild site in the specified order
# you can also run this code with only some of the files. In this case remove the rebuild=TRUE command
wflow_publish(here::here(
  "analysis",
  c(
    "index.Rmd",
    "config_dependencies.Rmd",
    "config_parameterization.Rmd",
    "read_World_Ocean_Atlas_2018.Rmd",
    "read_GLODAPv2_2016_MappedClimatologies.Rmd",
    "read_OceanSODA.Rmd",
    "read_GLODAPv2_2020.Rmd",
    "read_GLODAPv2_2021.Rmd",
    "read_Gruber_2019.Rmd",
    "read_Sabine_2004.Rmd",
    "read_CO2_atm.Rmd",
    "analysis_regional_clusters.Rmd"

  )
),
message = "rerun with new setup_obs.Rmd file",
republish = TRUE)


# Push latest version to GitHub
wflow_git_push()
jens-daniel-mueller
