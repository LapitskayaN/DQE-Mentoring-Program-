from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as expect
import time

browser_link = "https://dqelearn.trainings.dlabanalytics.com/nllapitskaya/notebooks/Final_task.ipynb"
user_email = "nataliya_lapitskaya@epam.com"

print('Initialize Chrome WebDriver')
driver = webdriver.Chrome()
driver.get(browser_link)
time.sleep(5)

print('click button_advanced')
button_advanced = WebDriverWait(driver, 5).until(expect.presence_of_element_located((By.ID, "details-button")))
button_advanced.click()
time.sleep(5)

print('wait for click link_proceed_dqe_lern')
link_proceed_dqe_lern = WebDriverWait(driver, 5).until(expect.presence_of_element_located((By.ID, "proceed-link")))
link_proceed_dqe_lern.click()
time.sleep(5)

print('wait for click link_epam_SSO ')
link_epam_SSO = WebDriverWait(driver, 5).until(expect.presence_of_element_located((By.ID, "social-epam-idp")))
link_epam_SSO.click()
time.sleep(5)

print('wait for input user email')
user_email_input = WebDriverWait(driver, 5).until(expect.presence_of_element_located((By.ID, "i0116")))
user_email_input.send_keys(user_email)
time.sleep(5)

print('enter password!!! user should enter password!')
time.sleep(5)

print('wait for click button_sign_in')
button_sign_in = WebDriverWait(driver, 30).until(expect.presence_of_element_located((By.ID, "idSIButton9")))
button_sign_in.click()
time.sleep(10)

print('wait browser link')
WebDriverWait(driver, 250).until(expect.url_to_be(browser_link))
print('User successfully logged')

print('Open Jupyter Notebook')
time.sleep(5)
print('Open DDL')
ddl_open = WebDriverWait(driver, 500).until(expect.presence_of_element_located((By.ID, "celllink")))
ddl_open .click()

run_notebook = WebDriverWait(driver, 20).until(expect.presence_of_element_located((By.ID, "run_all_cells")))
ActionChains(driver).move_to_element(run_notebook ).click().perform()
print('Jupyter Notebook run')
time.sleep(10)

driver.quit()
print("Close driver")



