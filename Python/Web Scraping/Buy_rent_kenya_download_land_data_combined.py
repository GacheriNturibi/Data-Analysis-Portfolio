##Use Ruto xpath finder to locate elements in a webpage
##Web scraping land prices in Nairobi

import time
import selenium.webdriver as webdriver
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException
import pandas as pd

from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys




driver=webdriver.Chrome('C:/Users/Kochulem/Documents/Excels/chromedriver.exe')


driver.get('https://www.buyrentkenya.com/land-for-sale')

base_url= driver.current_url
str(base_url)

pages=list(range(30))

main_page_links=[]
content=[]

links = {"URLs":[]}
for page in pages:

    current_page='https://www.buyrentkenya.com/land-for-sale/nairobi'+'?page='+str(page)
    main_page_links.append(current_page)
    driver.get(url=current_page)
    ##time.sleep(1)
    driver.implicitly_wait(3)

    incategory = driver.find_elements_by_xpath("//*[@class='w-full flex-1']/a[1]")
    ##incategory = driver.find_elements_by_xpath("//*[@class='text-primary font-semibold mr-5 text-lg']/a[1]")
    content.append(incategory)
    for i in range(len(incategory)):
        item = incategory[i]
        ##	get the href property to retrieve the URL link attached for each property
        a=item.get_property("href")
        ##	Append the link to the list of links
        links["URLs"].append(a)



print(links)

Buy_rent_kenya_property_url = pd.DataFrame.from_dict(links)


urls=Buy_rent_kenya_property_url.loc[0:200,'URLs'].values.tolist()

Land_details = {"Land_Cost":[],"Land_area":[],"Cost_per_m2":[],"Land_location":[],"land_description":[]}
nl='Null'


##Lets loop through each link to acces the page of property
for link in urls:
##    get url of each property
    driver.get(url=link)
    driver.implicitly_wait(3)

    try:
        ##Land_Cost=driver.find_element_by_xpath("//span[contains(@class,'text-xl font-bold')]")
        Land_Cost=driver.find_element_by_xpath("//span[contains(@class,'text-xl leading-7')]")
        TC =Land_Cost.text
        Land_details["Land_Cost"].append(TC)
    except NoSuchElementException:
        Land_details["Land_Cost"].append(nl)
    except TimeoutException:
        continue

    except Exception:
        continue
    try:
        ##Land_Loca=driver.find_element_by_xpath("(//div[@class='mb-4']//p)[3]")
        Land_Loca=driver.find_element_by_xpath("//p[contains(@class,'hidden items-center')]")
        LL =Land_Loca.text
        Land_details["Land_location"].append(LL)
    except NoSuchElementException:
        Land_details["Land_location"].append(nl)
    except TimeoutException:
        continue
    except Exception:
        continue
    try:
        ##Land_area=driver.find_element_by_xpath("//div[contains(@class,'hide-title block')]//h1[1]")
        Land_area=driver.find_element_by_xpath("(//span[contains(@class,'flex items-center')])[2]")
        LA=Land_area.text
        Land_details["Land_area"].append(LA)
    except NoSuchElementException:
        Land_details["Land_area"].append(nl)
    except TimeoutException:
        continue

    except Exception:
        continue

    try:
        #land_description=driver.find_element_by_xpath("//div[contains(@class,'mb-2 leading-normal')]")
        land_description=driver.find_element_by_xpath("//div[contains(@class,'text-grey-550 mb-0')]")
        LD=land_description.text
        Land_details["land_description"].append(LD)
    except NoSuchElementException:
        Land_details["land_description"].append(nl)
    except TimeoutException:
        continue

    except Exception:
        continue
    try:
        ##Cost_per_m2=driver.find_element_by_xpath("(//div[@class='flex items-center']//span)[2]")
        Cost_per_m2=driver.find_element_by_xpath("//span[contains(@class,'whitespace-nowrap inline')]")
        LCA=Cost_per_m2.text
        Land_details["Cost_per_m2"].append(LCA)
    except NoSuchElementException:
        Land_details["Cost_per_m2"].append(nl)
    except TimeoutException:
        continue

    except Exception:
        continue

Land_sale = pd.DataFrame.from_dict(Land_details)

Land_sale.to_csv("C:/Users/Kochulem/Documents/Excels/Buy_rent_kenya_land_property.csv")


# Quit the browser
driver.quit()
