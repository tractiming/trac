package com.trac.tracdroid;



import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

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
import android.widget.ExpandableListView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.trac.tracdroid.R;
import com.trac.tracdroid.CalendarActivity.AsyncServiceCall;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
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
	public static AsyncWorkoutCall asyncTask;
	public WorkoutAdapter workoutAdapter;
	public ExpandableWorkoutAdapter expandableAdapter;
	public WorkoutAsyncResponse delegate;
	ExpandableListView expListView;
	List<String> dataHeader;
	HashMap<String, List<String>> listDataChild;
	
	
	public static void backButtonWasPressed() {
		
        //Log.d("HI","Passed");
        asyncTask.cancel(true);
    }

	public void onPause(){
		super.onPause();
		asyncTask.cancel(true);
		
	}
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		//Log.d("Created","Workout Fragment");
		View rootView = inflater.inflate(R.layout.fragment_workout_view, null);
		expListView = (ExpandableListView) rootView.findViewById(android.R.id.list);
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
     //("The passed Variable Workout Fragment", message);
   
     //pull to refresh initialized and async called when pulled
     swipeLayout = (SwipeRefreshLayout) rootView.findViewById(R.id.swipe_container);
	    swipeLayout.setColorScheme(android.R.color.holo_blue_dark, android.R.color.holo_blue_light, android.R.color.holo_green_light, android.R.color.holo_green_light);
	    swipeLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                swipeLayout.setRefreshing(true);
                //("Swipe", "Refreshing Number");
                asyncTask = (AsyncWorkoutCall) new AsyncWorkoutCall().execute(message);
                ( new Handler()).postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        swipeLayout.setRefreshing(false);
                        //Log.d("Refresh","REfresh");
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
//	  View toolbar = v.findViewById(R.id.expanded_bar);
//	 
//      // Creating the expand animation for the item
//      ExpandAnimation expandAni = new ExpandAnimation(toolbar, 500);
//
//      // Start the animation on the toolbar
//     toolbar.startAnimation(expandAni);
//     
//     TextView mLayout = (TextView) v.findViewById(R.id.expand_button);
//     TextView collapse = (TextView) v.findViewById(R.id.collapse_button);
//     
//     //mLayout.setVisibility(v.GONE);
//     
//     //For directional arrows up and down, when clicked, change direction
//     if (mLayout.isShown()){
//    	 mLayout.setVisibility(v.INVISIBLE);
//     	 collapse.setVisibility(v.VISIBLE);
//     }
//     else
//     {
//    	 mLayout.setVisibility(v.VISIBLE);
//    	 collapse.setVisibility(v.INVISIBLE);
// 
//     }
   
  }


  
  
  	OkHttpClient client = new OkHttpClient();
	Gson gson = new Gson();
	public static final String DEBUG_TAG = "griffinSucks";
	
	  public class AsyncWorkoutCall extends AsyncTask<String, Void, List<Runners>> {
		  
			@Override
			protected List<Runners> doInBackground(String... params) {
				Request request = new Request.Builder()
		        .url(params[0])
		        .build();
				try {
				    Response response = client.newCall(request).execute();

					int responseCode = response.code();

					if (responseCode >= 400) {
						//if bad response, redirect to login
						//go to login page
						Intent i = new Intent(getActivity(), LoginActivity.class);
						i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
						startActivity(i);
					}
				    
				    IndividualResults preFullyParsed = gson.fromJson(response.body().charStream(), IndividualResults.class);
				    List<Runners> text = preFullyParsed.results;
					//Log.d("TEXT",text);
				    //Runners parsedjWorkout = gson.fromJson(text, Runners.class);
				    
				    Workout test = null;
				    System.out.println(text);
				    return text;
				    
				} catch (IOException e) {
					//Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
					return null;
				}
			}
			
			@Override
			protected void onPostExecute(List<Runners> result) {
				if(result==null){
					alertDialog.show();
				}
				else
				{
					dataHeader = new ArrayList<String>();
					listDataChild = new HashMap<String, List<String>>();
					for (int i = 0; i < result.size(); i++){
						List<String> tempArray = new ArrayList<String>();
						dataHeader.add(result.get(i).name);
						for (int j = 0; j < result.get(i).interval.size(); j++){
							float temp = Float.parseFloat(result.get(i).interval.get(j)[0]);
							if (temp>90){
								int min = (int) Math.floor(temp/60);
								int sec = (int) (((temp*60)-Math.floor(temp/60)*3600)/60);
								int mili = (int) (temp*100-Math.floor(temp)*100);
								StringBuilder sb = new StringBuilder();
								if (sec < 10)
								{
									
									sb.append(min + ":0" + sec +"." + mili );
								}
								else
								{
									
									sb.append(min + ":" +sec +"."+ mili);
								}
								tempArray.add(sb.toString());
							}
							else{
								tempArray.add(result.get(i).interval.get(j)[0].toString());
							}
							
							
							
							//Log.d("Interval to String", result.get(i).interval.get(j)[0].toString());
						}
						listDataChild.put(dataHeader.get(i), tempArray);
						
					}
				//set result to show on screen
				workoutAdapter = new WorkoutAdapter(result, getActivity());
				expandableAdapter = new ExpandableWorkoutAdapter(result, getActivity(), dataHeader, listDataChild);
				//setListAdapter((ExpandableListAdapter) expandableAdapter);		
				expListView.setAdapter(expandableAdapter);
				
				delegate.processFinish(expandableAdapter);
				}
			    
			}
			  
		  }


  
  
} 