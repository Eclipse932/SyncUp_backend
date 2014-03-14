"""
Each file that starts with test... in this directory is scanned for subclasses of unittest.TestCase or testLib.RestTestCase
"""

import unittest
import os
import testLib

class TestLoginSystem(testLib.RestTestCase):
	"""Test login system"""

	debug = False

	def assertResponse(self, respData, success = True, info = None, data = None):
		"""
		Check that the response data dictionary matches the expected values
		"""
		if self.debug:
			print "expected success: " + str(success) + " actual return: " + str(respData['success'])
			print "in info: " + str(respData['info'])
			if 'data' in respData:
				print "in data: " + str(respData['data'])

		expected = { 'success' : success }
		self.assertEqual(success, respData['success'])
		if info != None:
			self.assertEqual(info, respData['info'])
		if data != None:
			for key in data:
				assert key in respData['data'] 
				self.assertEqual(data[key], respData['data'][key])


	def testUserEmailExists1(self):
		respData = self.makeRequest("/api/v1/registrations", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password',\
																		  'password_confirmation' : 'password'}} )
		self.assertResponse(respData, success = True, data = { 'email' : 'user1@example.com'})

		respData = self.makeRequest("/api/v1/registrations", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password',\
																		  'password_confirmation' : 'password'}} )
		self.assertResponse(respData, success = False)


	def testUserEmailExists2(self):
		respData = self.makeRequest("/api/v1/registrations", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password',\
																		  'password_confirmation' : 'password'}} )
		self.assertResponse(respData, success = True, data = { 'email' : 'user1@example.com'})

		respData = self.makeRequest("/api/v1/registrations", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password2',\
																		  'password_confirmation' : 'password2', 'name' : 'u1'}} )
		self.assertResponse(respData, success = False)


	def testUserWrongPassword(self):
		respData = self.makeRequest("/api/v1/registrations", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password',\
																		  'password_confirmation' : 'password'}} )
		self.assertResponse(respData, success = True, data = { 'email' : 'user1@example.com'})

		respData = self.makeRequest("/api/v1/sessions", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password2'}} )
		self.assertResponse(respData, success = False, info = "Login Failed")


	def testUserNotExists(self):
		respData = self.makeRequest("/api/v1/registrations", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password',\
																		  'password_confirmation' : 'password'}} )
		self.assertResponse(respData, success = True, data = { 'email' : 'user1@example.com'})

		respData = self.makeRequest("/api/v1/sessions", method="POST", data = { 'user' : { 'email' : 'user2@example.com', 'password' : 'password'}} )
		self.assertResponse(respData, success = False, info = "Login Failed")


	def testLoginThroughEmailPassword(self):
		respData = self.makeRequest("/api/v1/registrations", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password',\
																		  'password_confirmation' : 'password'}} )
		self.assertResponse(respData, success = True, data = { 'email' : 'user1@example.com'})
		token = respData['data']['auth_token']

		respData = self.makeRequest("/api/v1/sessions", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password'}} )
		self.assertResponse(respData, success = True, data = { 'email' : 'user1@example.com', 'auth_token' : token})


	def testTokenAuthentication(self):
		respData = self.makeRequest("/api/v1/registrations", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password',\
																		  'password_confirmation' : 'password'}} )
		self.assertResponse(respData, success = True, data = { 'email' : 'user1@example.com'})
		email = respData['data']['email']
		token = respData['data']['auth_token']

		respData = self.makeRequest("/api/v1/activities?email=" + email + "&token=" + token, method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "activites!")


	def testLogout(self):
		respData = self.makeRequest("/api/v1/registrations", method="POST", data = { 'user' : { 'email' : 'user1@example.com', 'password' : 'password',\
																		  'password_confirmation' : 'password'}} )
		self.assertResponse(respData, success = True, data = { 'email' : 'user1@example.com'})
		email = respData['data']['email']
		token = respData['data']['auth_token']

		respData = self.makeRequest("/api/v1/sessions?email=" + email + "&token=" + token, method="DELETE", data = {} )
		self.assertResponse(respData, success = True, info = "Logged out")

		respData = self.makeRequest("/api/v1/activities?email=" + email + "&token=" + token, method="GET", data = {} )
		self.assertResponse(respData, success = False, info = "user not signed in")




class TestFriendSystem(testLib.RestTestCase):
	"""Test activities"""
	
	debug = False

	def assertResponse(self, respData, success = True, info = None, data = None, dataType = "JSON"):
		"""
		Check that the response data dictionary matches the expected values
		"""
		if self.debug:
			print "expected success: " + str(success) + " actual return: " + str(respData['success'])
			print "in info: " + str(respData['info'])
			if 'data' in respData:
				print "in data: " + str(respData['data'])

		expected = { 'success' : success }
		self.assertEqual(success, respData['success'])
		if info != None:
			self.assertEqual(info, respData['info'])
		if data != None:
			if dataType == "JSON":
				for key in data:
					assert key in respData['data'] 
					self.assertEqual(data[key], respData['data'][key])
			else:
				assert dataType == "LIST"
				if data:
					for key in data:
						valueList = [entry[key] for entry in respData['data']]
						self.assertListEqual(data[key], valueList)
				else:
					self.assertEqual(data, respData['data'])


	def createUser(self, name, password, nickname=None):
		respData = self.makeRequest("/api/v1/registrations", method="POST", data = { 'user' : { 'email' : name + '@example.com', 'password' : password,\
																		  'password_confirmation' : password, 'name' : nickname}} )
		self.assertResponse(respData, success = True, data = { 'email' : name + '@example.com'})
		user = {}
		user['email'] = respData['data']['email']
		user['token'] = respData['data']['auth_token']
		user['name'] = respData['data']['user']['name']
		user['id'] = respData['data']['user']['id']
		user['url'] = "?email=" + user['email'] + "&token=" + user['token']
		return user





	def testRequestAndConfirmFriend(self):

		user1 = self.createUser('user1', 'password')
		user2 = self.createUser('user2', 'password')
		user3 = self.createUser('user3', 'password')

		respData = self.makeRequest("/api/v1/requestFriend" + user1['url'], method="POST", data = { 'friendship' : { 'friend_id': user2['id']}} )
		self.assertResponse(respData, success = True, info = "request friend")

		respData = self.makeRequest("/api/v1/getSentRequests" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get sent friend requests", data = { 'id' : [user2['id']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/requestFriend" + user1['url'], method="POST", data = { 'friendship' : { 'friend_id': user3['id']}} )
		self.assertResponse(respData, success = True, info = "request friend")

		respData = self.makeRequest("/api/v1/getSentRequests" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get sent friend requests", data = { 'id' : [user2['id'], user3['id']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/getPendingFriends" + user2['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get pending friend requests", data = { 'id' : [user1['id']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/getPendingFriends" + user3['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get pending friend requests", data = { 'id' : [user1['id']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/confirmFriend" + user2['url'], method="POST", data = { 'friendship' : { 'request_id' : user1['id'],
																													 'response' : True}} )
		self.assertResponse(respData, success = True, info = "accept friend")


		respData = self.makeRequest("/api/v1/getFriends" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get all friends", data = { 'id' : [user2['id']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/getFriends" + user2['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get all friends", data = { 'id' : [user1['id']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/getFriends" + user3['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get all friends", data = { 'id' : []}, dataType = "LIST")


	def testCancelRequest(self):
		user1 = self.createUser('user1', 'password')
		user2 = self.createUser('user2', 'password')

		respData = self.makeRequest("/api/v1/requestFriend" + user1['url'], method="POST", data = { 'friendship' : { 'friend_id': user2['id']}} )
		self.assertResponse(respData, success = True, info = "request friend")

		respData = self.makeRequest("/api/v1/getSentRequests" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get sent friend requests", data = { 'id' : [user2['id']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/getPendingFriends" + user2['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get pending friend requests", data = { 'id' : [user1['id']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/deleteRequest" + user1['url'], method="POST", data = { 'friendship' : { 'request_id': user2['id']}} )
		self.assertResponse(respData, success = True, info = "delete succeeds")

		respData = self.makeRequest("/api/v1/getSentRequests" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get sent friend requests", data = { 'id' : []}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/getPendingFriends" + user2['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get pending friend requests", data = { 'id' : []}, dataType = "LIST")












class TestActivities(testLib.RestTestCase):
	"""Test activities"""
	
	debug = True

	def assertResponse(self, respData, success = True, info = None, data = None):
		"""
		Check that the response data dictionary matches the expected values
		"""
		if self.debug:
			print "expected success: " + str(success) + " actual return: " + str(respData['success'])
			print "in info: " + str(respData['info'])
			if 'data' in respData:
				print "in data: " + str(respData['data'])

		expected = { 'success' : success }
		self.assertEqual(success, respData['success'])
		if info != None:
			self.assertEqual(info, respData['info'])
		if data != None:
			for key in data:
				assert key in respData['data'] 
				self.assertEqual(data[key], respData['data'][key])












