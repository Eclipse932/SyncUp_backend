"""
Each file that starts with test... in this directory is scanned for subclasses of unittest.TestCase or testLib.RestTestCase
"""

import unittest
import os
import testLib


class TestUnit(testLib.RestTestCase):
    """Issue a REST API request to run the unit tests, and analyze the result"""
    def testUnit(self):
        respData = self.makeRequest("/api/v1/TESTAPI/unitTests", method="POST")
        self.assertTrue('output' in respData)
        print ("Unit tests output:\n"+
               "\n***** ".join(respData['output'].split("\n")))
        self.assertTrue('totalTests' in respData)
        print "***** Reported "+str(respData['totalTests'])+" unit tests. nrFailed="+str(respData['nrFailed'])
        # When we test the actual project, we require at least 10 unit tests
        minimumTests = 3
        if "SAMPLE_APP" in os.environ:
            minimumTests = 3
        self.assertTrue(respData['totalTests'] >= minimumTests,
                        "at least "+str(minimumTests)+" unit tests. Found only "+str(respData['totalTests'])+". use SAMPLE_APP=1 if this is the sample app")
        self.assertEquals(0, respData['nrFailed'])




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
																		  'password_confirmation' : 'password2', 'first_name' : 'u1'}} )
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
																		  'password_confirmation' : password, 'first_name' : nickname}} )
		self.assertResponse(respData, success = True, data = { 'email' : name + '@example.com'})
		user = {}
		user['email'] = respData['data']['email']
		user['token'] = respData['data']['auth_token']
		user['first_name'] = respData['data']['user']['first_name']
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




class TestActivitySystem(testLib.RestTestCase):
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
																		  'password_confirmation' : password, 'first_name' : nickname}} )
		self.assertResponse(respData, success = True, data = { 'email' : name + '@example.com'})
		user = {}
		user['email'] = respData['data']['email']
		user['token'] = respData['data']['auth_token']
		user['first_name'] = respData['data']['user']['first_name']
		user['id'] = respData['data']['user']['id']
		user['url'] = "?email=" + user['email'] + "&token=" + user['token']
		return user


	def createActivity(self, user, name='', location=None, description=None, visibility=1):
		respData = self.makeRequest("/api/v1/activities" + user['url'], method="POST", data = { 'activity' : { 'name': name,
																											   'location': location,
																											   'description': description,
																											   'visibility': visibility}} )
		self.assertResponse(respData, success = True, data = { 'host_id' : user['id'],
															   'name' : name,
															   'location' : location,
															   'description' : description,
															   'visibility' : visibility})
		return respData['data']


	def testCreatAndGetMyActivites(self):

		user1 = self.createUser('user1', 'password')

		act1 = self.createActivity(user1, name='activity1', location='location1', description='description1')

		respData = self.makeRequest("/api/v1/activities" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, data = { 'host_id' : [user1['id']],
															   'name' : [act1['name']]}, dataType = "LIST")


	def testGetFriendsActivities(self):

		user1 = self.createUser('user1', 'password')
		user2 = self.createUser('user2', 'password')
		user3 = self.createUser('user3', 'password')

		respData = self.makeRequest("/api/v1/requestFriend" + user1['url'], method="POST", data = { 'friendship' : { 'friend_id': user2['id']}} )
		self.assertResponse(respData, success = True, info = "request friend")

		respData = self.makeRequest("/api/v1/getSentRequests" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get sent friend requests", data = { 'id' : [user2['id']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/requestFriend" + user1['url'], method="POST", data = { 'friendship' : { 'friend_id': user3['id']}} )
		self.assertResponse(respData, success = True, info = "request friend")

		respData = self.makeRequest("/api/v1/confirmFriend" + user2['url'], method="POST", data = { 'friendship' : { 'request_id' : user1['id'],
																													 'response' : True}} )
		self.assertResponse(respData, success = True, info = "accept friend")

		respData = self.makeRequest("/api/v1/confirmFriend" + user3['url'], method="POST", data = { 'friendship' : { 'request_id' : user1['id'],
																													 'response' : True}} )
		self.assertResponse(respData, success = True, info = "accept friend")

		respData = self.makeRequest("/api/v1/getFriends" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get all friends", data = { 'id' : [user2['id'], user3['id']]}, dataType = "LIST")

		act1 = self.createActivity(user1, name='user1act', location='location1', description='description1')
		act2 = self.createActivity(user2, name='user2act', location='location2', description='description2')
		act3 = self.createActivity(user3, name='user3act', location='location3', description='description3')


		respData = self.makeRequest("/api/v1/getFriendsActivities" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, data = { 'host_id' : [user2['id'], user3['id']],
															   'name' : [act2['name'], act3['name']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/getFriendsActivities" + user2['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, data = { 'host_id' : [user1['id']],
															   'name' : [act1['name']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/getFriendsActivities" + user3['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, data = { 'host_id' : [user1['id']],
															   'name' : [act1['name']]}, dataType = "LIST")



	def testJoinActivities(self):

		user1 = self.createUser('user1', 'password')
		user2 = self.createUser('user2', 'password')
		user3 = self.createUser('user3', 'password')

		respData = self.makeRequest("/api/v1/requestFriend" + user1['url'], method="POST", data = { 'friendship' : { 'friend_id': user2['id']}} )
		self.assertResponse(respData, success = True, info = "request friend")

		respData = self.makeRequest("/api/v1/getSentRequests" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get sent friend requests", data = { 'id' : [user2['id']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/requestFriend" + user1['url'], method="POST", data = { 'friendship' : { 'friend_id': user3['id']}} )
		self.assertResponse(respData, success = True, info = "request friend")

		respData = self.makeRequest("/api/v1/confirmFriend" + user2['url'], method="POST", data = { 'friendship' : { 'request_id' : user1['id'],
																													 'response' : True}} )
		self.assertResponse(respData, success = True, info = "accept friend")

		respData = self.makeRequest("/api/v1/confirmFriend" + user3['url'], method="POST", data = { 'friendship' : { 'request_id' : user1['id'],
																													 'response' : True}} )
		self.assertResponse(respData, success = True, info = "accept friend")

		respData = self.makeRequest("/api/v1/getFriends" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, info = "get all friends", data = { 'id' : [user2['id'], user3['id']]}, dataType = "LIST")

		act1 = self.createActivity(user1, name='user1act', location='location1', description='description1')
		act2 = self.createActivity(user2, name='user2act', location='location2', description='description2')
		act3 = self.createActivity(user3, name='user3act', location='location3', description='description3')


		respData = self.makeRequest("/api/v1/joinActivity" + user1['url'], method="POST", data = { 'activity' : { 'activity_id' : act2['id']}} )
		self.assertResponse(respData, success = True)

		respData = self.makeRequest("/api/v1/activities" + user1['url'], method="GET", data = {} )
		self.assertResponse(respData, success = True, data = { 'host_id' : [user1['id'], user2['id']],
															   'name' : [act1['name'], act2['name']]}, dataType = "LIST")

		respData = self.makeRequest("/api/v1/joinActivity" + user2['url'], method="POST", data = { 'activity' : { 'activity_id' : act3['id']}} )
		self.assertResponse(respData, success = False, info="not friend with host, so cannot join activity")



