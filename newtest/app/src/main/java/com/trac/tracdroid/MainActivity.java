package com.trac.tracdroid;

import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.widget.SearchView;
import android.util.Log;
import android.view.Display;
import android.view.Menu;
import android.view.MenuItem;
import android.view.ViewConfiguration;
import android.view.WindowManager;
import android.widget.RelativeLayout;

import com.amplitude.api.Amplitude;
import com.trac.showcaseview.ShowcaseView;
import com.trac.showcaseview.targets.PointTarget;

import java.lang.reflect.Field;
import java.util.Locale;

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
			//Log.d("Back","PRESSED");
			WorkoutFragment.backButtonWasPressed();
			//Log.d("Back","PRESSED FROM WORKOUT");
    }

    public void onPause(){
    	fragment = new Fragment();
    	super.onPause();
			GroupFragment.backButtonWasPressed();
			//Log.d("Back","PRESSED");
			WorkoutFragment.backButtonWasPressed();
			//Log.d("Back","PRESSED FROM WORKOUT");

    }

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		try {
			ViewConfiguration config = ViewConfiguration.get(this);
			Field menuKeyField = ViewConfiguration.class.getDeclaredField("sHasPermanentMenuKey");

			if (menuKeyField != null) {
				menuKeyField.setAccessible(true);
				menuKeyField.setBoolean(config, false);
			}
		}
		catch (Exception e) {
			// presumably, not relevant
		}

		Log.d("Does this happen Multi", "Multi?");
		setContentView(R.layout.activity_main);

		 SharedPreferences userDetails = getSharedPreferences("userdetails",MODE_PRIVATE);
		   access_token = userDetails.getString("token","");
		boolean firstRun = userDetails.getBoolean("firstRun",true);
		   //userVariable = userDetails.getString("usertype", "");
		   //Log.d("Access_token, MainActivity:", userVariable);
		if (firstRun) {
			WindowManager wm = (WindowManager) this.getSystemService(Context.WINDOW_SERVICE);
			Display display = wm.getDefaultDisplay();
			Point size = new Point();
			display.getSize(size);
			int width = size.x;
			int frag = (width / 4)*3;
			int height = size.y;

			ShowcaseView.ConfigOptions co = new ShowcaseView.ConfigOptions();
			co.showcaseId = ShowcaseView.ITEM_ACTION_ITEM;
			co.shotType = ShowcaseView.TYPE_ONE_SHOT;
			co.hideOnClickOutside = true;
			PointTarget target = new PointTarget(frag, 250);
			ShowcaseView.insertShowcaseView(target, this, R.string.step_two_title, R.string.step_two, co);
		}

		  // resultOfComparison=userVariable.equals("coach");
		// 1. get passed intent 
        Intent intent = getIntent();

        // 2. get message--token-- value from intent
        String message = intent.getStringExtra("message");
       // Log.d("The passed Variable", message);

        numID = intent.getStringExtra("positionID");
       // Log.d("The ID Number", numID);


		// Set up the action bar.
		final ActionBar actionBar = getSupportActionBar();
		actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);
		getSupportActionBar().setStackedBackgroundDrawable(new ColorDrawable(Color.parseColor("#3577A8")));
		getSupportActionBar().setBackgroundDrawable(new ColorDrawable(Color.parseColor("#3577A8")));
		// Create the adapter that will return a fragment for each of the three
		// primary sections of the activity.
		mSectionsPagerAdapter = new SectionsPagerAdapter(
				getSupportFragmentManager());

		// Set up the ViewPager with the sections adapter.
		mViewPager = (ViewPager) findViewById(R.id.pager);
		mViewPager.setAdapter(mSectionsPagerAdapter);
		mViewPager.setOffscreenPageLimit(2);


		// When swiping between different sections, select the corresponding
		// tab. We can also use ActionBar.Tab#select() to do this if we have
		// a reference to the Tab.2
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
	    // Assumes current activity is the searchable activity
	    SearchView searchView = (SearchView) menu.findItem(R.id.action_search).getActionView();
		searchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));
		getSupportActionBar().setDisplayShowHomeEnabled(true);
		getSupportActionBar().setIcon(R.drawable.trac_launcher);

	    // Do not iconify the widget; expand it by default


        SearchView.OnQueryTextListener textChangeListener = new SearchView.OnQueryTextListener()
        {
            @Override
            public boolean onQueryTextChange(String newText)
            {
            	Amplitude.getInstance().logEvent("MainActivity_Search");
                try{// this is your adapter that will be filtered
                groupAdapter.getFilter(newText);
                workoutAdapter.getFilter(newText);
                //System.out.println("on text chnge text: "+newText);
                return true;
                }
                finally{
                	//Log.d("early","finally");
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
                //System.out.println("on query submit: "+query);
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
			Amplitude.getInstance().logEvent("MainActivity_Logout");
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

//
		return super.onOptionsItemSelected(item);
	}

	@Override
	public void onTabSelected(ActionBar.Tab tab,
							  FragmentTransaction fragmentTransaction) {
		// TODO Auto-generated method stub
		if(tab.getCustomView() == null)
		{

		}
		else{
			RelativeLayout tabLayout = (RelativeLayout) tab.getCustomView();
			tabLayout.setBackgroundResource(R.drawable.tab_indicator_ab_actionbar);
			tab.setCustomView(tabLayout);
		}

		// When the given tab is selected, switch to the corresponding page in
		// the ViewPager.
		Log.d("Fired Here","Fired");
		mViewPager.setCurrentItem(tab.getPosition());
		if (tab.getPosition()==0)
		{
			Log.d("akjdlf", "kjladf");
			mSectionsPagerAdapter.notifyDataSetChanged();


		}
		else if (tab.getPosition() == 1)
		{
			mSectionsPagerAdapter.notifyDataSetChanged();
		}
		else if (tab.getPosition() == 2)
		{
			SharedPreferences userDetails = this.getSharedPreferences("userdetails",Context.MODE_PRIVATE);
			boolean firstRun = userDetails.getBoolean("firstRun",true);

			if(firstRun) {
				WindowManager wm = (WindowManager) this.getSystemService(Context.WINDOW_SERVICE);
				Display display = wm.getDefaultDisplay();
				Point size = new Point();
				display.getSize(size);
				int width = size.x;
				int frag = (width / 4);
				int height = size.y;

				ShowcaseView.ConfigOptions co = new ShowcaseView.ConfigOptions();
				co.showcaseId = ShowcaseView.ITEM_ACTION_ITEM;
				co.shotType = ShowcaseView.TYPE_ONE_SHOT;
				co.hideOnClickOutside = true;
				PointTarget target = new PointTarget(frag, 400);
				ShowcaseView.insertShowcaseView(target, this, R.string.step_three_title, R.string.step_three,co);
			}

		}
	}

	@Override
	public void onTabUnselected(ActionBar.Tab tab,
			FragmentTransaction fragmentTransaction) {
	}

	@Override
	public void onTabReselected(ActionBar.Tab tab,
			FragmentTransaction fragmentTransaction) {
		if (tab.getPosition()==0) {
		}
	}

	/**
	 * A {@link FragmentPagerAdapter} that returns a fragment corresponding to
	 * one of the sections/tabs/pages.
	 */
	public class SectionsPagerAdapter extends FragmentStatePagerAdapter implements GroupAsyncResponse, WorkoutAsyncResponse {

		public SectionsPagerAdapter(FragmentManager fm) {
			super(fm);
		}
		@Override
		public Parcelable saveState()
		{
			return null;
		}

		@Override
		public int getItemPosition(Object object){
			return POSITION_NONE;
		}

		@Override
		public int getCount() {
			// Show 2 total pages.
			return 3;
		}

		@Override
		public Fragment getItem(int position) {
			check = position;
			// getItem is called to instantiate the fragment for the given page.
			fragment = new Fragment();
			switch(position){
			case 0:
				Log.d("Get Item","get item");
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
