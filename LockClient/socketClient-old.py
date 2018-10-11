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
# 关闭 socket 链接
def socketClose():
	if client != None:
		client.close()
		isconnect = False
		print('关闭链接！')

def sendMessage(typeStr, mes):
	send_mes = {'Mtype':typeStr, 'Mes':mes, 'lockState':lockState}
	# send_json = json.dumps(send_mes, sort_keys=True, indent=4)
	send_json = json.dumps(send_mes)
	code_json = crypto.encrypt(send_json)
	if client != None:
		client.send(code_json)


def clientConnect():
	global isconnect, client, lockState
	#创建sockte 实例
	client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

	#定义绑定的ip 和 端口
	ip_point = ('192.168.1.104', 8000)
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

fun_timer()

	


	# 给服务器发送消息
	# input_str = input('输入内容：')

	# client.send(input_str.encode('utf8'))

	# if input_str == 'exit':
	# 	isconnect = False
	# 	break
	









