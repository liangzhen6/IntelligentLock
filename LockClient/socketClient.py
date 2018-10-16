#!/usr/bin/env python3
import time
import socket
import threading
import json

from aes import crypto
from bluetooth import ble

isconnect = False
client = None
lockState = 'off'
sock_list = []

# 关闭 socket 链接
def socketClose():
	if client != None:
		client.close()
		isconnect = False
		print('关闭链接！')

def socketClientClose(sock):
		#关闭连接
		if sock != None:
			sock.close()
			# 移除这个链接 从链接列表内
			if sock in sock_list:
				sock_list.remove(sock)
			print('关闭连接')

def sendMessage(typeStr, mes):
	send_mes = {'Mtype':typeStr, 'Mes':mes, 'lockState':lockState}
	# send_json = json.dumps(send_mes, sort_keys=True, indent=4)
	send_json = json.dumps(send_mes)
	code_json = crypto.encrypt(send_json)
	if client != None:
		client.send(code_json)

def sendClientsMessage(sock, typeStr, mes = None, lockLink = None, lockState = None):
	#发送信息
	send_mes = {'Mtype':typeStr, 'Mes':mes}
	if mes != None:
		send_mes['Mes'] = mes
	if lockLink != None:
		send_mes['lockLink'] = lockLink
	if lockState != None:
		send_mes['lockState'] = lockState

	send_json = json.dumps(send_mes)
	# send_json = json.dumps(send_mes, sort_keys=True, indent=4)
	code_json = crypto.encrypt(send_json)
	if sock != None:
		sock.send(code_json)

def clientConnect():
	global isconnect, client, lockState
	#创建sockte 实例
	client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

	#定义绑定的ip 和 端口
	ip_point = ('144.34.162.116', 8000)
	try:
		#绑定监听
		client.connect(ip_point)
		isconnect = True

		while True:
			# 接受数据
			try:
				data = client.recv(1024)
				# 解码为 str类型
				str_base64 = data.decode('utf8')
				# aes 解密 得到 str 字符串
				data_str = crypto.decrypt(str_base64)
				# 将 json 解析为 dict
				data_dic = json.loads(data_str)
				mes_type = data_dic['Mtype']
				data_mes = data_dic['Mes']
				print('收到服务器发来的数据：'+data_mes)
				
				if 'command' in mes_type:
					# 是 服务器发来的命令(开门)
					if data_mes in 'ff':
						# 是 开的命令
						lockState = 'on'
						sendMessage('command', 'open')
						ble.send_open()
						lockState = 'off'
						sendMessage('command', 'close')
				else:
					# 是服务器发来的心跳数据
					print(data_mes)
			except Exception as e:
				# 异常
				print('error',e)
				break
				
		socketClose()
	except Exception as e:
		print('链接异常稍后重试！！')
	

def fun_timer():
	time_int = (int)(time.time())
	heart_str = '%d' %(time_int)
	# client.send(heart_str.encode('utf8'))
	if isconnect:
		# 连接状态 发送 心跳包
		sendMessage('heart', heart_str)
	else:
		# 非链接状态，重现链接
		clientThread = threading.Thread(target = clientConnect)
		clientThread.start()
		# clientConnect()
	# 每15S 发送一下心跳，或者重新连接
	timer = threading.Timer(15.0, fun_timer)
	timer.start()


def createSocket(point):
	#初始化 监听等
	sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	ip = '192.168.1.120'
	sk.bind((ip, point))
	sk.listen()

	while True:
		print('服务器-等待接收数据')
		sock, addr = sk.accept()
		message = '链接成功' + str(addr)
		sendClientsMessage(sock, 'command', message)
		print(message)
		# if point == 8000:
		# 	global lockSock, sock_list
		# 	# 是lock 的链接
		# 	lockSock = sock
		# 	lockLink = 'on'
		# 	handle_socket(sock, addr, point)
		# else:
		global sock_list
		sock_list.append(sock)
		client_thread = threading.Thread(target = handle_socket, args=(sock, addr, point))
		client_thread.start()

def handle_socket(sock, addr, point):
	global lockState
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
			print('收到客户端发来的数据：'+data_mes, point)

			if 'heart' in mes_type:
				time_int = (int)(data_mes) + 1
				heart_str = '服务端返回心跳：%d' %(time_int)
				# if point == 8000:
				# 	#是 lock 的链接 设置链接状态 返回心跳数据
				# 	lockLink = 'on'
				# 	lockedState = data_dic['lockState']
				# 	sendMessage(sock, 'heart', heart_str)
				# else:
				# 是 客户端的心跳包 + 锁的状态
				sendClientsMessage(sock, 'heart', heart_str, 'on', lockState)
			else:
				if data_mes == 'exit':
					break
				else:
					# 普通消息
					# mes = '服务端返回数据：' + data_mes
					# # 粘 包了 
					# sendMessage(sock, 'command', mes)
					# if point == 8000:
					# 	lockLink = 'on'
					# 	lockedState = data_dic['lockState']
					# 	# 收到 锁发来的状态信息 向所有 客户端发送锁的状态
					# 	for sockone in sock_list:
					# 		sendMessage(sockone, 'heart', lockedState, lockLink, lockedState)
						
					# else:
					# 	#向 lockSock 发送 指令
					# 	if lockLink in 'on':
					# 		sendMessage(lockSock, 'command', data_mes)

					# 是 服务器发来的命令(开门)
					if data_mes in 'ff':
						# 是 开的命令
						lockState = 'on'
						# 收到 开锁命令 向所有 客户端发送锁的状态
						for sockone in sock_list:
							sendClientsMessage(sockone, 'heart', lockState, 'on', lockState)
						ble.send_open()
						lockState = 'off'
						# 收到 开锁命令 向所有 客户端发送锁的状态
						for sockone in sock_list:
							sendClientsMessage(sockone, 'heart', lockState, 'on', lockState)


		except Exception as e:
			# 接收异常的情况下，断开连接。
			print('抛出异常：',e)
			break
	socketClientClose(sock)

	
threadTime = threading.Thread(target = fun_timer)
threadTime.start()

threadServer = threading.Thread(target = createSocket, args=(8008,))
threadServer.start()




	# 给服务器发送消息
	# input_str = input('输入内容：')

	# client.send(input_str.encode('utf8'))

	# if input_str == 'exit':
	# 	isconnect = False
	# 	break
	









