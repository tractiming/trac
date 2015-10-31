package com.example.newtest;

import java.io.IOException;
import java.util.Locale;

import com.example.newtest.SplashScreen.TokenValidation;
import com.google.gson.Gson;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import android.support.v7.app.ActionBarActivity;
import android.support.v7.app.ActionBar;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.app.FragmentPagerAdapter;
import android.app.AlertDialog;
import android.app.SearchManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SearchView;
import android.widget.TextView;
import android.support.v4.app.ListFragment;

public class MainActivity extends ActionBarActivity implements
		ActionBar.TabListener{

	/**
	 * The {@link android.support.v4.view.PagerAdapter} that will provide
	 * fragments for each of the sections. We use a {@link FragmentPagerAdapter}
	 * derivative, which will keep every loaded fragment in memory. If this
	 * becomes too memory intensive, it may be best to switch to a
	 * {@link android.support.v4.app.FragmentStatePagerAdapter}.
	 */
	SectionsPagerAdapter mSectionsPagerAdapter;

	/**
	 * The {@link ViewPager} that will host the section contents.
	 */
	ViewPager mViewPager;
	private Fragment fragment;
	int check = 0;
	private WorkoutReset mAuthTask = null;
	private static String var; 
	private String access_token;
	private String numID;
	private static String userVariable;
	boolean resultOfComparison;
	GroupFragment groupFrag;
	private GroupAdapter groupAdapter;
	WorkoutFragment workoutFrag;
	private ExpandableWorkoutAdapter workoutAdapter;
	
    public void onBackPressed() {
    	fragment = new Fragment();
    	super.onBackPressed();
			GroupFragment.backButtonWasPressed();
			Log.d("Back","PRESSED");
			WorkoutFragment.backButtonWasPressed();
			Log.d("Back","PRESSED FROM WORKOUT");
    }
    
    public void onPause(){
    	fragment = new Fragment();
    	super.onPause();
			GroupFragment.backButtonWasPressed();
			Log.d("Back","PRESSED");
			WorkoutFragment.backButtonWasPressed();
			Log.d("Back","PRESSED FROM WORKOUT");
    	
    }
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		 SharedPreferences userDetails = getSharedPreferences("userdetails",MODE_PRIVATE);
		   access_token = userDetails.getString("token","");
		   userVariable = userDetails.getString("usertype", "");
		   Log.d("Access_token, MainActivity:", userVariable);
		  
		   resultOfComparison=userVariable.equals("coach");
		// 1. get passed intent 
        Intent intent = getIntent();
 
        // 2. get message--token-- value from intent
        String message = intent.getStringExtra("message");
        Log.d("The passed Variable", message);
        
        numID = intent.getStringExtra("positionID");
        Log.d("The ID Number", numID);
        
        
		// Set up the action bar.
		final ActionBar actionBar = getSupportActionBar();
		actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);

		// Create the adapter that will return a fragment for each of the three
		// primary sections of the activity.
		mSectionsPagerAdapter = new SectionsPagerAdapter(
				getSupportFragmentManager());

		// Set up the ViewPager with the sections adapter.
		mViewPager = (ViewPager) findViewById(R.id.pager);
		mViewPager.setAdapter(mSectionsPagerAdapter);

		// When swiping between different sections, select the corresponding
		// tab. We can also use ActionBar.Tab#select() to do this if we have
		// a reference to the Tab.
		mViewPager
				.setOnPageChangeListener(new ViewPager.SimpleOnPageChangeListener() {
					@Override
					public void onPageSelected(int position) {
						actionBar.setSelectedNavigationItem(position);
					}
				});

		// For each of the sections in the app, add a tab to the action bar.
		for (int i = 0; i < mSectionsPagerAdapter.getCount(); i++) {
			// Create a tab with text corresponding to the page title defined by
			// the adapter. Also specify this Activity object, which implements
			// the TabListener interface, as the callback (listener) for when
			// this tab is selected.
			actionBar.addTab(actionBar.newTab()
					.setText(mSectionsPagerAdapter.getPageTitle(i))
					//.setIcon(R.drawable.log)
					.setTabListener(this));
			
		}


	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		
		// TODO Auto-generated method stub
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.shared_view, menu);
		// Get the SearchView and set the searchable configuration
	    SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
	    SearchView searchView = (SearchView) menu.findItem(R.id.action_search).getActionView();
	    // Assumes current activity is the searchable activity
	    searchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));
	    searchView.setIconifiedByDefault(false);
	    
	    // Do not iconify the widget; expand it by default

	   
        SearchView.OnQueryTextListener textChangeListener = new SearchView.OnQueryTextListener()
        {
            @Override
            public boolean onQueryTextChange(String newText)
            {
                try{// this is your adapter that will be filtered
                groupAdapter.getFilter(newText);
                workoutAdapter.getFilter(newText);
                System.out.println("on text chnge text: "+newText);
                return true;
                }
                finally{
                	Log.d("early","finally");
                	return true;
                	}
            }
            @Override
            public boolean onQueryTextSubmit(String query)
            {
                try{
                //filter the adapter
                groupAdapter.getFilter(query);
                workoutAdapter.getFilter(query);
                System.out.println("on query submit: "+query);
                return true;}
                finally{Log.d("early","finally");
                	return true;}
            }
        };
        searchView.setOnQueryTextListener(textChangeListener);
	    
	    return true;

	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();
		if (id == R.id.action_signout2) {
			fragment = new Fragment();
	    	super.onBackPressed();
				GroupFragment.backButtonWasPressed();
				Log.d("Back","PRESSED");
				WorkoutFragment.backButtonWasPressed();
				Log.d("Back","PRESSED FROM WORKOUT");
			
			//delete token
			SharedPreferences pref = getSharedPreferences("userdetails", MODE_PRIVATE);
			Editor edit = pref.edit();
			edit.putString("token", "");
			edit.commit();
			
			//go to login page
			Intent i = new Intent(MainActivity.this, LoginActivity.class);
			i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK); 
			startActivity(i);
		}
		
//		else if (id == R.id.action_reset)
//		{
//			Log.d("PRESSED BUTTOn","REset");
//			
//			
//			new AlertDialog.Builder(this)
//		    .setTitle("Reset Workout")
//		    .setMessage("Are you sure you want to reset this workout?")
//		    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
//		        public void onClick(DialogInterface dialog, int which) { 
//					mAuthTask = new WorkoutReset();
//					String url = "https://trac-us.appspot.com/api/TimingSessionReset/?access_token=" + access_token;
//					 mAuthTask.execute(url,numID);
//		        }
//		     })
//		    .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
//		        public void onClick(DialogInterface dialog, int which) { 
//		            // do nothing
//		        	Log.d("Do Nothing","Cancel");
//		        }
//		     })
//		    .setIcon(R.drawable.trac_launcher)
//		     .show();			
//		}
//		else if (id == R.id.action_play)
//		{
//			RaceCalibration raceAuth = new RaceCalibration();
//			//Add Delegate If We want this
//			String url = "https://trac-us.appspot.com/api/sessions/"+ numID+"/?access_token="+access_token;
//			String pre_json = "id=1";
//			 raceAuth.execute(url,pre_json);
//			
//		}
//		else if (id == R.id.action_record)
//		{
//			//TODO:HIT START WORKOUT ENDPOINT WHEN SETUP
//			//Log.d("Start","Pressed");
//			//RaceStart raceStart = new RaceStart();
//			//String url = "https://trac-us.appspot.com/api/sessions/"+ numID+"/?access_token="+access_token;
//			//String pre_json = "id=1";
//			//raceStart.execute(url,pre_json);
//		}
//		else if (id == R.id.action_stop)
//		{
//			RaceStop raceStop = new RaceStop();
//			//Add Delagate if we want this
//			String url = "https://trac-us.appspot.com/api/sessions/"+ numID+"/?access_token="+access_token;
//			String pre_json = "id=1";
//			 raceStop.execute(url,pre_json);
//			
//		}
		return super.onOptionsItemSelected(item);
	}

	@Override
	public void onTabSelected(ActionBar.Tab tab,
			FragmentTransaction fragmentTransaction) {
		// When the given tab is selected, switch to the corresponding page in
		// the ViewPager.
		mViewPager.setCurrentItem(tab.getPosition());
	}

	@Override
	public void onTabUnselected(ActionBar.Tab tab,
			FragmentTransaction fragmentTransaction) {
	}

	@Override
	public void onTabReselected(ActionBar.Tab tab,
			FragmentTransaction fragmentTransaction) {
	}

	/**
	 * A {@link FragmentPagerAdapter} that returns a fragment corresponding to
	 * one of the sections/tabs/pages.
	 */
	public class SectionsPagerAdapter extends FragmentPagerAdapter implements GroupAsyncResponse, WorkoutAsyncResponse {

		public SectionsPagerAdapter(FragmentManager fm) {
			super(fm);
		}

		@Override
		public int getCount() {
			// Show 2 total pages.
			if (resultOfComparison){
			return 3;
			}
			else{
				return 2;
			}
		}

		@Override
		public Fragment getItem(int position) {
			check = position;
			// getItem is called to instantiate the fragment for the given page.
			fragment = new Fragment();
			if (resultOfComparison){
			switch(position){
			case 0:
				groupFrag = new GroupFragment();
				groupFrag.delegate = this;
				Bundle args = new Bundle();
			    args.putString("AccessToken",access_token);
			    groupFrag.setArguments(args);
				return groupFrag;
			case 1:
				 workoutFrag = new WorkoutFragment();
				 workoutFrag.delegate = this;
				return workoutFrag;
			case 2:
				return fragment = new SettingsFragment();
			default:
				break;			
		}
			}
			else {
				
				switch(position){
				case 0:
					return fragment = new GroupFragment();
				case 1:
					return fragment = new WorkoutFragment();
				default:
					break;			
			}
				
			}
		return fragment;
		
		}

		@Override
	    public CharSequence getPageTitle(int position) {
	        Locale l = Locale.getDefault();
	        switch (position) {
	        case 0:
	            return getString(R.string.title_section1).toUpperCase(l);
	        case 1:
	            return getString(R.string.title_section2).toUpperCase(l);
	        case 2:
	            return getString(R.string.title_section3).toUpperCase(l);
	        }
	        return null;
	    }

		@Override
		public void processFinish(GroupAdapter groupList) {
			// TODO Auto-generated method stub
			groupAdapter = groupList;
		}

		@Override
		public void processFinish(ExpandableWorkoutAdapter expandableAdapter) {
			// TODO Auto-generated method stub
			workoutAdapter = expandableAdapter;
			
		}
	}


	
	
}
