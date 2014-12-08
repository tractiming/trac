package com.example.newtest;


import java.util.List;

import com.google.gson.annotations.SerializedName;

public class Runners {
	@SerializedName ("name")
	public String name;
	@SerializedName ("counter")
	public String[] counter;
	@SerializedName ("interval")
	public List<String[]> interval;
}
