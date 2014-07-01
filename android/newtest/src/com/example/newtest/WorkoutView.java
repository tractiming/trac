package com.example.newtest;



import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import com.google.gson.Gson;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.support.v4.app.ListFragment;

public class WorkoutView extends ListFragment {

  @Override
  public void onActivityCreated(Bundle savedInstanceState) {
    super.onActivityCreated(savedInstanceState);
    String[] values = new String[] { "Griffin", "Elliot", "Jason",
        "Gabe"};
    ArrayAdapter<String> adapter = new ArrayAdapter<String>(getActivity(),
        android.R.layout.simple_list_item_1, values);
    setListAdapter(adapter);
  }

  @Override
  public void onListItemClick(ListView l, View v, int position, long id) {
    // do something with the data
  }
  private TextView mTextView;
  	OkHttpClient client = new OkHttpClient();
	Gson gson = new Gson();
	private static final String DEBUG_TAG = "griffinSucks";
	
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
				
								
			}
			  
		  }


  
  
} 