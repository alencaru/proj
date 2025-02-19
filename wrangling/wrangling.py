import pandas as pd

tab_detalhes = pd.read_csv('./scrap/tabela_detalhes.csv')

tab_detalhes1 = tab_detalhes.explode('conforto').explode('infoteinimento').explode('seguranca')


tab_detalhes1 = (
    tab_detalhes.explode('conforto')
    .explode('infoteinimento')
    .explode('seguranca')
)
