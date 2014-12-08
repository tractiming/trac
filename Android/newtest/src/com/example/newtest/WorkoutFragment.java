package com.example.newtest;



import java.io.IOException;

import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import android.os.Bundle;
import android.os.SystemClock;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Chronometer;


public class WorkoutFragment extends ListFragment {
	
	private TextView mTextView;
	private Boolean isVisible;
	
	
  @Override
  public void onActivityCreated(Bundle savedInstanceState) {
    super.onActivityCreated(savedInstanceState);
    
    // 1. get passed intent 
		Intent intent = getActivity().getIntent();
		
     // 2. get message value from intent
     String message = intent.getStringExtra("message");
     Log.d("The passed Variable Workout Fragment", message);
    new AsyncServiceCall().execute(message);
    
         
    
  }

  @Override
  public void onListItemClick(ListView l, View v, int position, long id) {
	  View toolbar = v.findViewById(R.id.expanded_bar);
	 
      // Creating the expand animation for the item
      ExpandAnimation expandAni = new ExpandAnimation(toolbar, 500);

      // Start the animation on the toolbar
     toolbar.startAnimation(expandAni);
     
     TextView mLayout = (TextView) v.findViewById(R.id.expand_button);
     TextView collapse = (TextView) v.findViewById(R.id.collapse_button);
     //mLayout.setVisibility(v.GONE);
     if (mLayout.isShown()){
    	 mLayout.setVisibility(v.INVISIBLE);
     	 collapse.setVisibility(v.VISIBLE);
     }
     else
     {
    	 mLayout.setVisibility(v.VISIBLE);
    	 collapse.setVisibility(v.INVISIBLE);
     }
    
     
  }


  
  
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
				    
				    
				    Results preFullyParsed = gson.fromJson(response.body().charStream(), Results.class);
					String text = preFullyParsed.results;
					
				    Workout parsedjWorkout = gson.fromJson(text, Workout.class);
				   
				    Log.d("preFullyParsed", text);
				    return parsedjWorkout;
				    
				} catch (IOException e) {
					Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
					return null;
				}
			}
			
			@Override
			protected void onPostExecute(Workout result) {
				Log.d(DEBUG_TAG,"execute");
				
				//set result to show on screen
				
			  
			    setListAdapter(new WorkoutAdapter(result, getActivity()));		
			  
			    
			}
			  
		  }


  
  
} 