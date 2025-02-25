library(tidyverse)
library(stringr)
library(glue)
library(janitor)
library(magrittr)

#---------------------------------------------------------------------------------------------------------
# chamando as funções criadas para limpar os dados
source('./wrangling/functions_etl.r')

# ----------------------------------------

criterios <- read_csv('tab_criterios2.csv') |> bind_rows(data.frame(criterios = 'ano', multiplier = 1))

criterios |>
  bind_rows(
    data.frame(
        criterios = c('valor_fipe','conforto','seguranca','infoteinimento'),
        multiplier = c(-1,1,1,1)
    )
  ) |>
  filter(criterios %in%
    c(
    'valor_fipe', 
    'consumo_urbano_gasolina_km/l',
    'consumo_rodoviario_gasolina_km/l',
    'autonomia_rodoviaria_gasolina_km',
    'porta_malas_litros',
    'velocidade_maxima_km/h',
    'peso_potencia_kg/cv',
    'distancia_entre_eixos_mm',
    'altura_mm',
    'consumo_rodoviario_alcool_km/l',
    'consumo_urbano_alcool_km/l',
    'conforto',
    'seguranca',
    'infoteinimento',
    'ano'
  )
) -> conj_criterios


conj_criterios |>
  arrange() |>
  mutate(
    grau_de_importancia = case_when(
      criterios == 'valor_fipe' ~ 16,
      criterios == 'consumo_urbano_gasolina_km/l' ~ 15,
      criterios == 'consumo_rodoviario_gasolina_km/l' ~ 15,
      criterios == 'consumo_urbano_alcool_km/l' ~ 14,
      criterios == 'consumo_rodoviario_alcool_km/l' ~ 14,
      criterios == 'seguranca' ~ 14,
      criterios == 'conforto' ~ 6,
      criterios == 'infoteinimento' ~ 12,
      criterios == 'distancia_entre_eixos_mm' ~ 11,
      criterios == 'porta_malas_litros' ~ 10,
      criterios == 'velocidade_maxima_km/h' ~ 9,
      criterios == 'peso_potencia_kg/cv' ~ 8,
      criterios == 'autonomia_rodoviaria_gasolina_km' ~ 7,
      criterios == 'altura_mm' ~ 6,
      criterios == 'ano' ~ 16,
      TRUE ~ 5
    )
  ) -> conj_criterios

conj_criterios |> mutate(criterios = str_replace(criterios, '/', '_')) -> conj_criterios

conj_criterios |>
  mutate(weight = (grau_de_importancia) * multiplier / sum(grau_de_importancia)) -> conj_criterios

conj_criterios |>
  mutate(
    criterios = case_when(
      criterios == 'seguranca' ~ 'seguranca_n',
      criterios == 'infoteinimento' ~ 'infoteinimento_n',
      criterios == 'conforto' ~ 'conforto_n',
      TRUE ~ criterios
    )
  ) -> conj_criterios

#-------------------------------------------------------------------------------------------------
# tablea quli

tab_quali <- read.csv('tabela_carros_quali_2.csv')

#-------------------------------------------------------------------------------------------------
# tabela numeric

tab_numeric <- read.csv('tab_car_numeric_4.csv') |>
  clean_names()

#-------------------------------------------------------------------------------------------------
# tabela seguranca, conforto e infoteiniment
# os valores são baseados na quantidade de itens

tab_conforto <- read.csv('tb_conforto_numeric.csv')
tab_seguranca <- read.csv('tb_seguranca_numeric.csv')
tb_info <- read.csv('tb_infoteinimento_numeric.csv')

#-------------------------------------------------------------------------------------------------

tab_geral <- tab_quali |>
  select(ID, 'Marca.', 'Modelo.Base.','Ano.') |>
  clean_names() |>
  left_join(
    (tab_numeric |> select(any_of(conj_criterios$criterios), id))
  ) |>
  left_join(
    tb_info |> select(ID, infoteinimento_n) |> clean_names()
  ) |>
  left_join(
    tab_seguranca |> select(ID, seguranca_n) |> clean_names()
  ) |>
  left_join(
    tab_conforto |> select(ID, conforto_n) |> clean_names()
  )

#--------------------------------------------------------------------------------------------------
# aplicando funcao de normalizacao na tabela

tab_geral |>
  filter(!is.na(valor_fipe), !is.na(consumo_urbano_gasolina_km_l)) |>
  mutate(
    infoteinimento_n   = if_else(is.na(infoteinimento_n), 0, infoteinimento_n),
    seguranca_n = if_else(is.na(seguranca_n), 0, seguranca_n),
    conforto_n = if_else(is.na(conforto_n), 0, conforto_n)
  ) |>
  mutate(
    across(starts_with('consumo') & where(is.numeric), ~replace_na(.x, mean(.x, na.rm = TRUE)))
  ) -> tab_geral

#-------------------------------------------------------------------------------------------------
# aplicando a funcao normalizar

tab_geral |>
  mutate(porta_malas_litros = if_else(is.na(porta_malas_litros), 0, porta_malas_litros)) |>
  mutate(
    across(where(is.numeric) & !starts_with('id'), ~function_normalization(.x))
  ) -> tab_geral


tab_geral |>
  unnest() |>
  select(where(is.numeric)) |>
  as_tibble() %T>%
  {
    colunames <<- colnames(.) |> setdiff('id')
  } %>%
  pivot_longer(
    cols = colunames,
    names_to = "A",
    values_to = 'value' 
  ) %>%
  left_join(conj_criterios[,c('criterios','weight')], by = c("A" = "criterios")) |>
  mutate(weighted = value * weight) |>
  select(-weight, -value) |>
  pivot_wider(
    names_from = 'A',
    values_from = 'weighted'
  ) |>
  unnest() |>
  unique() |> 
  rowwise() %>%
  mutate(
    final_rank = sum(c_across(where(is.numeric) & !id))
  ) |> 
  arrange(desc(final_rank)) |> slice(1:10) -> tab_geral_w
  # left_join(
  #   tab_geral |> select(id, marca, modelo_base), by = 'id'
  # ) |>
  # select(id, marca, modelo_base, final_rank) -> tab_geral_w

#----------------------------------------------------------------------------------------------
# vendo quais carros ficaram em primeiro

nids <- tab_geral_w$id

tab_quali |> inner_join(tab_geral_w |> select(id, final_rank), by = c('ID' = 'id')) |> arrange(desc(final_rank))
