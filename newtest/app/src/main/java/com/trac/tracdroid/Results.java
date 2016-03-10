package com.trac.tracdroid;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class Results {
	//For JSON 
	
	@SerializedName ("id")
	public String id;
	@SerializedName ("name")
	public String name;
	@SerializedName ("start_time")
	public String startTime;
	@SerializedName ("stop_time")
	public String stopTime;
	@SerializedName ("rest_time")
	public String restTime;
	@SerializedName ("track_size")
	public String tracksize;
	@SerializedName ("interval_distance")
	public String intervaldist;
	@SerializedName ("interval_number")
	public String intervalnum;
	@SerializedName ("filter_choice")
	public String filterchoice;
	@SerializedName ("manager")
	public String manager;
	@SerializedName ("results")
	public String results;
	@SerializedName ("readers")
	public List readers;

	
}
