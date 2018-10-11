#!/usr/bin/env python3
from Crypto.Cipher import AES
import base64
import json

class Prpcrypt(object):
	"""docstring for ClassName"""
	def __init__(self):
		self.key = 'ADER19T22H2K56U5'
		self.mode = AES.MODE_CBC
		
	# 加密
	def encrypt(self, text):
		cryptor = AES.new(self.key, self.mode, self.key)
		length = 16
		count = len(text)
		add = length - (count % length)
		text = text + ('\0' * add)
		ciphertext = cryptor.encrypt(text)
		base64text = base64.b64encode(ciphertext)
		return base64text

	# 解密
	def decrypt(self, text):
		cryptor = AES.new(self.key, self.mode, self.key)
		plain_text = str(cryptor.decrypt(base64.b64decode(text)), 'utf8')
		new_text = ''
		for x in plain_text:
			if x == '\x00':
				#去除后面的一堆 \x00
				break
			else:
				new_text = new_text + x
		return new_text

crypto = Prpcrypt()
# send_mes = {'Mtype':'command', 'Mes':'w'}
# send_json = json.dumps(send_mes, sort_keys=True, indent=4)

# text = crypto.encrypt(send_json)
# # print(text,send_json,type(send_json))

# test = crypto.decrypt('fw3zv1vy5449PcTK3YY4G0BzsZ+zQ5z0mXU72EljVOaJ5c9WsI/HHA2Jcjv+ktGW')
# print(test)







