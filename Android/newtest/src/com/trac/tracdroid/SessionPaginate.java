package com.trac.tracdroid;

import java.util.ArrayList;
import java.util.List;

import com.google.gson.JsonArray;
import com.google.gson.annotations.SerializedName;

public class SessionPaginate {

	//For JSON 
	
	@SerializedName ("count")
	public String id;
	@SerializedName ("results")
	public JsonArray results;


	
}