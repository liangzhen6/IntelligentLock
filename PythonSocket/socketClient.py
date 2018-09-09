#!/usr/bin/env python3
import socket
import threading
import time

#创建sockte 实例
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

#定义绑定的ip 和 端口
ip_point = ('127.0.0.1', 8000)

global isconnect
isconnect = False

#绑定监听
client.connect(ip_point)
isconnect = True

def fun_timer():
	time_int = (int)(time.time())
	heart_str = 'heart:%d' %(time_int)
	client.send(heart_str.encode('utf8'))
	if isconnect:
		timer = threading.Timer(15.0, fun_timer)
		timer.start()
fun_timer()

while True:
	# 接受数据
	data = client.recv(1024)
	print(data.decode('utf8'));
	
	# 给服务器发送消息
	# input_str = input('输入内容：')

	# client.send(input_str.encode('utf8'))

	# if input_str == 'exit':
	# 	isconnect = False
	# 	break
	









