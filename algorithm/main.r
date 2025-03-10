library(tidyverse)
library(stringr)
library(glue)
library(janitor)

#---------------------------------------------------------------------------------------------------------
# chamando as funções criadas para limpar os dados
source('./wrangling/functions_etl.r')

# --------------------------------------------------------------------------------------------------------
# carregando a base de dados

tb_car <- read_csv('./scrap/tabela_carros2.csv')

# criando a lista de elemntos textuais para retirar das celulas a fim de deixar somente números
list_symbles <- c(
  ' graus',' mm', ' rpm', ' cv', ' cv/litro', ' kg/cv', ' kg/kgfm', ' kgfm/litro', 
  ' kg',' km/l', ' km/h', ' km', '(?<=\\s)s$', ' cm³', ' litros', '(?<=\\s)m$',
  ' m²$', ' kWh'
)

#---------------------------------------------------------------------------------------------------------
# aplicando a função de ETL em lote em todas as colunas
# resultado será uma tabela com somente dados numéricos

df <- map(list_symbles, 
  function(x){

      tb <- take_symble_to_column(tb_car, x)
      
      return(tb)

}) |>
list_cbind()

# limpando resíduos e recriando o ID
df |>
  rename("ID"=`...102`) |>
  select(-starts_with("...")) -> df

# salvando em arquivo em formato CSV
write_csv(df, 'tab_car_numeric_3.csv')

#-------------------------------------------------------------------------------------------------------
# testando o identificador de colunas

identifica_colunas(tb_car, ' kWh')

# aplicanco a função de correcao das colunas
tab_not_cleaned <- map(list_symbles, function(x){

  a <- identifica_colunas(tb_car, x)
  return(a)
}) |> 
  list_cbind() |>
  select(-starts_with('...')) |>
  colnames() #|>

# selecionando as colunas para retirar da planilha principal
tab_not_cleaned |> str_remove_all('...[0-9][0-9]$') |> unique() -> columns_to_filter

tb_car |> as_tibble() |> select(-any_of(columns_to_filter)) -> tb_restante

# Limpando colunas categoricas, de data e valor
tb_restante |>
  mutate(
    valor_fipe = str_replace_all(`Valor FIPE:`, '^R\\$ ', ''),
    valor_fipe = str_replace_all(valor_fipe, '\\(|\\)', ''),
    valor_fipe = str_trim(valor_fipe)
  ) |> 
  separate(
    valor_fipe, 
    into = c('valor_fipe', 'valor_data'), sep = ' ', remove = TRUE
  ) |> 
  mutate(
    `garantia_em_anos` = str_extract(`Garantia:`, '\\d+'),
    `garantia_em_anos` = as.integer(`garantia_em_anos`)
  ) |>
 separate(
    `Cilindros:`, into=c('cilindros', 'tipo_cilindro'),
    sep = '(?<=[0-9])\\s', ,
    fill = 'right',
    remove = TRUE
  ) |>
  mutate(
    valvulas_por_cilindro = as.numeric(`Válvulas por Cilindro:`),
    quantidade_de_marchas = as.numeric(`Quantidade de Marchas:`),
    geracao = as.numeric(`Geração:`)
  ) -> tb_restante

tb_restante |>
  mutate(
    valor_fipe = str_replace_all(valor_fipe, '\\.', ''),
    valor_fipe = as.numeric(valor_fipe)
  ) -> tb_restante
 
tb_restante |>  
  mutate(
    coeficiente_de_arrasto = str_replace(`Coeficiente de Arrasto:`, ',', '.'),
    coeficiente_de_arrasto = as.numeric(coeficiente_de_arrasto)
  ) -> tb_restante
  
write_csv(tb_restante, 'tabela_carros_quali.csv')

# corrigindo a coluna de torque maximo
# separando em 3 colunas: torque gasolina, alcool e rpm

tb_car |>
  select(`...1`, `Torque Máximo:`) |>
  rename("ID" = `...1`) |>
  clean_names() |>
  filter(str_detect(torque_maximo,'([A-Z])')) |> #-> tb_teste
  separate(
    col = torque_maximo,
    into = c("torque_max_al_kgfm", "torque_max_gas_kgfm", 'torque_m_rpm'),
    sep = '\\([A-Z]\\)',
    fill = 'right'
  ) |> 
  mutate(
    torque_max_al_kgfm = str_replace(torque_max_al_kgfm, ' kgfm', ''),
    torque_max_gas_kgfm = str_replace(torque_max_gas_kgfm, ' kgfm', ''),
    torque_m_rpm = str_replace(torque_m_rpm, ' rpm', ''),
    torque_m_rpm = str_replace(torque_m_rpm, ' a ', ''),
  ) |>
  mutate(across(where(is.character), ~ str_replace_all(.x, ",", "."))) |>
  mutate(
    torque_max_al_kgfm = as.numeric(torque_max_al_kgfm),
    torque_max_gas_kgfm = as.numeric(torque_max_gas_kgfm),
    torque_m_rpm = as.integer(torque_m_rpm),    
  )-> tb_torque_corrigido_1

tb_car |>
  select(`...1`, `Torque Máximo:`) |>
  rename("ID" = `...1`) |>
  clean_names() |>
  filter(!str_detect(torque_maximo,'([A-Z])')) |> #-> tb_teste
  separate(
    col = torque_maximo,
    into = c("torque_max_gas_kgfm", 'torque_m_rpm'),
    sep = ' a ',
    fill = 'right'
  ) |> 
  mutate(
   torque_max_gas_kgfm = str_replace(torque_max_gas_kgfm, ' kgfm', ''),
   torque_m_rpm = str_replace(torque_m_rpm, ' rpm', ''),
   torque_m_rpm = str_replace(torque_m_rpm, ' a ', ''),
  ) |>  
  mutate(across(where(is.character), ~ str_replace_all(.x, ",", "."))) |>
  mutate(
   torque_max_gas_kgfm = as.numeric(torque_max_gas_kgfm),
   torque_m_rpm = as.integer(torque_m_rpm),    
  )-> tb_torque_corrigido_2

# tabela final de torque maximo
tab_torque_maximo <- bind_rows(tb_torque_corrigido_1, tb_torque_corrigido_2)

write_csv(tab_torque_maximo, 'tabela_torque_maximo.csv')
#------------------------------------------------------------------------------------------------

#tb <- read_csv('db_detalhes.csv')
#tb_car <- read_csv('tabela_carros')

criterios <- read_csv('tab_criterios2.csv')

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
    'infoteinimento'
  )
) -> conj_criterios

#------------------------------------------------------------------------------------------------
# ordenando os criterios

conj_criterios |>
  arrange() |>
  mutate(
    grau_de_importancia = case_when(
      criterios == 'valor_fipe' ~ 16,
      criterios == 'consumo_urbano_gasolina_km/l' ~ 15,
      criterios == 'consumo_rodoviario_gasolina_km/l' ~ 15,
      criterios == 'consumo_urbano_alcool_km/l' ~ 14,
      criterios == 'consumo_rodoviario_alcool_km/l' ~ 14,
      criterios == 'seguranca' ~ 16,
      criterios == 'conforto' ~ 13,
      criterios == 'infoteinimento' ~ 12,
      criterios == 'distancia_entre_eixos_mm' ~ 11,
      criterios == 'porta_malas_litros' ~ 10,
      criterios == 'velocidade_maxima_km/h' ~ 9,
      criterios == 'peso_potencia_kg/cv' ~ 8,
      criterios == 'autonomia_rodoviaria_gasolina_km' ~ 7,
      criterios == 'altura_mm' ~ 6,
      TRUE ~ 5
    )
  ) -> conj_criterios

#-------------------------------------------------------------------------------------------------