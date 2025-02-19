library(tidyverse)
library(glue)
library(stringr)
library(janitor)


tb1 = read.csv('./scrap/tabela_detalhes.csv')

tb1 %>%
  separate_longer_delim('conforto', delim = ',') %>%
  separate_longer_delim('infoteinimento', delim = ',') %>%
  separate_longer_delim('seguranca', delim = ',') -> tab2

str_detect("['✔ Ajuste do volante em altura'", '✔')

tab2 %>%
  mutate(
    conforto = str_replace_all(conforto, '✔', ''),
    conforto = str_replace_all(conforto, '\\[', ''),
    conforto = str_replace_all(conforto, '\\]', ''),
    conforto = str_replace_all(conforto, '^\' ', ''),
    conforto = str_replace_all(conforto, '\'', '')
  ) %>%
  mutate(
    infoteinimento = str_replace_all(infoteinimento, '✔', ''),
    infoteinimento = str_replace_all(infoteinimento, '\\[', ''),
    infoteinimento = str_replace_all(infoteinimento, '\\]', ''),
    infoteinimento = str_replace_all(infoteinimento, '^\' ', ''),
    infoteinimento = str_replace_all(infoteinimento, '\'', '')
  ) %>%
  mutate(
    seguranca = str_replace_all(seguranca, '✔', ''),
    seguranca = str_replace_all(seguranca, '\\[', ''),
    seguranca = str_replace_all(seguranca, '\\]', ''),
    seguranca = str_replace_all(seguranca, '^\' ', ''),
    seguranca = str_replace_all(seguranca, ' \' ', ''),
    seguranca = str_replace_all(seguranca, '\' ', '')
) -> tb3

write_csv(tb3, 'db_detalhes.csv')

#------------------------------------------------------------------
# limpeza de dados e criação de novas colunas
tb_car <- read_csv('./scrap/tabela_carros2.csv')

tb_car |>
  mutate(
    valor_fipe = str_replace_all(`Valor FIPE:`, '^R\\$ ', ''),
    valor_fipe = str_replace_all(valor_fipe, '\\(|\\)', '')
  ) |> 
  separate(
    valor_fipe, 
    into = c('valor_fipe', 'valor_data'), sep = ' ', remove = TRUE
  ) |>
  mutate(valor_fipe = as.numeric(valor_fipe, na.rm = TRUE)) |>
  mutate(
    `garantia_em_anos` = str_extract(`Garantia:`, '\\d+'),
    `garantia_em_anos` = as.integer(`garantia_em_anos`)
  ) |>
  mutate(
    cilindrada_em_cm3 = str_extract(`Cilindrada:`, '\\d+')
  ) |>
  separate(
    `Cilindros:`, into=c('cilindros', 'tipo_cilindro'),
    sep = ' em ', remove = TRUE
  ) |>
  mutate(
    curso_do_pistao_mm = str_remove(`Curso do Pistão:`, ' mm'),
    diametro_do_cilindro_mm =  str_remove(`Diâmetro do Cilindro:`, ' mm'),
    peso_potencia_kg_cv = str_remove(`Peso-Potência:`, ' kg/cv'),
    peso_torque_kg_kgfm = str_remove(`Peso-Torque:`, ' kg/kgfm'),
    potencia_especifica_cv_litro = str_remove(`Potência Específica:`, ' cv/litro'),
    torque_especifico = str_remove(`Torque Específico:`, ' kgfm/litro'),
    aceleracao_0_a_100_km_h_em_s = str_remove(`Aceleração 0-100 km/h:`, ' s'),
    velocidade_maxima = str_remove(`Velocidade Máxima:`, ' km/h'),
    velocidade_maxima_eletrico = str_remove(`Velocidade Máxima (Modo Elétrico):`, ' km/h'),
    consumo_urbano_gasolina = str_remove(`Consumo Urbano (Gasolina):`, ' km/l'),
    consumo_rodoviario_gasolina = str_remove(`Consumo Rodoviário (Gasolina):`, ' km/l'),
    autonomia_rodovidaria_gasolina = str_remove(`Autonomia Rodoviária (Gasolina):`, ' km/l'),
    consumo_urbano_alcool = str_remove(`Consumo Urbano (Álcool):`, ' km/l'),
    consumo_rodoviario_alcool = str_remove(`Consumo Rodoviário (Álcool):`, ' km/l'),
    autonomia_rodoviaria_alcool = str_remove(`Autonomia Rodoviária (Álcool):`, ' km/l'),
    consumo_urbano_diesel = str_remove(`Consumo Urbano (Diesel):`, ' km/l'),
    consumo_rodoviario_diesel = str_remove(`Consumo Rodoviário (Diesel):`, ' km/l'),
    autonomia_rodoviaria_diesel = str_remove(`Autonomia Rodoviária (Diesel):`, ' km/l'),
    altura_do_flanco_mm = str_remove(`Altura do Flanco:`, ' mm'),
    altura = str_remove(`Altura:`, ' mm'),
    bitola_dianteira = str_remove(`Bitola Dianteira:`, ' mm'),
    bitola_traseira = str_remove(`Bitola Traseira:`, ' mm'),
    comprimento = str_remove(`Comprimento:`, ' mm'),
    largura = str_remove(`Largura:`, ' mm'),
    entre_eixos = str_remove(`Distância entre Eixos:`, ' mm'),
    vao_livre_do_solo = str_remove(`Vão Livre do Solo:`, ' mm'),
    Travessia_de_agua = str_remove(`Travessia de Água:`, ' mm'),
    peso = str_remove(`Peso:`, ' kg'),
    porta_malas_litragem = str_remove(`Porta-Malas:`, ' litros'),
    tanque_combustivel = str_remove(`Tanque de Combustível:`, ' litros'),
    rotacao_de_potencia_maxima = str_remove(`Rotação de Potência Máxima:`, ' rpm'),
    rotacao_de_torque_maximo = str_remove(`Rotação de Torque Máximo:`, ' rpm'),
    rotacao_maxima = str_remove(`Rotação Máxima:`, ' rmp'),
    angulo_central = str_remove(`Ângulo Central:`, ' graus'),
    angulo_de_saida = str_remove(`Ângulo de Saída:`, ' graus'),
    angulo_de_entrada = str_remove(`Ângulo de Entrada:`, ' graus'),
    reboque_com_freio_kg = str_remove(`Reboque com Freio:`, ' kg'),
    reboque_sem_freio_kg = str_remove(`Reboque sem Freio:`, ' kg'),
    cilindrada_unitaria_cm3 = str_remove(`Cilindrada unitária:`, ' cm³'),
    cilindrada = str_remove(`Cilindrada:`, ' cm³'),
    algura_minima_do_solo = str_remove(`Altura mínima do solo:`, ' mm'),
    autonomia = str_remove(`Autonomia:`, ' km'),
    portamalas_5_lugares = str_remove(`Porta-Malas (5 Lugares):`, ' litros'),
    portamalas_6_lugares = str_remove(`Porta-Malas (6 Lugares):`, ' litros'),
    portamalas_7_lugares = str_remove(`Porta-Malas (7 Lugares):`, ' litros')
    
  ) ->tb_teste

#  select(`Curso do Pistão:`)
#  select(-`Garantia:`, -`Valor FIPE:`)
#  group_by()

#str_extract_all(c('8,2 kg/cv','65,1 kg/kgfm',   '9,6 kgfm/litro',   '61,2 kgfm '), '[a-z]+/+[a-z]+|[a-z]+')

tb_car |>
  select(where(~ any(str_detect(.x, " kg"), na.rm = TRUE)), id) |>
  select(-`Torque Máximo:`) -> tb_kg

tb_kg2 <- map(1:9,
    function(x){
      colnam <- colnames(tb_kg[,x])

      nam <- tb_kg |> select(x) |> str_extract('[a-z]+/+[a-z]+|[a-z]+') |> unique()
      nome <- glue('{colnames(tb_kg[,x])}_{nam}')

      tb_kg |>
       #select(x) |>
       mutate(
        !!nome := str_remove(colnam, ' [a-z]+/+[a-z]+|[a-z]+') #(colnam, '-?\\d+,\\d+')
       ) |>
       select()
    }
  ) |> 
  list_cbind()

#str_extract_all(unique(tb_kg[,1]), ' [a-z]+/+[a-z]+|[a-z]+')

map(1:9, 
  function(x){
    
    original_cl <- colnames(tb_kg)[1]
    value_cl <- tb_kg |> select(x) |> str_extract_all(' [a-z]+/+[a-z]+| [a-z]+') |> first() |> unique() |> str_trim() |> as.character()

    cl <- colnames(clean_names(tb_kg[, x]))
    coluna <- as.character(glue('{original_cl}_{value_cl}'))

    tb_kg %>%
     select(x) %>%
     mutate(
      !! coluna := str_extract(., '-?\\d+,\\d+')
     ) %>%
     select(-1)
  }
) |>
list_cbind()

#-----------
# tentativa 3
tb_kg |>
  mutate(
    `Torque Combinado:` = str_replace(`Torque Combinado:`, 'select \\* from carros_ficha_tecnica where id_carro in \\(select id_carro from carros where combustivel=', '')
  ) -> tb_kg

xpto <- colnames(tb_kg)

 map(xpto,
  function(x){
 
    nam <- tb_kg |> select(x) |> str_extract_all(' [a-z]+/+[a-z]+| [a-z]+') |> first() |> unique() |> str_trim()
    nome <- glue('{x}_{nam}')
   
    tb_kg %>%
     mutate(
      !! x := str_remove(x, ' [a-z]+/+[a-z]+| [a-z]+')
     )      
   
  }
) |> 
list_cbind() -> teste

#select * from carros_ficha_tecnica where id_carro in (select id_carro from carros where combustivel=

#-----------
# organizar dados de potencia maxima em alcool e em gasolina

#tb_car |> select(`Potência Máxima:`) |> filter(str_detect(`Potência Máxima:`, '(A)|(G)|(A).*(G)'))


#------------------------------------------------------------------
# criando a array de critérios
#tb_car <- read_csv('./scrap/tabela_carros2.csv')

cols <- colnames(tb_car)
write.csv(cols,'./scrap/criterios.csv')


