package com.example.newtest;

import java.util.ArrayList;
import java.util.List;

import com.google.gson.JsonArray;
import com.google.gson.annotations.SerializedName;

public class IndividualResults {

	//For JSON 
	
	@SerializedName ("num_sessions")
	public String num_sessions;
	@SerializedName ("results")
	public List<Runners> results;
	@SerializedName ("num_returned")
	public String num_returned;

	
}
