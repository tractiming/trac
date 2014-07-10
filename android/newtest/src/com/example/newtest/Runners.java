package com.example.newtest;

import com.google.gson.annotations.SerializedName;

public class Runners {
	@SerializedName ("name")
	public String name;
	@SerializedName ("interval")
	public Interval interval;

}
