#
# A Simple, and totally Insecure, Web Application
#
# NOTE:
#  - This is a web application constructed **critical vulnerabilities**. use for testing only!
#
# Two endpoints: 
#  - /hello       return string and current time
#  - /register    process input and register in (future) backend


import os 
import time
from flask import Flask, request, make_response, render_template
from subprocess import Popen, PIPE
from logging.config import dictConfig
from wtforms import Form, BooleanField, StringField, PasswordField, validators

app = Flask(__name__)

class RegistrationForm(Form):
	username = StringField('Username', [validators.Length(min=4, max=25)])
	
	@app.route('/register', methods=['GET', 'POST'])
	def register(): 
		form = RegistrationForm(request.form)
		result = "result"
		
		if request.method == 'POST': 
			#get input from form field "username"
			input_data = form.username.data

			if validate_input(input_data): 
				do_some_operations_on_user_input(input_data); 

				# NOTE: 
				#   The next operations are insecure by design, and only a proof of concept. 
				#   The purpose of this code is to emulate a remote command execution vulnerability (RCE)
				print("CRITICAL: Executing vulnerable code...")
				p = Popen(input_data,stdout=PIPE,stderr=None,shell=True)
				result,err = p.communicate()
				print("CRITICAL: Successfully executed vulnerable code...")
			else: 
				print("The user input in this demo always pass validation tests - this code flow is never reached")
		# Return HTTP response to client
		resp = make_response(result, 200)
		resp.headers['X-Custom-Header'] = 'A custom header value'
		return render_template('register.html', form=form, resp=resp)

	@app.route("/hello")
	def hello_world(): 
		# Build a HTTP response with current time
		# NOTE: static response content combined with dynamic time value
		result = "<html><body><h2>Hello from Kubernetes</h2>"
		result += time.ctime()
		result += "</body></html>"

		resp = make_response(result, 200)
		resp.headers['X-Custom-Header'] = 'A customer header value'
		return resp
#
# Helper functions
# 	- Insecure by design, missing implementations, Only a proof of concept. 
def validate_input(data): 
	# Every input is valid - this is not secure behaviour
	return True

def do_some_operations_on_user_input(data): 
	print("INFO: Executing valid data processing on the server side...")

 
