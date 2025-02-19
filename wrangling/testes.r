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