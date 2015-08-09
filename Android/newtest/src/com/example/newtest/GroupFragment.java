package com.example.newtest;



import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Parcelable;
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


public class GroupFragment extends ListFragment {
	
	
	private ChronometerSubs mChronometer;
	private ListView labels;
	View detailListHeader;
	View detailListHeader2;
	View detailListHeader3;
	public ListView lview;
	private String message;
	//private final static int INTERVAL = 1000; //runs every 2 minutes
	//private Handler mHandler;
	private View mLoginStatusView;
	public static Timer timer;
	public TimerTask doAsynchronousTask;
	public static AsyncServiceCall asyncServiceCall;
	public static String testvar;
	public static String title;
	public static String date;
	public GroupAdapter groupList;
	public GroupAsyncResponse delegate; 
	
	
	public static void backButtonWasPressed() {
		timer.cancel();
		asyncServiceCall.cancel(true);
        Log.d("HI","Passed");
        testvar = null;
    }

	public void onPause(){
		super.onPause();
		timer.cancel();
		asyncServiceCall.cancel(true);
	}
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		
		//Log.d("Instance State in Group on Create",savedInstanceState.toString());
		View rootView = inflater.inflate(R.layout.fragment_group_view, container,
				false);
        //Inflate ID and Workout Numbers
		mTextView = (TextView) rootView.findViewById(R.id.workout_date_view);
		mTextView1 = (TextView) rootView.findViewById(R.id.workout_id_view);
		
		
		if(testvar != null){
			timer.cancel();
			asyncServiceCall.cancel(true);
			mLoginStatusView = rootView.findViewById(R.id.login_status);
		    mLoginStatusView.setVisibility(View.GONE);
		    mTextView.setText("Date: " + date);
		    mTextView1.setText("Workout ID: " + title);
		    Log.d("Log","Not NULL");

		}
		else{
			testvar = "FragmentCheckCreation";
			Log.d("Test","NONNULL?");
			mLoginStatusView = rootView.findViewById(R.id.login_status);
		    mLoginStatusView.setVisibility(View.VISIBLE);
		}
		
		
		// 1. get passed intent from MainActivity
		Intent intent = getActivity().getIntent();
		
        // 2. get message value from intent
        message = intent.getStringExtra("message");
        title = intent.getStringExtra("workoutName");
        date = intent.getStringExtra("workoutDate");
        Log.d("The passed Variable in frag baby", message);
        

        asyncServiceCall = new AsyncServiceCall();
    	asyncServiceCall.execute(message);
        
		   
		
//Commented out the stopwatch features with buttons to start/stop
//		
//		mChronometer = (ChronometerSubs) rootView.findViewById(R.id.chronometer);
//        //mChronometer.start();        
//		//chronometer = (Chronometer) rootView.findViewById(R.id.chronometer);
//		((Button) rootView.findViewById(R.id.start_button)).setOnClickListener(this);
//        ((Button) rootView.findViewById(R.id.stop_button)).setOnClickListener(this);
//        
//        

		//Inflate Header--gives titles above names and splits
		detailListHeader = rootView.findViewById(R.id.header);
		detailListHeader2 = rootView.findViewById(R.id.header2);
		detailListHeader3 = rootView.findViewById(R.id.header3);
	    

		return rootView;
	}	
	
	public void onResume(){
		super.onResume();
		 timer = new Timer();
		    doAsynchronousTask = new TimerTask() {       
		                public void run() {       
		                    try {
		                    	asyncServiceCall.cancel(true);
		                    	asyncServiceCall = new AsyncServiceCall();
		                        // PerformBackgroundTask this class is the class that extends AsynchTask 
		                    	Log.d("URL:", message);
		                    	//performs async service call on the message--url--passed
		                    	asyncServiceCall.execute(message);
		                    	Log.i(DEBUG_TAG, "counter");
		                    } catch (Exception e) {
		                        // TODO Auto-generated catch block
		                    }
		        }
		    };
		    timer.schedule(doAsynchronousTask, 0, 5000); //execute in every 4.0 seconds
		
		
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
    lview = getListView();
    
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

  
  
  	private final OkHttpClient client = new OkHttpClient();
	Gson gson = new Gson();
	private static final String DEBUG_TAG = "Debug";
	
	  private class AsyncServiceCall extends AsyncTask<String, Void, List<Runners>> {
		  protected void onPreExecute(){
			  Log.d("Async", "PreExcute");
		  }
		  
		  
			@Override
			protected List<Runners> doInBackground(String... params) {
				Request request = new Request.Builder()
		        .url(params[0])
		        .build();
				try {
					//Log.d(DEBUG_TAG, "Pre Response");
				    Response response = client.newCall(request).execute();
				    //Log.d(DEBUG_TAG, "Post Response");
				    IndividualResults preFullyParsed = gson.fromJson(response.body().charStream(), IndividualResults.class);
				    //Log.d(DEBUG_TAG, "Post First Parse");
				    List<Runners> text = preFullyParsed.results;
				    //Log.d(DEBUG_TAG, "Post First Parse");
				   // Log.d(DEBUG_TAG, preFullyParsed.results.toString());
				    
					//Log.d("TEXT",text);
				   // Runners variable = text.toArray()
				   // Runners parsedjWorkout = gson.fromJson(text, Runners.class);
				    
				    Workout test = null;
				    	
				    //Log.d(DEBUG_TAG, parsedjWorkout[1].toString());
				    return text;
				    
				} catch (IOException e) {
					Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
					return null;
				}
			}
			
			@Override
			protected void onPostExecute(List<Runners> result) {
				Log.d(DEBUG_TAG,"execute");
				//String resultstring = result.toString();
				 mLoginStatusView.setVisibility(View.GONE);
				//did not have popup appear if null due to async every 2 seconds being called. Popup will continuously popup then
				if(result==null){
					return;
				}
				else
				{
				//set result to show on screen
				
				Parcelable state = lview.onSaveInstanceState();
				groupList = new GroupAdapter(result, getActivity());
			    setListAdapter(groupList);	
			    
			    mTextView.setText("Workout Name: " + title);
			    mTextView1.setText("Date: " + date.substring(0,10));
			    delegate.processFinish(groupList);
			    lview.onRestoreInstanceState(state);
				}
			}
			  
		  }


  
  
} 