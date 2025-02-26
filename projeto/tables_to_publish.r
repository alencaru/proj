library(tidyverse)
library(glue)
library(gt)

#-----------------------------------------------------------------------------------------------------
# criar as tabela sem formato png para colocar no tcc

# tabela original

tabela_carros_raw <- read_csv('./scrap/tabela_carros2.csv')

tabela_carros_raw |>
  select(
    "...1","Marca:","Modelo Base:","Versão:","Ano:",
    starts_with('consumo'), 
    starts_with('valor')
  ) |>
  slice(1:6) |>
  gt()
