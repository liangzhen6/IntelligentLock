#!/usr/bin/env python3
import socket
import threading
import time
import json
from aes import crypto
# from lockConnect import LockConnect

lockLink = 'off' # 锁的链接状态 on off
lockedState = 'off' # 锁的状态  off  opening on  三种
lockSock = None
sock_list = []  # 服务器所有socket 列表

def socketClose(sock):
		#关闭连接
		if sock != None:
			sock.close()
			# 移除这个链接 从链接列表内
			if sock in sock_list:
				sock_list.remove(sock)
			print('关闭连接')

def sendMessage(sock, typeStr, mes = None, lockLink = None, lockState = None):
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

def createSocket(point):
	#初始化 监听等
	sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	ip = '192.168.1.104'
	sk.bind((ip, point))
	sk.listen()

	while True:
		print('服务器-等待接收数据')
		sock, addr = sk.accept()
		message = '链接成功' + str(addr)
		sendMessage(sock, 'command', message)
		print(message)
		if point == 8000:
			global lockSock, sock_list
			# 是lock 的链接
			lockSock = sock
			lockLink = 'on'
			handle_socket(sock, addr, point)
		else:
			sock_list.append(sock)
			client_thread = threading.Thread(target = handle_socket, args=(sock, addr, point))
			client_thread.start()

def handle_socket(sock, addr, point):
	global lockLink, lockedState
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
				if point == 8000:
					#是 lock 的链接 设置链接状态 返回心跳数据
					lockLink = 'on'
					lockedState = data_dic['lockState']
					sendMessage(sock, 'heart', heart_str)
				else:
					# 是 客户端的心跳包 + 锁的状态
					sendMessage(sock, 'heart', heart_str, lockLink, lockedState)
			else:
				if data_mes == 'exit':
					break
				else:
					# 普通消息
					mes = '服务端返回数据：' + data_mes
					# # 粘 包了 
					# sendMessage(sock, 'command', mes)
					if point == 8000:
						lockLink = 'on'
						lockedState = data_dic['lockState']
						# 收到 锁发来的状态信息 向所有 客户端发送锁的状态
						for sockone in sock_list:
							sendMessage(sockone, 'heart', lockedState, lockLink, lockedState)
						
					else:
						#向 lockSock 发送 指令
						if lockLink in 'on':
							sendMessage(lockSock, 'command', data_mes)


		except Exception as e:
			# 接收异常的情况下，断开连接。
			print('抛出异常：',e)
			break
	if point == 8000:
		#是 lock 的链接 设置链接状态
		lockLink = 'off'
	socketClose(sock)

lockServer = threading.Thread(target = createSocket, args=(8000,))
lockServer.start()

threadServer = threading.Thread(target = createSocket, args=(8008,))
threadServer.start()







