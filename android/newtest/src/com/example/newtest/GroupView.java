package com.example.newtest;

import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;
import java.io.IOException;
import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;



public class GroupView extends Fragment{

	/**
	 * Returns a new instance of this fragment.
	 */
	
	public GroupView() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.fragment_group_view, container,
				false);
		return rootView;
	}

	  OkHttpClient client = new OkHttpClient();

	  String run(String url) throws IOException {
	    Request request = new Request.Builder()
	        .url(url)
	        .build();

	    Response response = client.newCall(request).execute();
	    return response.body().string();
	  }

	  public static void main(String[] args) throws IOException {
	    GroupView example = new GroupView();
	    String response = example.run("http://76.12.155.219/trac/files/data.json");
	    System.out.println(response);
	  }
	}