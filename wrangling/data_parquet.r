library(tidyverse)
library(arrow)

tb_det <- read_csv('db_detalhes.csv')

tb_det |>
  filter(across(c(conforto, infoteinimento, seguranca), ~!is.na(.x))) |>
  rename(ID = id) |>
  arrow::write_parquet('db_detalhes.parquet')
