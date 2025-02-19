import polars as pl
import pandas as pd


# criar função matematica para analise

# PASSO 1
# conjunto de crittérios (colunas da base)
# verificar valores monotonicos (custo por exemplo) -> n * (-1)

tab = pl.read_csv("./scrap/tabela_carros2.csv")

tab.select("Garantia:").group_by("Garantia:").count()

tab.with_columns(
    pl.col("Garantia:").str.extract_all(r"^\d+").list.join("")
).with_columns(
    garantia_em_anos=pl.col("Garantia:").str.to_integer(base=16, strict=False)
)

"""
###
# Ordenação de critérios por importância
# pode haver empate

# PASSO 3
# atribuição do grau de importância dos critérios => (sj)
# (sj)max = {n, se n > 7} 
# (sj)max = {7, se n <= 7}
# wj = sj / sum(n, j = 1 Sj) -> divide pelo total

# PASSO 4
# as alternativas são definidas pelo conjunto A = {a1, a2, ..., am} para cada tomada de decisão
# cada critério as alternativas apresentam um atributo dj.
# os atributos formam a Matriz de Decisão M
# os criterios quantitativos devem ter seus valores atrelados a uma unidade de medida
# observar critérios monotônicos de custo.
# critérios qualitativos deve-se usar escala de sete pontos
# calcular para cada critério a média eo desvio padrão dos atributos dj, (normalizados para encaixar na forma gaussiana)

# PASSO 5
"""
