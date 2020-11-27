# This script summarizes the central commands and steps to set-up and organize a R project
# using the Workflowr package.
# For details please refer to:
# https://jdblischak.github.io/workflowr/articles/wflow-01-getting-started.html

library("workflowr")

# Start project -----------------------------------------------------------

# open this script from the folder where the project folder should be created

wflow_start("XXX")

# After starting the project, do the following:

# Copy this Workflowr_project_managment.R file in /code

# copy in .gitignore after starting the project
/data
/output
#

# delete about.Rmd and license.Rmd in /analysis and analysis/_site.yml

# copy or adapt in analysis/_site.yml:
navbar:
 title: XXX

output:
 workflowr::wflow_html:
   theme: flatly
   code_folding: hide

# Build the website -------------------------------------------------------

wflow_build()
wflow_status()
wflow_publish(c("analysis/index.Rmd"),
              "Publish the initial files for myproject")

# Deploy the website ------------------------------------------------------

wflow_use_github("jens-daniel-mueller")
wflow_git_push()
jens-daniel-mueller

# Final changes after first deployment ------------------------------------

# creates a source code link in the navbar
wflow_publish(c("analysis/index.Rmd"),
              "Publish with source code link")

# to also set a link to jens homepage in the navbar
# copy or adapt in analysis/_site.yml:
# - icon: fa-home
#   text: Jens' homepage
#   href: https://jens-daniel-mueller.github.io/



# Change short project description in analysis/index.Rmd and README.md

# On this website we present our ongoing ambition to XXX
#
# Please navigate trough the navbar on top to take a look at the various chapters of this project.
# The links in the upper right corner bring you to the source code of this project and back to Jens' main homepage.
#
# (c) Dr. Jens Daniel Müller, 2019

# Change description in README.md

# In this repo we present our ongoing ambition XXX
# Results can be accessed under:
# https://jens-daniel-mueller.github.io/XXX
#
#
# Dr. Jens Daniel Müller, 2019


# Lastly, now that your code is on GitHub, you need to tell GitHub that you want
# the files in docs/ to be published as a website.
# Go to Settings -> GitHub Pages and choose "master branch docs/ folder" as the Source (instructions).



# Add a new analysis file -------------------------------------------------

wflow_open("analysis/first-analysis.Rmd")

# After opening a new analysis file, do the following:

# change: author: "Jens Daniel Müller"
# change: date:  "`r format(Sys.time(), '%d %B, %Y')`"

# include link to new html file in _site.yml

# Finally, rebuild, push and push again from R-Studio remaining files not taken care of by workflowr





# Repeated comments during work on the project ----------------------------

# to check impact of latest updates
wflow_build()

# commit regular changes (locally) and rebuild site
wflow_publish(here::here(
  "analysis",
  c(
    "analysis_previous_studies.Rmd"
  )
),
message = "use setup child Rmd file")

# commit regular changes (locally) and rebuild site
wflow_publish(all = TRUE, message = "XXX")

# commit changes including _site.yml (locally) and rebuild site
wflow_publish(c("analysis/*Rmd"), message = "XXX", republish = TRUE)

# commit changes including _site.yml (locally) and rebuild site in the specified order
wflow_publish(here::here(
  "analysis",
  c(
    "index.Rmd",
    "config_dependencies.Rmd",
    "config_nomenclature.Rmd",
    "config_parameterization.Rmd",
    "read_World_Ocean_Atlas_2018.Rmd",
    "read_GLODAPv2_2020.Rmd",
    "read_GLODAPv2_2016_MappedClimatologies.Rmd",
    "read_Gruber_2019_Cant.Rmd",
    "read_Sabine_2004_Cant.Rmd",
    "read_CO2_atm.Rmd",
    "eMLR_data_preparation.Rmd",
    "eMLR_assumption_testing.Rmd",
    "eMLR_model_fitting.Rmd",
    "mapping_predictor_preparation.Rmd",
    "mapping_cant_calculation.Rmd",
    "mapping_cstar_calculation.Rmd",
    "analysis_this_study_vs_Gruber_2019.Rmd",
    "analysis_this_study.Rmd"
  )
),
message = "XXX",
republish = TRUE)



# Push latest version to GitHub
wflow_git_push()
jens-daniel-mueller
