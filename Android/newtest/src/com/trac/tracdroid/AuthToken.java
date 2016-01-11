package com.trac.tracdroid;

import com.google.gson.annotations.SerializedName;

public class AuthToken {
	//Allows JSON response from server to be parsed when it returns token
		@SerializedName ("access_token")
		public String access_token;
		@SerializedName ("token_type")
		public String token_type;
		@SerializedName ("expires_in")
		public String expires_in;
		@SerializedName ("scope")
		public String scope;
}
