package com.trac.tracdroid;

import java.util.List;

import com.google.gson.annotations.SerializedName;

public class AccessToken {
	//Allows JSON response from server to be parsed when it returns token
	@SerializedName ("username")
	public String username;
	@SerializedName ("client_secret")
	public String client_secret;
	@SerializedName ("user_type")
	public String user_type;
	@SerializedName ("client_id")
	public String client_id;

}
