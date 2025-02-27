library(tidyverse)
library(glue)
library(gt)
library(ggplot2)
library(grid)
library(gridExtra)
library(arrow)

#-----------------------------------------------------------------------------------------------------
# criar as tabela sem formato png para colocar no tcc

# tabela original

tabela_carros_raw <- read_csv('./scrap/tabela_carros2.csv')

# nome das colunas após o download dos dados via scrapping
lista_colunas <-colnames(tabela_carros_raw) |> 
  matrix(nrow = 24, ncol = 4, byrow = TRUE) |>
  as.data.frame() |>
  gt()

# glimpse das tabela 
tabela_carros_raw |>
  select(
    "...1","Marca:","Modelo Base:","Versão:","Ano:", "Consumo Rodoviário (Gasolina):", "Valor FIPE:","Torque Máximo:","Válvulas por Cilindro:",
    "Potência Específica:"
    #starts_with('consumo'), 
    #starts_with('valor')
  ) |>
  slice(1:6) |>
  gt()

# olhando a sgunda tabela com dados de seguranca, entreteinimento e conforto
tabela_segunda_dados_quali_raw <- open_dataset('db_detalhes.parquet') %>%
  head(5) %>%
  collect() |>
  gt()

# tabelas corrigidas e detalheadas
tabela_criterios <- read_csv('tab_criterios2.csv') |>
  head(3) |>
  bind_rows(
    read_csv('tab_criterios2.csv') |>
      filter(multiplier < 0) |>
      head(3)
  ) |>
  gt()

# tabela quanti definida
tabela_quali <- read_csv('tabela_carros_quali_2.csv') |>
  select(c(1:3, 10:15)) |>
  head() |>
  gt()

# tabela numeric corrgida 
tabela_numeric <- read_csv('tab_car_numeric_4.csv') %>%
  select(c(1:4, 40:43)) |>
  drop_na() |>
  head(6) |>
  gt()

# tabela normalizada
tabela_normalizada <- read_csv('tabela_geral_weight.csv') |>
  select(c(1:5, 14:16)) |>
  head() |>
  gt()

# tabela final rank
tabela_rank <- read_csv('tabela_final_rank.csv') |>
  head() |>
  gt()

