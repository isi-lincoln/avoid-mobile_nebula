import unittest
import time
import pdb

from appium import webdriver
from appium.options.common import AppiumOptions
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy
from appium_flutter_finder.flutter_finder import FlutterElement, FlutterFinder

appName = "net.defined.mobile_nebula"
appActivity = "net.defined.mobile_nebula.MainActivity"

capabilities = dict(
    platformName='Android',
    #automationName='uiautomator2',
    automationName='flutter',
    #deviceName='de0597a8',
    deviceName='android',
    paltformVersion='14',
    language='en',
    locale='US',
    appPackage=appName,
    appActivity=appActivity,
    #noReset=True, # Assumes app is already installed. Otherwise need to provide install option
    #appPackage='com.android.settings',
    #appActivity='.Settings',
)

SERVER_URL_BASE = 'http://192.168.1.47:4723'
#SERVER_URL_BASE = 'http://localhost:4723'
capabilities_options = UiAutomator2Options().load_capabilities(capabilities)


class TestAppium(unittest.TestCase):
    def setUp(self) -> None:
        self.driver = webdriver.Remote(SERVER_URL_BASE, options=AppiumOptions().load_capabilities(capabilities))

    def tearDown(self) -> None:
        if self.driver:
            self.driver.quit()

    def test_nebula(self) -> None:
        print("here")
        if self.driver:
            if self.driver.is_app_installed(appName):
                print("app is installed")

                #self.driver.quit()
                finder = FlutterFinder()
                key_finder = finder.by_value_key("settings_page")
                print("k", key_finder)
                if key_finder != None:
                    ele = FlutterElement(self.driver, key_finder)
                    print(ele)
                    if ele != None:
                        ele.click()

                time.sleep(1)

                #pdb.set_trace()

                #elements = self.driver.find_elements("xpath", "//*")

                # Print all element IDs
                #for element in elements:
                #    print(element.id, element.tag_name)
                #    print(dir(element))
                #    print(element.__dict__)
                #    # there isnt a better way to find this sucker - I could
                #    # rewrite the code to add attributes
                #    if "000a00000003" in element.id:
                #         element.click()
            else:
                print("app is not installed")

if __name__ == '__main__':
    unittest.main()
