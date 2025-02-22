import polars as pl
import pandas as pd


# criar função matematica para analise

# PASSO 1
# conjunto de crittérios (colunas da base)
# verificar valores monotonicos (custo por exemplo) -> n * (-1)

tab = pl.read_csv("./scrap/tabela_carros2.csv")


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

#------------------------------------------------------------------------
# filtrar os criterios e adicionar os graus de importancia
tb_criterios = pl.read_csv('tab_criterios2.csv')
tb_conforto = pl.read_csv('tb_conforto_numeric.csv')
tb_seguranca = pl.read_csv('tb_seguranca_numeric.csv')
tb_infotein = pl.read_csv('tb_infoteinimento_numeric.csv')
tb_quali = pl.read_csv('tabela_carros_quali_2.csv')


lista_criterios = tb_criterios.filter(
    pl.col('criterios').is_in([
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
    ]))


lista_criterios.lazy().sink_csv('conjunto_criterios.csv')
