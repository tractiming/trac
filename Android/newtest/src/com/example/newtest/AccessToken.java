package com.example.newtest;

import java.util.List;

import com.google.gson.annotations.SerializedName;

public class AccessToken {

	@SerializedName ("access_token")
	public String access_token;
	@SerializedName ("token_type")
	public String token_type;
	@SerializedName ("expires_in")
	public String expires_in;
	@SerializedName ("scope")
	public String scope;

}
