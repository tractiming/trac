package com.trac.tracdroid;


import com.google.gson.annotations.SerializedName;

import java.util.List;

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
	@SerializedName ("first_seen")
	public String first_seen;
}
