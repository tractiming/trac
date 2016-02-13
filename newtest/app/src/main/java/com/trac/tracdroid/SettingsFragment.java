package com.trac.tracdroid;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.res.Resources;
import android.graphics.Point;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.widget.ListView;

import com.amplitude.api.Amplitude;
import com.trac.showcaseview.ShowcaseView;
import com.trac.showcaseview.targets.PointTarget;

import java.util.ArrayList;
import java.util.List;

public class SettingsFragment extends ListFragment implements BooleanAsyncResponse,BooleanWorkoutEndResponse,BooleanStartRace{
    private List<ListViewItem> mItems;        // ListView items list
    private String access_token;
    private String positionID;
    private String message;
    private String name;
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


        // initialize the items list
        mItems = new ArrayList<ListViewItem>();
        Resources resources = getResources();


        mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_search_dark), getString(R.string.view_roster), getString(R.string.view_roster_description)));
		mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_play_over_video_dark), getString(R.string.record), getString(R.string.start_description)));
		mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_discard_dark), getString(R.string.action_reset), getString(R.string.reset_description)));
        mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_play_dark), getString(R.string.play), getString(R.string.calibrate_description)));
        mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_stop_dark), getString(R.string.action_stop), getString(R.string.stop_description)));
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
        	Amplitude.getInstance().logEvent("SettingsFragment_to_Roster");
        	//Calibrate start, start:now, finish:today+1day
        	Log.d("Going to new view","New Settings");
			Intent i = new Intent(getActivity(), RosterActivity.class);
			i.putExtra("urlID", positionID);
			i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(i);


        }
        else if (position == 3){
        	Amplitude.getInstance().logEvent("SettingsFragment_Calibrate");
        	//Calibrate start, start:now, finish:today+1day
        	raceAuth = new RaceCalibration();
        	raceAuth.delegate = this;
			String url = "https://trac-us.appspot.com/api/sessions/"+positionID+"/open/?access_token=" + access_token;

			 raceAuth.execute(url);


        }
        else if (position == 1){
        	Amplitude.getInstance().logEvent("SettingsFragment_Start");
        	raceGo = new RaceStart();
        	raceGo.delegate = this;
        	String url = "https://trac-us.appspot.com/api/sessions/"+positionID+"/start_timer/?access_token=" + access_token;
        	raceGo.execute(url);

        }
        else if (position == 4){
        	//End Workout, finish:now
        	Amplitude.getInstance().logEvent("SettingsFragment_End");
			raceStop = new RaceStop();
			raceStop.delegate = this;
			String url = "https://trac-us.appspot.com/api/sessions/"+positionID+"/close/?access_token=" + access_token;
			raceStop.execute(url);


        }
        else if (position == 2){
        	//Reset Button
        	Amplitude.getInstance().logEvent("SettingsFragment_Reset");
        	new AlertDialog.Builder(getActivity())
		    .setTitle("Reset Workout")
		    .setMessage("Are you sure you want to reset this workout?")
		    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
		        public void onClick(DialogInterface dialog, int which) {
        	WorkoutReset raceReset = new WorkoutReset();
        	String url = "https://trac-us.appspot.com/api/sessions/"+positionID+"/reset/?access_token=" + access_token;

        	raceReset.execute(url);
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
        else if (position == 5){
        	//Logout Button
        	Amplitude.getInstance().logEvent("SettingsFragment_to_Logout");
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


	@Override
	public void processFinish(Boolean success) {
		// TODO Auto-generated method stub
		successVariable =  success;
		if (successVariable){
			new AlertDialog.Builder(getActivity())
		    .setTitle("Success!")
		    .setMessage("Time successfully changed. Athletes are now editable.")
		    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
		        public void onClick(DialogInterface dialog, int which) {

		        }
		    })
		    .setIcon(R.drawable.trac_launcher)
		     .show();
		}
		else {
				//if bad response, redirect to login
				//go to login page
				Intent i = new Intent(getActivity(), LoginActivity.class);
				i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
				startActivity(i);

		}
	}

	@Override
	public void workoutEnded(Boolean success) {
		// TODO Auto-generated method stub
		successVariable =  success;
		if (successVariable){
			new AlertDialog.Builder(getActivity())
					.setTitle("Success!")
					.setMessage("Workout ended. Athletes' splits cannot be edited.")
					.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
						public void onClick(DialogInterface dialog, int which) {

						}
					})
					.setIcon(R.drawable.trac_launcher)
					.show();
		}
		else {
			//if bad response, redirect to login
			//go to login page
			Intent i = new Intent(getActivity(), LoginActivity.class);
			i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(i);

		}
	}

	@Override
	public void booleanstartRace(Boolean success) {
		// TODO Auto-generated method stub
		successVariable =  success;
		if (successVariable){
			new AlertDialog.Builder(getActivity())
					.setTitle("Success!")
					.setMessage("Race started. All runners will be given a single start time.")
					.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
						public void onClick(DialogInterface dialog, int which) {

						}
					})
					.setIcon(R.drawable.trac_launcher)
					.show();
		}
		else {
			//if bad response, redirect to login
			//go to login page
			Intent i = new Intent(getActivity(), LoginActivity.class);
			i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(i);

		}
	}

    
    
}