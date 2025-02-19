from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from datetime import datetime, timedelta
import pandas as pd
import time

#--------------------------------------------------------------------------------------------------------------
# parametros

date_reg = datetime.now()

chrome_pathexe =  r'/home/alencar/Documentos/DataScience/chromedriver'
#chrome_pathexe = r'C:/Users/alencar/Documents/DataScience/chrome_driver/chromedriver-win64/chromedriver.exe'
url = "https://guiacarros.com.br/catalogo/carros?anoInicial=1968&anoFinal=2025&valorInicial=R$%200&valorFinal=R$%201.000.000&procedencia=Todos&cambio=Todos"
elem_class = 'cinza-laranja'
pg = '&pg='
last_page = 472

#--------------------------------------------------------------------------------------------------------------
# options

service = Service()  
options = webdriver.ChromeOptions()

# This will automatically install Chromedriver  
#driver = webdriver.Chrome(service=service, options=options)

options = webdriver.ChromeOptions()
options.add_argument('--hedless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

#---------------------------------------------------------------------------------------------------------------

wd = webdriver.Chrome(service=service, options=options)
#wd.get(url)

url_list = []
for i in range(1, last_page):
    wd.get(url + pg + f'{i}')
    e = wd.find_elements(By.CSS_SELECTOR, 'a.cinza-laranja')
    time.sleep(1)
    ls = [el.get_attribute('href') for el in e if el.get_attribute('href')]
    url_list.append(ls)
    time.sleep(3)

#----------------------------------------------------------------------------------------------------------------
# saving to a file

# Write to a file
with open("lista_urls.txt", "w") as file:
    for item in url_list:
        file.write(f"{item}\n")  # Add a newline after each item

#wd.find_element(By.CLASS_NAME, elem_class)
#time.sleep(1)

#elems = wd.find_element(By.CLASS_NAME, elem_class)
#elems = wd.find_elements(By.CSS_SELECTOR, 'a.cinza-laranja')

#html = wd.page_source
#time.sleep(1)

#links = [elem.get_attribute('href') for elem in elems if elem.get_attribute('href')]

# //*[@id="link-ficha-tecnica-1369"]
#table = pd.read_html(html)
#print(html)

#--------------------------------------------------------------------------------------------------------------