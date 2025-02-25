library(tidyverse)
library(glue)
library(stringr)


identifica_colunas(tb_car, 'Não informado') -> t

tb_car |>
      select(-`Torque Máximo:`) |>
      select(where(~ any(str_detect(.x, '(?<=\\s)s$'), na.rm = TRUE))) |>
      mutate(across(where(is.character), ~ str_replace_all(.x, ",", "."))) |>
      mutate(across(everything(), ~ na_if(.x, 'Não informado')))-> tb_teste
  
   nn <- ncol(tb_teste)
  
   tb_teste_corrigido <- map(1:nn, 
    function(x){
      
      original_cl <- colnames(tb_teste)[x]
      
      value_cl <- tb_teste |> 
        select(x) |> 
        pull() |>
        str_extract_all('(?<=\\s)s$') |> 
        detect(~!is.na(.x))
        #first() |> 
        #unique() |> 
        #str_trim() |> 
        #as.character()
  
      cl <- colnames(clean_names(tb_teste[, x]))
      coluna <- as.character(glue('{cl}_{value_cl}'))
  
      tb_teste %>%
       select(original_cl) %>%
       separate(
        col = !!sym(original_cl), into = c(coluna, "a"), sep = " ", remove = TRUE, convert = TRUE
       ) %>%
       select(-a)
    }
  ) |>
  list_cbind() #|>
  
#cbind(data[,1])

# v <- c(76,80,76,80,68,76)
# m <- mean(v)
# s <- sd(v)
# z <- (v - m)/s




# teste de pontuação de itens de confoto
tab_conforto |>
  separate_rows(conforto, sep = ', ') |>
  select(conforto) |>
  unique() |>
  pull()

filtro_conf <- c('Ar-condicionado automático','Ajuste elétrico dos retrovisores', 'Câmbio automático','Retrovisores rebativeis eletricamente',
'Controle de velocidade adaptativo',"Bancos revestidos em couro")

tab_seguranca |>
  separate_rows(seguranca, sep = "' ,") |>
  select(seguranca) |>
  unique() |>
  pull()

filtro_seg <- c( "Airbags de cortina", "Airbags frontais", "Airbags laterais", "Câmera traseira para manobras",
"Assistente de partida em rampa", "Controle de estabilidade", "Freios ABS" ,"Alerta de ponto cego", "Freios ABS"
)

tb_info |>
  separate_rows(infoteinimento, sep = " ,") |>
  select(infoteinimento) |>
  unique() |>
  pull()

filtro_info <- c("Computador de bordo" ,"Conexão USB","Espelhamento da tela do celular" )

# filtrar na tabela tab_conforto e contar

head(tab_conforto)

tab_conforto %>%
  separate_rows(conforto, sep = ',\\s') |>
  group_by(ID) |>
  nest(conforto = conforto) |>
  slice(1:100) |>
  mutate(conforto = map(conforto, ~pull(.x, 1))) |>
  mutate( 
    exists = map(conforto, ~ .x %in% filtro_conf),
    value = map_int(exists, ~sum(.x))
  ) -> t

map(tab_conforto$conforto[1:10], ~ .x %in% filtro_conf)

# testando criar a funcao

funcao_atribuir_valor <- function(data, coluna, filtro, separador){

  data |>
    separate_rows(coluna, sep = separador) |>
    group_by(ID) |>
    nest(coluna = coluna) |>
    slice(1:100) |>
    mutate(coluna = map(coluna, ~pull(.x, 1))) |>
    mutate( 
      exists = map(coluna, ~ .x %in% filtro),
      value = map_int(exists, ~sum(.x))
    ) -> t
    
    return(t)

}

funcao_atribuir_valor(tb_info, 'infoteinimento', filtro_info, ' ,') 
funcao_atribuir_valor(tab_conforto, 'conforto', filtro_conf, ', ') 
funcao_atribuir_valor(tab_seguranca, 'seguranca', filtro_seg, "' ,") 
