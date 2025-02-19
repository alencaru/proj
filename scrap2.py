from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from datetime import datetime, timedelta
from pydantic import BaseModel, create_model
import pandas as pd
import time

#--------------------------------------------------------------------------------------------
# lista de urls

# Open the file and read lines into a list
with open("lista_urls.txt", "r") as file:
    lines = file.readlines()

#--------------------------------------------------------------------------------------------
# webdriver options

service = Service()  
options = webdriver.ChromeOptions()

options = webdriver.ChromeOptions()
options.add_argument('--hedless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

#--------------------------------------------------------------------------------------------
# getting car data from the web

wd = webdriver.Chrome(service=service, options=options)

# number of cars available
last_n = 8458

table = pd.DataFrame()
table_eq = pd.DataFrame(columns=["url", "id", "conforto", "infoteinimento","seguranca"])

for i in range(0, 1000):
    wd.get(lines[i].strip())
    label = wd.find_elements(By.CSS_SELECTOR, 'span.label_spec')
    value = wd.find_elements(By.CSS_SELECTOR, 'span.value_spec')

    time.sleep(1)

    l = [la.text for la in label if la.text]
    v = [va.text for va in value if va.text]

    fields = {key: (type(value), value) for key, value in zip(l, v)}

   # local anterior da tabela principal
    table = pd.concat([table, pd.DataFrame([v], columns=l)], ignore_index=True)
    table["url"] = lines[i].strip()
    table["id"] = i

    time.sleep(1)
    conf = wd.find_elements(By.CSS_SELECTOR, 'div.eq_column.eq_conforto ul.eq_list li')
    info = wd.find_elements(By.CSS_SELECTOR, 'div.eq_column.eq_infotenimento ul.eq_list li')
    segu = wd.find_elements(By.CSS_SELECTOR, 'div.eq_column.eq_seguranca ul.eq_list li')

    cf = [i.text for i in conf if i.text]
    ie = [i.text for i in info if i.text]
    sg = [i.text for i in segu if i.text]

    row = {"url": lines[i].strip(), "id": i, "conforto": cf, "infoteinimento": ie, "seguranca": sg}
    table_eq = pd.concat([table_eq, pd.DataFrame([row], columns=["url","id","conforto","infoteinimento","seguranca"])], ignore_index=True)

    time.sleep(3)

print(table)

table.to_csv('tabela_carros2.csv')
table_eq.to_csv('tabela_detalhes.csv')

#--------------------------------------------------------------------------------------------

