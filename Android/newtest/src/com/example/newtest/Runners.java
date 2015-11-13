package com.example.newtest;


import java.util.List;

import com.google.gson.annotations.SerializedName;

public class Runners {
	//For JSON
	@SerializedName ("name")
	public String name;
	@SerializedName ("splits")
	public List<String[]> interval;
	@SerializedName ("id")
	public String id;
	@SerializedName ("total")
	public String total;
	@SerializedName ("has_split")
	public String has_split;
}
