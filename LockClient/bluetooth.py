#!/usr/bin/env python3
# https://blog.csdn.net/qq_33433070/article/details/78671210 参考   91:FF:DD:CC:BB:AA
#
# from bluepy import btle
# from bluepy.btle import Scanner, DefaultDelegate

# class ScanDelegate(DefaultDelegate):
# 	"""docstring for ClassName"""
# 	def __init__(self):
# 		DefaultDelegate.__init__(self)
	
# 	def handleDiscovery(self, dev, isNewDev, isNewData):
# 		if isNewDev:
# 			print("Discovered device", dev.addr)
# 		elif isNewData:
# 			print("Received new data from", dev.addr)


# scanner = Scanner().withDelegate(ScanDelegate())
# devices = scanner.scan(10.0)

# for dev in devices:
# 	print("Device %s (%s), RSSI=%d dB" % (dev.addr, dev.addrType, dev.rssi))
# 	for (adtype, desc, value) in dev.getScanData():
		# print("%s = %s" % (desc, value))
from bluepy import btle
from bluepy.btle import DefaultDelegate
import time
import binascii
class ScanDelegate(DefaultDelegate):
	"""docstring for ClassName"""
	def __init__(self):
		DefaultDelegate.__init__(self)
	
	def handleDiscovery(self, dev, isNewDev, isNewData):
		if isNewDev:
			print("Discovered device", dev.addr)
		elif isNewData:
			print("Received new data from", dev.addr)
# global dev
# dev = None
# while dev == None:
# 	dev=btle.Peripheral('91:FF:DD:CC:BB:AA').withDelegate(ScanDelegate())
# 	time.sleep(3.0)

# for ser in dev.getServices():
#     print(str(ser))
#     for chara in ser.getCharacteristics():
#         print(str(chara))
#         print("Handle is "+str(chara.getHandle()))
#         print("properties is "+chara.propertiesToString())
#         if(chara.supportsRead()):
#             print(type(chara.read()))
#             print(chara.read())
#     print("\n")
class BleCtrl(object):
	"""docstring for BleCtrl"""
	def __init__(self):
		self.hexOn = bytes.fromhex('ff')
		self.hexOff = bytes.fromhex('00')
		self.dev = None
		self.dev_mac = '91:FF:DD:CC:BB:AA'

	def scan_dev(self):
		while self.dev == None:
			self.dev = btle.Peripheral(self.dev_mac).withDelegate(ScanDelegate())
			time.sleep(3.0)

	def dev_open(self, isOn):
		if self.dev == None:
			self.scan_dev()
		else:# 链接成功
			if isOn:
				self.dev.writeCharacteristic(9,self.hexOn,withResponse=False)
			else:
				self.dev.writeCharacteristic(9,self.hexOff,withResponse=False)

	def send_open(self):
		self.dev_open(True)
		time.sleep(2.0)
		self.dev_open(False)

		
ble = BleCtrl()
ble.scan_dev()
# ble.send_open()

# hello = dev.writeCharacteristic(9,hexOn,withResponse=False)
# print(hexOn,hello)

  