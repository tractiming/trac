package com.trac.tracdroid;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.View;
import android.widget.ListView;
import android.widget.Switch;

import com.amplitude.api.Amplitude;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

public class SettingsFragment extends ListFragment implements BooleanAsyncResponse,BooleanWorkoutEndResponse,BooleanStartRace,StartDateInterface{
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
	private Switch mySwitch;
	SettingsAdapter settingsAdapter;
	VerifySensorActive sensorActive;

    @Override
    public void onCreate(Bundle savedInstanceState) {
    	Log.d("Created", "Settings Fragment");
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


		VerifySensorActive sensorActive = new VerifySensorActive();
		sensorActive.delegate = this;
		String url = "https://trac-us.appspot.com/api/sessions/"+positionID+"/?access_token=" + access_token;
		sensorActive.execute(url);


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
        else if (position == 1){
        	Amplitude.getInstance().logEvent("SettingsFragment_Start");
        	raceGo = new RaceStart();
        	raceGo.delegate = this;
        	String url = "https://trac-us.appspot.com/api/sessions/"+positionID+"/start_timer/?access_token=" + access_token;
        	raceGo.execute(url);

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

					ArrayList<String> tempTimes = null;
					ArrayList<String> tempResets = null;
					ArrayList<String> tempIDs = null;
					System.out.println("SAVING IN : timeArray:"+tempTimes+"Resets"+ tempResets+"IDs"+tempIDs);
					String tempTimesString = "tempTimes-"+positionID;
					String tempResetsString = "tempResets-"+positionID;
					String tempIDsString = "tempIDs-"+positionID;
					try {
						InternalStorage.writeObject(getContext(), tempTimesString, tempTimes);
						InternalStorage.writeObject(getContext(), tempResetsString, tempResets);
						InternalStorage.writeObject(getContext(), tempIDsString, tempIDs);

					}
					catch(IOException e){

					}




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
	public void processFinish(Results result){
		// initialize the items list
		mItems = new ArrayList<ListViewItem>();
		Resources resources = getResources();


		mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_search_dark), getString(R.string.view_roster), getString(R.string.view_roster_description), null, Boolean.FALSE));
		mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_play_over_video_dark), getString(R.string.record), getString(R.string.start_description), null, Boolean.FALSE));
		mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_discard_dark), getString(R.string.action_reset), getString(R.string.reset_description), null, Boolean.FALSE));


		String start = result.startTime;
		String end = result.stopTime;
		List readers = result.readers;
		System.out.println("Start Time " + result.startTime);
		System.out.println("Stop Time  " + result.stopTime);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
		sdf.setTimeZone(TimeZone.getTimeZone("Etc/UTC"));
		Date startdate = null;
		Date enddate = null;
		long startmilli = 0L;
		long endmilli = 0L;
		try {
			startdate = sdf.parse(start);
			enddate = sdf.parse(end);
			startmilli = startdate.getTime();
			endmilli = enddate.getTime();

		} catch (ParseException e) {
			e.printStackTrace();
		} catch (NullPointerException e)
		{
			System.out.println("Null Value");
		}
		long currentTime = System.currentTimeMillis();

		if(readers.size() == 0 || readers == null){
			//disable switch
			System.out.println("Disable");
			mItems.add(new ListViewItem(null, "Sensor is Off", "For this Workout", null, Boolean.TRUE));
		}
		else if (currentTime > startmilli && endmilli > currentTime){
			//enable switch to on
			System.out.println("ON");
			mItems.add(new ListViewItem(null, "Sensor is Off", "For this Workout", Boolean.TRUE, Boolean.TRUE));
		}
		else{
			//enable switch, and turn off.
			System.out.println("Off");
			mItems.add(new ListViewItem(null, "Sensor is Off", "For this Workout", Boolean.FALSE, Boolean.TRUE));
		}




		//mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_play_dark), getString(R.string.play), getString(R.string.calibrate_description), null, Boolean.FALSE));
		//mItems.add(new ListViewItem(resources.getDrawable(R.drawable.ic_action_stop_dark), getString(R.string.action_stop), getString(R.string.stop_description), null, Boolean.FALSE));
		mItems.add(new ListViewItem(resources.getDrawable(R.drawable.trac_launcher_small), getString(R.string.action_signout), getString(R.string.logout_description), null, Boolean.FALSE));



		// initialize and set the list adapter
		settingsAdapter = new SettingsAdapter(getActivity(), mItems);
		setListAdapter(settingsAdapter);
		settingsAdapter.passToken(access_token,positionID);

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