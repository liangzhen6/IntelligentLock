#!/usr/bin/env python3
import socket
import threading
import time
import json
from aes import crypto
# from lockConnect import LockConnect

def socketClose(sock):
		#关闭连接
		if sock != None:
			sock.close()
			print('关闭连接')

def sendMessage(sock, typeStr, mes):
	#发送信息
	send_mes = {'Mtype':typeStr, 'Mes':mes}
	send_json = json.dumps(send_mes, sort_keys=True, indent=4)
	code_json = crypto.encrypt(send_json)
	if sock != None:
		sock.send(code_json)

def createSocket():
	#初始化 监听等
	sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	ip_point = ('192.168.1.104', 8008)
	sk.bind(ip_point)
	sk.listen()

	while True:
		print('服务器-等待接收数据')
		sock, addr = sk.accept()
		message = '链接成功' + str(addr)
		sendMessage(sock, 'commamd', message)
		print(message)
		client_thread = threading.Thread(target = handle_socket, args=(sock,addr))
		client_thread.start()

def handle_socket(sock, addr):
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
			# print(threading.currentThread())
			# print(threading.active_count())
			if 'heart' in mes_type:
				time_int = (int)(data_mes) + 1
				heart_str = '服务端返回心跳：%d' %(time_int)
				sendMessage(sock, 'heart', heart_str)
				# lockSocketConnect = LockConnect()
				# print(lockSocketConnect)
				# print('lock当前的链接状态：',lockSocketConnect.getLockState())

			else:
				if data_mes == 'exit':
					break
				else:
					# 普通消息
					mes = '服务端返回数据：' + data_mes
					sendMessage(sock, 'commamd', mes)
					# lockSocketConnect = LockConnect()
					# print(lockSocketConnect)
					# lockSocketConnect.setCammand(data_mes)


		except Exception as e:
			# 接收异常的情况下，断开连接。
			print('抛出异常：',e)
			break
	socketClose(sock)


# def createLockContent():
# 	lockSocketConnect = LockConnect()
# 	lockSocketConnect.createSocket()
# 	# thread = threading.Thread(target = lockSocketConnect.createSocket())
# 	# thread.start()

# threadlock = threading.Thread(target = createLockContent)
# threadlock.start()
# threadlock.join()

threadServer = threading.Thread(target = createSocket)
threadServer.start()
# threadServer.join()

# createLockContent()
# createSocket()






