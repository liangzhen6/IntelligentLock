#!/usr/bin/env python3
import threading

class LockState(object):
	"""docstring for SocketManger"""
	def __init__(self):
		self.lockState = 'off'
		self.lock = threading.Lock()
		

	def getLockState(self):
		#获取锁的状态
		return self.lockState
		
	def  setLockState(self, state):
		#加锁
		self.lock.acquire()
		try:
			self.lockState = state
		finally:
			#释放锁
			self.lock.release()

lockSocketState = LockState()





