package com.example.newtest;



import java.io.IOException;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.ListFragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.example.newtest.CalendarActivity.AsyncServiceCall;
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
	private AlertDialog alertDialog;
	private  SwipeRefreshLayout swipeLayout;
	private static AsyncWorkoutCall asyncTask;
	public WorkoutAdapter workoutAdapter;
	public WorkoutAsyncResponse delegate;
	
	public static void backButtonWasPressed() {
		
        Log.d("HI","Passed");
        asyncTask.cancel(true);
    }

	public void onPause(){
		super.onPause();
		asyncTask.cancel(true);
	}
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		Log.d("Created","Workout Fragment");
		View rootView = inflater.inflate(R.layout.fragment_workout_view, container,
				false);
    //Alert Box if no connectivity
    alertDialog = new AlertDialog.Builder(getActivity()).create();
	alertDialog.setTitle("No Internet Connectivity");
	alertDialog.setMessage("Please connect to the internet and reopen application.");
	alertDialog.setIcon(R.drawable.trac_launcher);
	alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
		public void onClick(DialogInterface dialog, int which) {
		// here you can add functions
		}
		});
    
    
    // 1. get passed intent 
		Intent intent = getActivity().getIntent();
		
     // 2. get message value from intent
     final String message = intent.getStringExtra("message");
     Log.d("The passed Variable Workout Fragment", message);
   
     //pull to refresh initialized and async called when pulled
     swipeLayout = (SwipeRefreshLayout) rootView.findViewById(R.id.swipe_container);
	    swipeLayout.setColorScheme(android.R.color.holo_blue_dark, android.R.color.holo_blue_light, android.R.color.holo_green_light, android.R.color.holo_green_light);
	    swipeLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                swipeLayout.setRefreshing(true);
                Log.d("Swipe", "Refreshing Number");
                asyncTask = (AsyncWorkoutCall) new AsyncWorkoutCall().execute(message);
                ( new Handler()).postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        swipeLayout.setRefreshing(false);
                        Log.d("Refresh","REfresh");
                        //new AsyncServiceCall().execute(url);
                    }
                }, 3000);
            }
	    
        });
     
     
     
	    asyncTask = (AsyncWorkoutCall) new AsyncWorkoutCall().execute(message);
    
         return rootView;
    
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
     
     //For directional arrows up and down, when clicked, change direction
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
	
	  private class AsyncWorkoutCall extends AsyncTask<String, Void, Workout> {
		  
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
				
				if(result==null){
					alertDialog.show();
				}
				else
				{
				//set result to show on screen
				
				workoutAdapter = new WorkoutAdapter(result, getActivity());
			    setListAdapter(workoutAdapter);		
			    delegate.processFinish(workoutAdapter);
				}
			    
			}
			  
		  }


  
  
} 