
# Imports 
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from helium import *

import csv
import time

#driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
chrome_options = Options()
#chrome_options.add_argument("--incognito")
chrome_options.add_argument("--window-size=1920x1080")
driver = webdriver.Chrome(chrome_options = chrome_options)
size = driver.get_window_size()
print(size)


url = "placeholder.com"
time.sleep(2)

driver.get(url)
#WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CLASS_NAME, "gwt-TextBox.loginusername")))
time.sleep(5)
UNentry = driver.find_element(By.CLASS_NAME, "gwt-TextBox.loginusername")
UNentry.send_keys(input("Username:"))
driver.find_element(By.ID, "next").click()
time.sleep(3)
password = driver.find_element(By.CLASS_NAME, "gwt-PasswordTextBox.loginpassword")
password.send_keys(input("Password:"))
password.send_keys(Keys.RETURN)

WebDriverWait(driver, 120).until(EC.element_to_be_clickable((By.ID, "dashboard-builder")))
driver.find_element(By.ID, "dashboard-builder").click()
#Put "Show list here

# Put loop here
# Return name.
WebDriverWait(driver, 120).until(EC.element_to_be_clickable((By.ID, "edit")))
driver.find_element(By.ID, "edit").click()
time.sleep(10)
set_driver(driver)
click(Point(555,25))
WebDriverWait(driver, 120).until(EC.element_to_be_clickable((By.XPATH, "/html/body/div/div[2]/div[2]/a[2]")))
driver.find_element( By.XPATH, "/html/body/div/div[2]/div[2]/a[2]").is_enabled()

#testarray = driver.find_elements(By.XPATH, "/html/body/div/div[2]/div[2]/a[2]")
#print(testarray)


time.sleep(10)
#click into "Data Sources"
# Loop through form names and return them here.
#driver.close



