package com.example.newtest;



import java.io.IOException;

import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.View;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

public class WorkoutView extends ListFragment {

  @Override
  public void onActivityCreated(Bundle savedInstanceState) {
    super.onActivityCreated(savedInstanceState);
   
    new AsyncServiceCall().execute("http://76.12.155.219/trac/json/test.json");
   
  }

  @Override
  public void onListItemClick(ListView l, View v, int position, long id) {
    Toast.makeText(getActivity(), ((Runners)l.getItemAtPosition(position)).name + "", Toast.LENGTH_SHORT).show();
  }
  private TextView mTextView;

  
  
  	OkHttpClient client = new OkHttpClient();
	Gson gson = new Gson();
	private static final String DEBUG_TAG = "griffinSucks";
	
	  private class AsyncServiceCall extends AsyncTask<String, Void, Workout> {
		  
			@Override
			protected Workout doInBackground(String... params) {
				Request request = new Request.Builder()
		        .url(params[0])
		        .build();
				try {
				    Response response = client.newCall(request).execute();
				    Workout parsedjWorkout = gson.fromJson(response.body().charStream(), Workout.class);
				   
				    Log.d(DEBUG_TAG, "GSON");
				    return parsedjWorkout;
				    
				} catch (IOException e) {
					Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
					return null;
				}
			}
			
			@Override
			protected void onPostExecute(Workout result) {
				Log.d(DEBUG_TAG,"execute");
				String resultstring = result.toString();
				
				//System.out.println(resultstring);
				//set result to show on screen
				
			  
			    setListAdapter(new WorkoutAdapter(result, getActivity()));			
			}
			  
		  }


  
  
} 