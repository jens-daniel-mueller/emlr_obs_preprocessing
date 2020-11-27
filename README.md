# Instructions to run the code in this repository

This code was written to be executed within RStudio.

## Scientific scope

The code in this repository is intended to estimate anthropogenic carbon in the ocean based on the eMLR(C*) method.

## Sharing code across analysis

Background information about sharing code across analysis in this repository, can be found [here](https://jdblischak.github.io/workflowr/articles/wflow-07-common-code.html){target="_blank"} on the workflowr homepage.

## Using child documents

Code chunks that are used across several .Rmd files are located in /analysis/child. Following child documents are available:

- setup.Rmd: Defines global options, loads libraries, functions and auxillary files. To run .Rmd files manually, the code in this child document must be executed first (Click "Run all", or Strg+Alt+R). This refers only to documents downstream of read_World_Ocean_Atlas_2018.Rmd, because this is where most auxillary files are created.


## Using functions

Functions are stored in .R files located under /code. Here, it is distinguished between:

biogeochemical_functions.R  

- calculate biogeochemical parameters, such as C*

mapping_functions.R  

- map properties, eg calculate \Delta C~ant~ by appliying model coeffcients to predictor climatologies, and regional averaging

plotting_functions.R  

- produce maps, zonal mean sections and other plots


## Unevaluated chunks

Following code chunks are not executed (set to eval=FALSE) in routine mode:

in eMLR_data_preparation.Rmd  

- plot_all_individual_cruises_clean

in eMLR_assumption_testing.Rmd  

- predictor_correlation_per_basin_era_slab  

in eMLR_model_fitting.Rmd  

- fit_best_models (only plot commands uncommented within loop)

in mapping_cant_calculation.Rmd  

- cant_section_by_model_eras_lon  

Respective code chunks create a high number of diagnostic figures as separate output which results in higher runtime of the code. Therefore, those chunks must be run manually to generate the desired output.


A [workflowr][] project.

[workflowr]: https://github.com/jdblischak/workflowr
