import unittest
import time

from appium import webdriver
from appium.options.common import AppiumOptions
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy

appName = "net.defined.mobile_nebula"
appActivity = "net.defined.mobile_nebula.MainActivity"

capabilities = dict(
    platformName='Android',
    automationName='uiautomator2',
    deviceName='de0597a8',
    paltformVersion='14',
    language='en',
    locale='US',
    appPackage=appName,
    appActivity=appActivity,
    #noReset=True, # Assumes app is already installed. Otherwise need to provide install option
    #appPackage='com.android.settings',
    #appActivity='.Settings',
)

SERVER_URL_BASE = 'http://localhost:4723'
capabilities_options = UiAutomator2Options().load_capabilities(capabilities)


class TestAppium(unittest.TestCase):
    def setUp(self) -> None:
        self.driver = webdriver.Remote(SERVER_URL_BASE, options=AppiumOptions().load_capabilities(capabilities))

    def tearDown(self) -> None:
        if self.driver:
            self.driver.quit()

    def test_nebula(self) -> None:
        if self.driver:
            #self.driver.startActivity(".net.defined.mobile_nebula", ".activity.MainTabActivity")
            if self.driver.is_app_installed(appName):
                print("app is installed")

                elements = self.driver.find_elements("xpath", "//*")

                # Print all element IDs
                for element in elements:
                    # there isnt a better way to find this sucker - I could
                    # rewrite the code to add attributes
                    if "000a00000003" in element.id:
                         element.click()
                         import pdb
                         pdb.set_trace()
            else:
                print("app is not installed")

if __name__ == '__main__':
    unittest.main()
