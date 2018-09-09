#!/usr/bin/env python3
import socket
import threading
import time

#创建sockte 实例
sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

#定义绑定的ip 和 端口
ip_point = ('192.168.1.5', 8000)

#绑定监听
sk.bind(ip_point)

#监听
sk.listen()

global sock, time
sock = None
time = None

# 关闭 socket 链接
def socketClose():
	if sock != None:
		sock.close()
		print('关闭链接！')


while True:
	print('等待接收数据')
	# 接受数据
	sock, addr = sk.accept()
	message = '链接成功'
	sock.send(message.encode('utf8'))
	while True:
		# 获取从客户端发来的数据
		# 一次1K的数据
		# python3.x以上的版本。网络数据的发送接受都是byte类型。
		# 如果发送的数据是str类型则需要进行编解码
		data = sock.recv(1024)
		str_data = data.decode('utf8')
		print('收到客户端发来的数据：'+str_data)

		if 'heart' in str_data:
			#是心跳包数据
			# 返回心跳包数据 +1
			time_int = (int)(str_data[6:]) + 1
			heart_str = 'heart:%d' %(time_int)
			sock.send(heart_str.encode('utf8'))

			if time != None:
				#如果存在time 关闭定时器触发
				time.cancel()
			# 重新启动心跳包检测的定时器
			time = threading.Timer(20.0, socketClose)
			time.start()
		elif str_data == 'exit':
			#退出指令
			break;
		else:
			#是其他数据
			# 给客户端返回数据
			mes = '服务端返回数据：' + str_data
			sock.send(mes.encode('utf8'))

	# 主动关闭链接
	# sock.close()
	socketClose()










