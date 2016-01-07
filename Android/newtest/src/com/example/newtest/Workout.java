package com.example.newtest;

import java.util.List;

import com.google.gson.annotations.SerializedName;



public class Workout {
	
	//For JSON
	@SerializedName ("num_results")
	public String num_results;
	@SerializedName ("num_returned")
	public String num_returned;
	@SerializedName ("results")
	public List<Runners> runners;

	
	
	
}

