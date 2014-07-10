package com.example.newtest;

import java.util.List;

import com.google.gson.annotations.SerializedName;



public class Workout {
	@SerializedName ("date")
	public String date;
	@SerializedName ("workoutID")
	public String id;
	@SerializedName ("runners")
	public List<Runners> runners;

	
	
	
}

