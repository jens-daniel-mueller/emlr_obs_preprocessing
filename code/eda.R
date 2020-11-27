eda <- function(df, name){

library(DataExplorer)

config <- configure_report(
  add_plot_prcomp = FALSE,
  add_plot_qq = FALSE,
  plot_correlation_args = list(type = "continuous"),
  global_ggtheme = quote(theme_bw())
)

df %>%
  create_report(output_dir = "docs/",
                output_file = paste("EDA_report_",name,".html", sep = ""),
                report_title = paste("eMLR(C*) |",name,"data - Exploratory Data Analysis"),
                config = config
  )
}
