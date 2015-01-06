package com.example.newtest;


import java.util.List;

import com.google.gson.annotations.SerializedName;

public class Runners {
	//For JSON
	@SerializedName ("name")
	public String name;
	@SerializedName ("counter")
	public String[] counter;
	@SerializedName ("interval")
	public List<String[]> interval;
}
