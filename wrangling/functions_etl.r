library(tidyverse)
library(glue)
library(stringr)

#--------------------------------------------------------------------------------------
# Funtion 1
# function to identify columns with specific caracteres in its cells

identifica_colunas <- function(data, symble_txt) {
  data |>
    select(where(~ any(str_detect(.x, symble_txt), na.rm = TRUE)) , "...1") |>
    mutate(across(where(is.character), ~ str_replace_all(.x, ",", "."))) -> tb

  return(tb)
}

#-------------------------------------------------------------------------------------
# function 2
# function to take away symbles like mm, cm, kg etc and mutate the column of a dataframe
# to numeric and add the symble to the column name
# '[a-z]+/+[a-z]+|[a-z]+'
# '-?\\d+,\\d+'

take_symble_to_column <- function(data, symble_txt) {
  data |>
    select(-`Torque Máximo:`) |>
    select(where(~ any(str_detect(.x, symble_txt), na.rm = TRUE))) |>
    mutate(across(where(is.character), ~ str_replace_all(.x, ",", "."))) |>
    mutate(across(everything(), ~ na_if(.x, "Não informado"))) -> tb_kg

  nn <- ncol(tb_kg)

  tb_kg_corrigido <- map(
    1:nn,
    function(x) {
      original_cl <- colnames(tb_kg)[x]

      value_cl <- tb_kg |>
        select(x) |>
        pull() |>
        str_extract_all(symble_txt) |>
        detect(~ !is.na(.x)) |>
        str_trim()

      cl <- colnames(clean_names(tb_kg[, x]))
      coluna <- as.character(glue("{cl}_{value_cl}"))

      tb_kg %>%
        select(original_cl) %>%
        separate(
          col = !!sym(original_cl), into = c(coluna, "a"), sep = " ", remove = TRUE, convert = TRUE
        ) %>%
        select(-a)
    }
  ) |>
    list_cbind() |>
    cbind(data[, 1])

  return(tb_kg_corrigido)
}

# test
# take_symble_to_column(tb_car, '(?<=\\s)s$') |> head() -> t
