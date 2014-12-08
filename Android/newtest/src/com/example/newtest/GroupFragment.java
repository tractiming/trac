package com.example.newtest;



import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ListView;
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


public class GroupFragment extends ListFragment {
	
	
	private ChronometerSubs mChronometer;
	private ListView labels;
	View detailListHeader;
	View detailListHeader2;
	View detailListHeader3;
	private String message;
	//private final static int INTERVAL = 1000; //runs every 2 minutes
	//private Handler mHandler;
	private View mLoginStatusView;
	

	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.fragment_group_view, container,
				false);
		
		// 1. get passed intent 
		Intent intent = getActivity().getIntent();
		
        // 2. get message value from intent
        message = intent.getStringExtra("message");
        Log.d("The passed Variable in frag baby", message);
        
		
		final Handler handler = new Handler();
		    Timer timer = new Timer();
		    TimerTask doAsynchronousTask = new TimerTask() {       
		        @Override
		        public void run() {
		            handler.post(new Runnable() {
		                public void run() {       
		                    try {
		                    	AsyncServiceCall asyncServiceCall = new AsyncServiceCall();
		                        // PerformBackgroundTask this class is the class that extends AsynchTask 
		                    	Log.d("URL:", message);
		                    	asyncServiceCall.execute(message);
		                    	Log.i(DEBUG_TAG, "counter");
		                    } catch (Exception e) {
		                        // TODO Auto-generated catch block
		                    }
		                }
		            });
		        }
		    };
		    timer.schedule(doAsynchronousTask, 0, 2500); //execute in every 2.5 seconds
		

//		
//		mChronometer = (ChronometerSubs) rootView.findViewById(R.id.chronometer);
//        //mChronometer.start();        
//		//chronometer = (Chronometer) rootView.findViewById(R.id.chronometer);
//		((Button) rootView.findViewById(R.id.start_button)).setOnClickListener(this);
//        ((Button) rootView.findViewById(R.id.stop_button)).setOnClickListener(this);
//        
//        
        //Inflate ID and Workout Numbers
		mTextView = (TextView) rootView.findViewById(R.id.workout_date_view);
		mTextView1 = (TextView) rootView.findViewById(R.id.workout_id_view);
		
		//Inflate Header
		detailListHeader = rootView.findViewById(R.id.header);
		detailListHeader2 = rootView.findViewById(R.id.header2);
		detailListHeader3 = rootView.findViewById(R.id.header3);
		

		return rootView;
	}	
	
/*	@Override
    public void onClick(View v) {
        switch(v.getId()) {
        case R.id.start_button:
        	SimpleDateFormat s = new SimpleDateFormat("yyyy-mm-dd hh:mm:ss");
        	String starttime = s.format(new Date());
               mChronometer.setBase(SystemClock.elapsedRealtime());
               mChronometer.start();
               Log.i(DEBUG_TAG, "start"+ starttime);
               //new AsyncServiceCall().execute("http://76.12.155.219/trac/json/test.json");
               break;
       case R.id.stop_button:
              mChronometer.stop();
              SimpleDateFormat st = new SimpleDateFormat("yyyy-mm-dd hh:mm:ss");
          	String stoptime = st.format(new Date());
              Log.i(DEBUG_TAG, "stop" + stoptime );
              //new AsyncServiceCall().execute("http://76.12.155.219/trac/json/test.json");
              break;
       }
}*/
	
  @Override
  public void onActivityCreated(Bundle savedInstanceState) {
    super.onActivityCreated(savedInstanceState);
    
    //new AsyncServiceCall().execute("http://76.12.155.219/trac/json/test.json");
    
  }
/*
  @Override
  public void onListItemClick(ListView l, View v, int position, long id) {
    //Toast.makeText(getActivity(), ((Runners)l.getItemAtPosition(position)).name + "", Toast.LENGTH_SHORT).show();
	  View toolbar = v.findViewById(R.id.expanded_bar_group);
		 
      // Creating the expand animation for the item
      ExpandAnimation expandAni = new ExpandAnimation(toolbar, 500);

      // Start the animation on the toolbar
     toolbar.startAnimation(expandAni);
  }*/
  private TextView mTextView;
  private TextView mTextView1;

  
  
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
				//String resultstring = result.toString();

				//set result to show on screen
				
			    setListAdapter(new GroupAdapter(result, getActivity()));		
			    mTextView.setText("Date: " + result.date);
			    mTextView1.setText("Workout ID: " + result.id);
			    
			}
			  
		  }


  
  
} 