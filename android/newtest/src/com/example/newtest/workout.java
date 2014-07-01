package com.example.newtest;

import com.google.gson.annotations.SerializedName;



public class workout {
	@SerializedName ("one")
	public String one;
	@SerializedName ("key")
	public String key;
	

	
	@Override
    public String toString() {
        return one + key + "hello";
    }
}
