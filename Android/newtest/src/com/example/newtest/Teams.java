package com.example.newtest;

import com.google.gson.annotations.SerializedName;

public class Teams {
	@SerializedName ("id")
	public String id;
	@SerializedName ("coach")
	public String coach;
	@SerializedName ("name")
	public String name;
	@SerializedName ("primary_team")
	public Boolean primary_team;
	@SerializedName ("tfrrs_code")
	public String tfrrs_code;

}
