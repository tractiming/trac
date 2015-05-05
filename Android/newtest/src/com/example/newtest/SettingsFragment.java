package com.example.newtest;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.google.gson.Gson;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.res.Resources;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;

public class SettingsFragment extends ListFragment implements BooleanAsyncResponse{
    private List<ListViewItem> mItems;        // ListView items list
    private String access_token;
    private String positionID;
    private String message;
    private String name;
    private String start_date;
    private String end_date;
    private String rest_time;
    private String track_size;
    private String interval_distance;
    private String interval_number;
    private String filter_choice;
    RaceCalibration raceAuth;
    RaceStop raceStop;
    RaceStart raceGo;
    private Boolean successVariable;

    
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	Log.d("Created","Settings Fragment");
        super.onCreate(savedInstanceState);
        //GroupFragment.backButtonWasPressed();
		//WorkoutFragment.backButtonWasPressed();
        	// 1. get passed intent from MainActivity
     		Intent intent = getActivity().getIntent();
     		
             // 2. get message value from intent
             positionID = intent.getStringExtra("positionID");
             Log.d("The passed Variable in frag baby", positionID);
             access_token = intent.getStringExtra("token");
             Log.d("The passed Variable in frag baby", access_token);
             message = intent.getStringExtra("message");
             ParseData parseData = new ParseData();
             parseData.execute(message);
             
             
        // initialize the items list
        mItems = new ArrayList<ListViewItem>();
        Resources resources = getResources();
        
        mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_play_dark), getString(R.string.play), getString(R.string.calibrate_description)));
        mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_play_over_video_dark), getString(R.string.record), getString(R.string.start_description)));
        mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_stop_dark), getString(R.string.action_stop), getString(R.string.stop_description)));
        mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_discard_dark), getString(R.string.action_reset), getString(R.string.reset_description)));
        mItems.add(new ListViewItem(resources.getDrawable(R.drawable.trac_launcher_small), getString(R.string.action_signout), getString(R.string.logout_description)));

        
        // initialize and set the list adapter
        setListAdapter(new SettingsAdapter(getActivity(), mItems));
       
    }
    

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // remove the dividers from the ListView of the ListFragment
        getListView().setDivider(null);
    }
 
    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        // retrieve theListView item
        ListViewItem item = mItems.get(position);
        
        if (position == 0){
        	//Calibrate start, start:now, finish:today+1day
        	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        	String currentDateandTime = sdf.format(new Date());
        	Log.d("Date", currentDateandTime);
        	
        	String tomorrowDate = sdf.format(new Date(System.currentTimeMillis() + 86400000));
        	Log.d("Date", tomorrowDate);
        	
        	raceAuth = new RaceCalibration();
        	raceAuth.delegate = this;
			String url = "https://trac-us.appspot.com/api/sessions/"+ positionID+"/?access_token="+access_token;
			String pre_json = "id=" + positionID + "&name="+name+"&start_time="+currentDateandTime+"&stop_time="+tomorrowDate+"&rest_time="+rest_time+"&track_size="+track_size+"&interval_distance="+interval_distance+"&interval_number="+interval_number+"&filter_choice="+filter_choice;
			 raceAuth.execute(url,pre_json);
			 
			 //Update Data
			 ParseData parseData = new ParseData();
             parseData.execute(message);
        }
        else if (position == 1){
        	//TODO: Go Button. When endpoint made, hit it!
        	raceGo = new RaceStart();
        	raceGo.delegate = this;
        	String url = "https://trac-us.appspot.com/api/start_timer/?access_token=" + access_token;
        	String pre_json = "id="+positionID;
        	raceGo.execute(url,pre_json);
        	
        }
        else if (position == 2){
        	//End Workout, finish:now
        	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        	String currentDateandTime = sdf.format(new Date());
        	Log.d("Date", currentDateandTime);
        	
			raceStop = new RaceStop();
			raceStop.delegate = this;
			String url = "https://trac-us.appspot.com/api/sessions/"+ positionID+"/?access_token="+access_token;
			String pre_json = "id=" + positionID + "&name="+name+"&start_time="+start_date+"&stop_time="+currentDateandTime+"&rest_time="+rest_time+"&track_size="+track_size+"&interval_distance="+interval_distance+"&interval_number="+interval_number+"&filter_choice="+filter_choice;
			 raceStop.execute(url,pre_json);
			 //Update Data
			 ParseData parseData = new ParseData();
             parseData.execute(message);
        	
        }
        else if (position == 3){
        	//Reset Button
        	new AlertDialog.Builder(getActivity())
		    .setTitle("Reset Workout")
		    .setMessage("Are you sure you want to reset this workout?")
		    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
		        public void onClick(DialogInterface dialog, int which) { 
        	WorkoutReset raceReset = new WorkoutReset();
        	String url = "https://trac-us.appspot.com/api/TimingSessionReset/?access_token=" + access_token;
        	String id_number = positionID;
        	raceReset.execute(url,id_number);
		        }
		    })
		    .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
		        public void onClick(DialogInterface dialog, int which) { 
		            // do nothing
		        	Log.d("Do Nothing","Cancel");
		        }
		     })
		    .setIcon(R.drawable.trac_launcher)
		     .show();
        }
        else if (position == 4){
        	//Logout Button
        	SharedPreferences pref = this.getActivity().getSharedPreferences("userdetails", Context.MODE_PRIVATE);
			Editor edit = pref.edit();
			edit.putString("token", "");
			edit.commit();
			
			GroupFragment.backButtonWasPressed();
			Log.d("Back","PRESSED");
			WorkoutFragment.backButtonWasPressed();
			
			Intent i = new Intent(getActivity(), LoginActivity.class);
			i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK); 
			startActivity(i);
        	
        }
        // do something
       // Toast.makeText(getActivity(), item.title, Toast.LENGTH_SHORT).show();
    }
    
    public class ParseData extends AsyncTask<String, Void, Results> {
    	private static final String DEBUG_TAG = "Token Check";

    		OkHttpClient client = new OkHttpClient();
    		Gson gson = new Gson();
    	@Override
    	protected Results doInBackground(String... params) {
    		Request request = new Request.Builder()
            .url(params[0])
            .build();
    		try {
    			Log.d(DEBUG_TAG, "Pre Response");
    		    Response response = client.newCall(request).execute();
    		    Log.d(DEBUG_TAG, "Post Response");
    		    Results preFullyParsed = gson.fromJson(response.body().charStream(), Results.class);

    		    
    		    	
    		    Log.d(DEBUG_TAG, "GSON");
    		    return preFullyParsed;
    		    
    		} catch (IOException e) {
    			Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
    			return null;
    		}
    	}

    	protected void onPostExecute(Results results) {
    		

    		if(results==null){
    			return;
    		}
    		else
    		{
    		    name = results.name;
    		    start_date = results.startTime;
    		    end_date = results.stopTime;
    		    rest_time = results.restTime;
    		    track_size = results.tracksize;
    		    interval_distance = results.intervaldist;
    		    interval_number = results.intervalnum;
    		    filter_choice = results.filterchoice;
    			 
    		}

    			 
    		}
    	}

	@Override
	public void processFinish(Boolean success) {
		// TODO Auto-generated method stub
		successVariable =  success;
		if (successVariable){
			new AlertDialog.Builder(getActivity())
		    .setTitle("Success!")
		    .setMessage("Time successfully changed")
		    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
		        public void onClick(DialogInterface dialog, int which) { 
        	
		        }
		    })
		    .setIcon(R.drawable.trac_launcher)
		     .show();
		}
	}

    
    
    
}