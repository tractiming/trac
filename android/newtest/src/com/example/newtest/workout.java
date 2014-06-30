package com.example.newtest;

import com.google.gson.annotations.SerializedName;



public class workout {
	@SerializedName ("one")
	private String one;
	@SerializedName ("key")
	private String key;
	

	
	@Override
    public String toString() {
        return one + key + "hello";
    }
}
