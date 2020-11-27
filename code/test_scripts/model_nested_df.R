# from https://tidyr.tidyverse.org/articles/nest.html

library(tidyverse)

mtcars <- mtcars

mtcars_nested <- mtcars %>%
  group_by(cyl) %>%
  nest()


mtcars_nested_model <- mtcars_nested %>%
  mutate(model = map(data, function(df) lm(mpg ~ wt, data = df)))

mtcars_nested_predict <- mtcars_nested %>%
  mutate(model = map(data, function(df) lm(mpg ~ wt, data = df)),
         predict = map(model, predict)) %>%
  select(-model)

mtcars_nested <- full_join(mtcars_nested_model, mtcars_nested_predict)


# from https://www.brodrigues.co/blog/2018-01-19-mapping_functions_with_any_cols/

library(tidyverse)

data(mtcars)
data(iris)

data_list = list(mtcars, iris)

my_summarise_f = function(dataset, cols, funcs){
  dataset %>%
    summarise_at(vars(!!!cols), lst(!!!funcs)) # funs() -> lst()
}

mtcars %>%
  my_summarise_f(quos(mpg, drat, hp), quos(mean, sd, max))


# from https://www.youtube.com/watch?v=rz3_FDVt9eg

library(tidyverse)

mtcars <- mtcars

funs <- list(mean, median, sd)

funs %>%
  map(~ mtcars %>% map_dbl(.x))


# with for loop

library(tidyverse)
library(broom)

mtcars_nested <- mtcars %>%
  group_by(cyl) %>%
  nest()

lm_mpg_wt <- function(df)
  lm(mpg ~ wt, data = df)

lm_mpg_qsec <- function(df)
  lm(mpg ~ qsec, data = df)

mtcars_nested_lm_mpg_wt <- mtcars_nested %>%
  mutate(model = map(data, lm_mpg_wt),
         tidied = map(model, tidy))

mtcars_nested_lm_mpg_wt %>%
  unnest(tidied)

models <- lst(lm_mpg_wt,
              lm_mpg_qsec)

for (i in 1:length(models)) {

  print(i)

  mtcars_nested_temp <- mtcars_nested %>%
    mutate(model = map(data, models[i]),
           tidied = map(model, tidy))

  if (exists("mtcars_nested_models")) {
    mtcars_nested_models <-
      bind_rows(mtcars_nested_models, mtcars_nested_temp)
  }

  if (!exists("mtcars_nested_models")) {
    mtcars_nested_models <- mtcars_nested_temp
  }

}

mtcars_nested_models %>%
  unnest(tidied)
