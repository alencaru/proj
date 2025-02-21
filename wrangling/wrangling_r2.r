library(tidyverse)
library(glue)
library(stringr)
library(janitor)

# limpeza de dados e criação de novas colunas
tb_car <- read_csv('./scrap/tabela_carros2.csv')


#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# resolvendo as colunas com 'kg'

tb_car |>
  select(where(~ any(str_detect(.x, " kg"), na.rm = TRUE)), id) |>
  mutate(across(where(is.character), ~ str_replace_all(.x, ",", "."))) |>
  select(-`Torque Máximo:`) -> tb_kg


# limpando a linha com dados errados

tb_kg |>
  mutate(
    `Torque Combinado:` = str_replace(
      `Torque Combinado:`, 
      'select \\* from carros_ficha_tecnica where id_carro in \\(select id_carro from carros where combustivel=', ''
    )
  ) -> tb_kg


# retirando os dados textuais das colunas com kg e alterando o nome da coluna conforme o texto encontrado e transformando o dado das colunas em float

tb_kg_corrigido <- map(1:10, 
  function(x){
    
    original_cl <- colnames(tb_kg)[x]
    value_cl <- tb_kg |> select(x) |> str_extract_all(' [a-z]+/+[a-z]+| [a-z]+') |> first() |> unique() |> str_trim() |> as.character()

    cl <- colnames(clean_names(tb_kg[, x]))
    coluna <- as.character(glue('{cl}_{value_cl}'))

    tb_kg %>%
     select(x) %>%
     separate(
      col = !!sym(original_cl), into = c(coluna, "a"), sep = " ", remove = TRUE, convert = TRUE
     ) %>%
     select(-a)
  }
) |>
list_cbind() |>
cbind(tb_car[,1])


#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# change columns with  kg/cv 

tb_car |>
  select(where(~ any(str_detect(.x, " kg/cv"), na.rm = TRUE))) |>
  mutate(across(where(is.character), ~ str_replace_all(.x, ",", "."))) -> tb_kg_cv


tb_kg_cv_corrigido <- map(1:ncol(tb_kg_cv), 
  function(x){
    
    original_cl <- colnames(tb_kg_cv)[x]
    value_cl <- tb_kg_cv |> select(x) |> str_extract_all(' [a-z]+/+[a-z]+| [a-z]+') |> first() |> unique() |> str_trim() |> as.character()

    cl <- colnames(clean_names(tb_kg_cv[, x]))
    coluna <- as.character(glue('{cl}_{value_cl}'))

    tb_kg_cv %>%
     select(x) %>%
     separate(
      col = !!sym(original_cl), into = c(coluna, "a"), sep = " ", remove = TRUE, convert = TRUE
     ) %>%
     select(-a)
  }
) |>
list_cbind() |>
cbind(tb_car[,1])

#------------------------------------------------------------------------------------------------------------------------------------------------------------
# corrigindo as colunas que contem os dados de textuais com mm (milimetros)


tb_car |>
  select(where(~ any(str_detect(.x, " mm"), na.rm = TRUE))) |>
  mutate(across(where(is.character), ~ str_replace_all(.x, ",", "."))) -> tb_mm


tb_mm_corrigido <- map(1:ncol(tb_mm), 
  function(x){
    
    original_cl <- colnames(tb_mm)[x]
    value_cl <- tb_mm |> select(x) |> str_extract_all(' [a-z]+/+[a-z]+| [a-z]+') |> first() |> unique() |> str_trim() |> as.character()

    cl <- colnames(clean_names(tb_mm[, x]))
    coluna <- as.character(glue('{cl}_{value_cl}'))

    tb_mm %>%
     select(original_cl) %>%
     separate(
      col = !!sym(original_cl), into = c(coluna, "a"), sep = " ", remove = TRUE, convert = TRUE
     ) %>%
     select(-a)
  }
) |>
list_cbind() |>
cbind(tb_car[,1])


#--------------------------------------------------------------------------------------------------------------------------------------------------
# criando a db_detalhes numerica

library(arrow)

db_detalhes <- read_parquet('db_detalhes.parquet')

db_detalhes |>
  group_by(ID) |>
  summarise(
    conforto = paste0(unique(conforto), collapse = ', '),
    conforto_n = str_count(conforto, ',') + 1
  ) -> tb_conforto


db_detalhes |>
  group_by(ID) |>
  summarise(
    seguranca = paste0(unique(seguranca), collapse = ' ,'),
    seguranca_n = str_count(seguranca, ',') + 1
  ) -> tb_seguranca


db_detalhes |>
  group_by(ID) |>
  summarise(
    infoteinimento = paste0(unique(infoteinimento), collapse = ' ,'),
    infoteinimento_n = str_count(infoteinimento) + 1
  ) -> tb_infoteinimento


# salvando os arquivos
write_csv(tb_conforto, 'tb_conforto_numeric.csv')
write_csv(tb_seguranca, 'tb_seguranca_numeric.csv')
write_csv(tb_infoteinimento, 'tb_infoteinimento_numeric.csv')

#---------------------------------------------------------------------
# criando a tabela de valores monotonicos de custo

tb_numeric <- read_csv('tab_car_numeric_3.csv')
colnames(tb_restante)

tb_criterios_numeric <- tibble(
  criterios = colnames(tb_numeric),
  multiplier = if_else(
    criterios %in% c(
      'peso_potencia_kg/cv','peso_torque_kg','peso_kg','consumo_rodoviario_km/l', "consumo_rodoviario_gasolina_km/l","consumo_urbano_gasolina_km/l",
      "consumo_rodoviario_diesel_km/l","consumo_urbano_diesel_km/l","consumo_rodoviario_km/l","consumo_urbano_km/l","consumo_rodoviario_alcool_km/l",
      "consumo_urbano_alcool_km/l", "consumo_rodoviario_diesel_km", "consumo_urbano_diesel_km","consumo_rodoviario_alcool_km","consumo_urbano_alcool_km",
      'aceleracao_0_100_km_h_s','frenagem_0_100_km_h_m','consumo_eletrico_kWh','valor_fipe', 'coeficiente_de_arrasto'
    ), -1, 1
   )
)

write_csv(tb_criterios_numeric, 'tab_criterios.csv')
