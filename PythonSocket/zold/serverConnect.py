#!/usr/bin/env python3
import socket
import threading
import time
import json
from aes import crypto

class ServerConnect(object):
	"""docstring for ServerConnect"""
	def __init__(self):
		#定义绑定的ip 和 端口
		self.ip_point = ('192.168.1.104', 8008)

	def socketClose(self, sock):
		#关闭连接
		if sock != None:
			sock.close()
			print('关闭连接')

	def sendMessage(self, sock, typeStr, mes):
		#发送信息
		send_mes = {'Mtype':typeStr, 'Mes':mes}
		send_json = json.dumps(send_mes, sort_keys=True, indent=4)
		code_json = crypto.encrypt(send_json)
		if sock != None:
			sock.send(code_json)

	def createSocket(self):
		#初始化 监听等
		sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		sk.bind(self.ip_point)
		sk.listen()

		while True:
			print('等待接收数据')
			sock, addr = sk.accept()
			message = '链接成功' + str(addr)
			self.sendMessage(sock, 'commamd', message)
			print(message)
			client_thread = threading.Thread(target = self.handle_socket(sock, addr))
			client_thread.start()

	def handle_socket(self, sock, addr):
		while True:
			try:
				data = sock.recv(1024)
		 		# 解码为 str类型
				str_base64 = data.decode('utf8')
				# aes 解密 得到 str 字符串
				data_str = crypto.decrypt(str_base64)
				# 将 json 解析为 dict
				data_dic = json.loads(data_str)
				mes_type = data_dic['Mtype']
				data_mes = data_dic['Mes']
				print('收到客户端发来的数据：'+data_mes)
				print(threading.currentThread())
				if 'heart' in mes_type:
					time_int = (int)(data_mes) + 1
					heart_str = '服务端返回心跳：%d' %(time_int)
					self.sendMessage(sock, 'heart', heart_str)

				else:
					if data_mes == 'exit':
						break
					else:
						# 普通消息
						mes = '服务端返回数据：' + data_mes
						self.sendMessage(sock, 'commamd', mes)

			except Exception as e:
				# 接收异常的情况下，断开连接。
				print('抛出异常：',e)
				break
		self.socketClose(sock)
		

lockSocketConnect = ServerConnect()
lockSocketConnect.createSocket()











