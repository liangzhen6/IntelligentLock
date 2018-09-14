#!/usr/bin/env python3
import socket
import threading
import time
import json
from aes import crypto

#创建sockte 实例
sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

#定义绑定的ip 和 端口
ip_point = ('192.168.1.104', 8000)

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

def sendMessage(typeStr, mes):
	send_mes = {'Mtype':typeStr, 'Mes':mes}
	send_json = json.dumps(send_mes, sort_keys=True, indent=4)
	code_json = crypto.encrypt(send_json)
	if sock != None:
		sock.send(code_json)


while True:
	print('等待接收数据')
	# 接受数据
	sock, addr = sk.accept()
	message = '链接成功' + str(addr)
	sendMessage('commamd', message)
	while True:
		# 获取从客户端发来的数据
		# 一次1K的数据
		# python3.x以上的版本。网络数据的发送接受都是byte类型。
		# 如果发送的数据是str类型则需要进行编解码
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

			if 'heart' in mes_type:
				#是心跳包数据
				# 返回心跳包数据 +1
				time_int = (int)(data_mes) + 1
				heart_str = '服务端返回心跳：%d' %(time_int)
				sendMessage('heart', heart_str)
				
				if time != None:
					#如果存在time 关闭定时器触发
					time.cancel()
				# 重新启动心跳包检测的定时器
				time = threading.Timer(20.0, socketClose)
				time.start()
			else:
				if data_mes == 'exit':
					break
				else:
					# 给客户端返回数据
					mes = '服务端返回数据：' + data_mes
					sendMessage('commamd', mes)

		except Exception as e:
			# 接收异常的情况下，断开连接。
			break
		

	# 主动关闭链接
	# sock.close()
	socketClose()










