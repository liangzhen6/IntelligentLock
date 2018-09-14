#!/usr/bin/env python3
import socket
import threading
import time
import json
from aes import crypto

class LockConnect(object):
	"""docstring for LockConnect"""
	_instance_lock = threading.Lock()
	def __init__(self):
		#定义绑定的ip 和 端口
		self.ip_point = ('192.168.1.104', 8000)
		self.sock = None
		self.lockState = 'off'
		# self.lock = threading.Lock()
		# self.time = None 暂时取消不要了

	def __new__(cls, *args, **kwargs):
		if not hasattr(LockConnect, '_instance'):
			with LockConnect._instance_lock:
				if not hasattr(LockConnect, "_instance"):
					LockConnect._instance = object.__new__(cls)
		return LockConnect._instance


	def setLockState(self, state):
		#加锁
		# self.lock.acquire()
		# try:
		# 	self.lockState = state
		# finally:
		# 	#释放锁
		# 	self.lock.release()
		self.lockState = state


	def getLockState(self):
		# 返回锁的状态
		return self.lockState

	def setCammand(self, cammand):
		#获取到的指令
		print('收到服务器发来的指令：'+cammand)
		self.sendMessage('cammand', cammand)




	def socketClose(self):
		#关闭连接
		if self.sock != None:
			self.sock.close()
			# self.setLockState('off')
			# print(self.getLockState())
			# self.sock = None
			print('关闭连接')


	def sendMessage(self, typeStr, mes):
		#发送信息
		send_mes = {'Mtype':typeStr, 'Mes':mes}
		send_json = json.dumps(send_mes, sort_keys=True, indent=4)
		code_json = crypto.encrypt(send_json)
		if self.sock != None:
			self.sock.send(code_json)

	def createSocket(self):
		#初始化 监听等
		sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		sk.bind(self.ip_point)
		sk.listen()

		while True:
			print('锁-等待接收数据')
			self.sock, addr = sk.accept()
			message = '链接成功' + str(addr)
			self.sendMessage('commamd', message)
			print(message)

			while True:
				try:
					data = self.sock.recv(1024)
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
						# self.setLockState('on')
						# print(self.getLockState())
						self.sendMessage('heart', heart_str)

					else:
						if data_mes == 'exit':
							break
						else:
							# 普通消息
							mes = '服务端返回数据：' + data_mes
							self.sendMessage('commamd', mes)

				except Exception as e:
					# 接收异常的情况下，断开连接。
					print('抛出异常：',e)
					break
			self.socketClose()

	# def createThread(self):
	# 	thread = threading.Thread(target = self.createSocket())
	# 	print(thread)
	# 	thread.start()

# lockSocketConnect = LockConnect()

# socketManger = SocketManger()

# lockSocketConnect.createThread(socketManger)










