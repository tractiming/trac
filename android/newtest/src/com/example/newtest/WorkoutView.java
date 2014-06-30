package com.example.newtest;


import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import com.google.gson.Gson;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import android.support.v4.app.Fragment;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;


public class WorkoutView extends Fragment{
	private static final String DEBUG_TAG = "griffinSucks";
	//this field holds a reference to text field
	private TextView mTextView;
	/**
	 * Returns a new instance of this fragment.
	 */
	
	public WorkoutView() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.fragment_workout_view, container,
				false);
		mTextView = (TextView) rootView.findViewById(R.id.group_text_view);
		new AsyncServiceCall().execute("http://echo.jsontest.com/key/value/one/two");
		Log.d(DEBUG_TAG, "onCreateView CALLED");
		return rootView;
	}

	 OkHttpClient client = new OkHttpClient();
	 Gson gson = new Gson();
	 
	 
	  
	  private class AsyncServiceCall extends AsyncTask<String, Void, Object> {
		  
		@Override
		protected workout doInBackground(String... params) {
			Request request = new Request.Builder()
	        .url(params[0])
	        .build();
			try {
			    Response response = client.newCall(request).execute();
			    workout parsedjWorkout = gson.fromJson(response.body().charStream(), workout.class);
			   
			    Log.d(DEBUG_TAG, "GSON");
			    return parsedjWorkout;
			    
			} catch (IOException e) {
				Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
				return null;
			}
		}
		
		@Override
		protected void onPostExecute(Object result) {
			Log.d(DEBUG_TAG,"execute");
			String resultstring = result.toString();
			//System.out.println(resultstring);
			//set result to show on screen
			mTextView.setText(resultstring);
			
			
			
		}
		  
	  }

	 
	}