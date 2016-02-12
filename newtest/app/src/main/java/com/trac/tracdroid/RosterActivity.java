package com.trac.tracdroid;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.CancellationException;
import java.util.concurrent.ExecutionException;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ListActivity;
import android.app.SearchManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.text.InputType;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AbsListView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.TextView;
import android.widget.AbsListView.OnScrollListener;

import com.trac.showcaseview.ShowcaseView;
import com.trac.showcaseview.targets.ActionItemTarget;
import com.trac.tracdroid.R;
import com.trac.tracdroid.CalendarActivity.AsyncServiceCall;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;
import com.amplitude.api.Amplitude;

public class RosterActivity extends ListActivity implements StringAsyncResponse, BooleanAsyncResponse, CreateTeamCallback{
	//protected Context context;
	private String access_token;
	private ArrayList<Results> positionArray;
	private View mLoginStatusView;
	private AlertDialog alertDialog;
	private  SwipeRefreshLayout swipeLayout;
	private String url;
	private AsyncServiceCall asyncCall;
	public RosterAdapter var;
	private boolean executing = false;
	private OnScrollListener scrollListener;
    protected TextView firstVisibleItemText;
    protected TextView visibleItemCountText;
    protected TextView totalItemCountText;
    private ListView list;
    public boolean asyncExecuted = false;
    private int nextFifteen;
    int fakedTotalItemCount = 16;
    int maxTotalSessions;
	private String urlID;
	private String m_Text = "";
	private String primaryTeam;
	private CreateAthleteAsyncTask splitCall;
	private boolean editStatus;
	public Boolean asyncStatus;
	private CreateTeam teamCreateAsync;


	public void onPause(){
		super.onPause();
		   asyncCall.cancel(true);
	}
	  
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		//This controls the OnText Change Listener and Inflates it

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.rostermenu, menu);

	    // Get the SearchView and set the searchable configuration
	    SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
	    SearchView searchView = (SearchView) menu.findItem(R.id.action_searchroster).getActionView();
	    // Assumes current activity is the searchable activity
	    searchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));
	    searchView.setIconifiedByDefault(false);
	    
	    // Do not iconify the widget; expand it by default

        SearchView.OnQueryTextListener textChangeListener = new SearchView.OnQueryTextListener()
        {
            @Override
            public boolean onQueryTextChange(String newText)
            {
            	Amplitude.getInstance().logEvent("RosterActivity_SearchUsed");
                try{// this is your adapter that will be filtered
                	System.out.println("on text chnge text: "+newText);
                	((RosterAdapter) getListAdapter()).getFilter(newText);
                
                return true;
                }
                catch(Exception e){
                	System.out.println("Error " + e.getMessage());
                	Log.d("early","finally");
                	return true;
                	}
            }
            @Override
            public boolean onQueryTextSubmit(String query)
            {
                try{// this is your adapter that will be filtered
                	((CalendarAdapter)getListAdapter()).getFilter(query);
                	System.out.println("on query submit: "+query);
                	return true;
                }
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
		
		//If signout clicked, check for token in Shard Preferences and override
		//Bring to LoginActivity.class then clear the stack of previous pages.
		if (id == R.id.action_signout) {
			SharedPreferences pref = getSharedPreferences("userdetails", MODE_PRIVATE);
			Editor edit = pref.edit();
			edit.putString("token", "");
			edit.commit();

			//go to login page
			Intent i = new Intent(RosterActivity.this, LoginActivity.class);
			i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(i);
			

		}
		else if(id == R.id.action_addRunner){
			Amplitude.getInstance().logEvent("RosterActivity_AddRunner");
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
		    // Get the layout inflater
		    LayoutInflater inflater = getLayoutInflater();

		    // Inflate and set the layout for the dialog
		    // Pass null as the parent view because its going in the dialog layout
		    builder.setView(inflater.inflate(R.layout.dialog_create, null))
		    // Add action buttons
		           .setPositiveButton(R.string.action_addRunner, new DialogInterface.OnClickListener() {
		               @Override
		               public void onClick(DialogInterface dialog, int id) {
		            	   confirmCreate(dialog);
		               }
		           })
		           .setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
		               public void onClick(DialogInterface dialog, int id) {
		                  dialog.cancel();
		               }
		           });      
		    builder.show();
		}
		else if (id == R.id.action_edit){
			//toggle checks.
			Amplitude.getInstance().logEvent("RosterActivity_ToggleChecks");
			var.changeCheck(editStatus);
			if(editStatus){
        		editStatus = false;
        		LinearLayout footer = (LinearLayout) this.findViewById(R.id.footer);
	            footer.setVisibility(LinearLayout.VISIBLE);
        	}
        	else{
        		editStatus = true;
        		LinearLayout footer = (LinearLayout) this.findViewById(R.id.footer);
	            footer.setVisibility(LinearLayout.GONE);
        	}
        	
			
			
			
		}

		return super.onOptionsItemSelected(item);
	}
	


	public void confirmCreate(DialogInterface dialog){
		EditText name = (EditText) ((Dialog)dialog).findViewById(R.id.name);
 	   String nameString = name.getText().toString();
 	   String[] parts = nameString.split("\\s+");
 	   String last_name;
 	   String first_name;
 	   
 	   if (parts.length == 1){
 		   	first_name = parts[0];
 		    last_name = null;
 	   }
 	   else{
 		   first_name = parts[0];
 		   last_name = parts[1];
 	   }
 	   EditText tagId = (EditText) ((Dialog)dialog).findViewById(R.id.tagID);
 	   String tagIdString = tagId.getText().toString();
 	   dialog.cancel();

    		String createURL = "https://trac-us.appspot.com/api/athletes/?access_token=" + access_token;
    		splitCall = new CreateAthleteAsyncTask(createURL,first_name,last_name,tagIdString,primaryTeam);
    		splitCall.execute();
    		splitCall.delegate = this;
	}

	
	
	 public void onCreate(Bundle savedInstanceState) {
		    super.onCreate(savedInstanceState);
		    //initialize content views
		    setContentView(R.layout.activity_roster);
		    mLoginStatusView = findViewById(R.id.login_status);
		    mLoginStatusView.setVisibility(View.VISIBLE);
		    
		    editStatus = true;
		    //Set Listeners for infinite scroll
		    //listView = (InfiniteScrollListView) this.getListView();
		    list = getListView();
		 //Get token from Shared Preferences and create url endpoint with token inserted
		 	SharedPreferences userDetails = getSharedPreferences("userdetails",MODE_PRIVATE);
		 	access_token = userDetails.getString("token","");
		 	boolean firstRun = userDetails.getBoolean("firstRun",true);
			 if(firstRun) {
				 ShowcaseView.ConfigOptions co = new ShowcaseView.ConfigOptions();
				 co.showcaseId = ShowcaseView.ITEM_ACTION_ITEM;
				 co.hideOnClickOutside = true;
				 ActionItemTarget target = new ActionItemTarget(this, R.id.action_edit);
				 final ShowcaseView sv = ShowcaseView.insertShowcaseView(target, this, R.string.step_four_title, R.string.step_four,co);
				 sv.show();
				 SharedPreferences.Editor editor = userDetails.edit();
				 editor.putBoolean("firstRun", false);
				 editor.commit();
			 }

		    Intent intent = getIntent();
			
	        // 2. get message value from intent
	       urlID = intent.getStringExtra("urlID");

			   
		    //Initialize swipe to refresh layout, what happens when swiped: async task called again
		    swipeLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_container);
		    swipeLayout.setColorScheme(android.R.color.holo_blue_dark, android.R.color.holo_blue_light, android.R.color.holo_green_light, android.R.color.holo_green_light);
	        swipeLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
	            @Override
	            public void onRefresh() {
	                swipeLayout.setRefreshing(true);
	                Log.d("Swipe", "Refreshing Number");
	                asyncExecuted = false;
	                url = "https://trac-us.appspot.com/api/athletes/?primary_team=True&access_token=" + access_token;
	                asyncCall = (AsyncServiceCall) new AsyncServiceCall().execute(url);
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
		    
	        
	        final Button b2 = (Button) findViewById(R.id.registerButton);
		    b2.setOnClickListener( new View.OnClickListener() {
			    public void onClick(View v) {
			    	Amplitude.getInstance().logEvent("RosterActivity_RegisterClicked");
			    	onRegisterClick();
			    }
			  });

	        
		  
		   //When No Internet connection, display alert dialog
		   
	        alertDialog = new AlertDialog.Builder(this).create();
			alertDialog.setTitle("No Internet Connectivity");
			alertDialog.setMessage("Please connect to the internet and reopen application.");
			alertDialog.setIcon(R.drawable.trac_launcher);
			alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
				}});
			
			 url = "https://trac-us.appspot.com/api/athletes/?primary_team=True&access_token=" + access_token;
			//OnCreate Async Task Called, see below for async task class
			asyncCall =  (AsyncServiceCall) new AsyncServiceCall().execute(url);
			
			//Get primary team id to store if you create an athlete.
			String teamURL = "https://trac-us.appspot.com/api/teams/?primary_team=True&access_token=" + access_token;
			RetrievePrimaryTeams asyncTeams = (RetrievePrimaryTeams) new RetrievePrimaryTeams().execute(teamURL);
			asyncTeams.delegate = this;
		  }
	 
	 public void onRegisterClick(){

	    ArrayList<String> checkArray = var.getCheckArrayID();
	    //Log.d("Array has data?2 ??",checkArray.toString());
     	String url = "https://trac-us.appspot.com/api/sessions/"+ urlID +"/register_athletes/?access_token=" + access_token;
     	//http://10.0.2.2:8000/api/individual_splits/?access_token=XQ8JLMtCPznQGSWUep1jX3ES2FWjWX
     	RosterCheckboxAsync checkAsync = new RosterCheckboxAsync(checkArray,url);
     	checkAsync.execute();
     	checkAsync.delegate = this;

     	var.clearCheckboxes();
     	try {
				asyncStatus = checkAsync.get();
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (CancellationException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (ExecutionException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} 
	     	if(asyncStatus != null){
				var.resetCheckArray();
				//groupList.changeBool();
			}
	 }
	 
		public void processComplete(String success) {
			if (success == "Null")
			{
				addTeam();
			}else {
				primaryTeam = success;
			}
		}
	 	public void addTeam(){
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			// Get the layout inflater
			LayoutInflater inflater = getLayoutInflater();
			builder.setView(inflater.inflate(R.layout.dialog_team, null))
					// Add action buttons
					.setPositiveButton(R.string.addTeam, new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int id) {
							createTeam(dialog);
						}
					});
			builder.show();

		}

	public void createTeam(DialogInterface dialog){
		EditText name = (EditText) ((Dialog)dialog).findViewById(R.id.teamname);
		String nameString = name.getText().toString();
		dialog.cancel();

		String createURL = "https://trac-us.appspot.com/api/teams/?access_token=" + access_token;
		teamCreateAsync = new CreateTeam(createURL,nameString);
		teamCreateAsync.execute();
		teamCreateAsync.delegate = this;
	}

		  @Override
		  protected void onListItemClick(ListView l, View v, int position, long id) {
			  super.onListItemClick(l, v, position, id);
		        //Toggle CheckBox from not selected to selected and vice versa.
		        if (v != null) {
		            CheckBox checkBox = (CheckBox) v.findViewById(R.id.rosterCheck);
		            checkBox.setChecked(!checkBox.isChecked());
		        }
		    }
		  
		  OkHttpClient client = new OkHttpClient();
			Gson gson = new Gson();
			private static final String DEBUG_TAG = "Debug";
			
			  public class AsyncServiceCall extends AsyncTask<String, Void, ArrayList<RosterJson>> {
				  
					@Override
					protected ArrayList<RosterJson> doInBackground(String... params) {
						Request request = new Request.Builder()
				        .url(params[0])
				        .build();
						try {
							   Response response = client.newCall(request).execute();

							int responseCode = response.code();

							if (responseCode >= 400) {
								//if bad response, redirect to login
								//go to login page
								Intent i = new Intent(RosterActivity.this, LoginActivity.class);
								i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
								startActivity(i);
							}

							   Log.d("Reponse", response.body().toString());
							   RosterJson[] preFullyParsed = gson.fromJson(response.body().charStream(), RosterJson[].class);
							   System.out.println(preFullyParsed);
							   
							   ArrayList<RosterJson> dataList = new ArrayList<RosterJson>(Arrays.asList(preFullyParsed));

						    return dataList;
						    
						} catch (IOException e) {
							//Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
							return null;
						}
					}
					
					@Override
					protected void onPostExecute(ArrayList<RosterJson> result) {
						//Log.d("Finished", "Calendar Activity");
						
						//If the array/string doesnt come through alert will popup, hide spinner
						
						
						if(result==null){

							Log.d("Crashing Here","Crashing Here");
							alertDialog.show();
							mLoginStatusView.setVisibility(View.GONE);
							// swipeLayout.setRefreshing(false);
						}
						else{
							//else parse the result and put in adapter, hide spinner
							var = new RosterAdapter(result, getApplicationContext());
							setListAdapter(var);

							mLoginStatusView.setVisibility(View.GONE);
							executing = false;
							// swipeLayout.setRefreshing(false);
						}
					}
			  }

			@Override
			public void processFinish(Boolean success) {
				if (success){
					new AlertDialog.Builder(this)
				    .setTitle("Success!")
				    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
				        public void onClick(DialogInterface dialog, int which) { 
		        	
				        }
				    })
				    .setIcon(R.drawable.trac_launcher)
				     .show();

				url = "https://trac-us.appspot.com/api/athletes/?primary_team=True&access_token=" + access_token;
				asyncCall =  (AsyncServiceCall) new AsyncServiceCall().execute(url);
				
				editStatus = true;
        		LinearLayout footer = (LinearLayout) this.findViewById(R.id.footer);
	            footer.setVisibility(LinearLayout.GONE);
				}
			}

	@Override
	public void teamFinish(Boolean success) {
		if (success){
			new AlertDialog.Builder(this)
					.setTitle("Success!")
					.setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
						public void onClick(DialogInterface dialog, int which) {

						}
					})
					.setIcon(R.drawable.trac_launcher)
					.show();

			String teamURL = "https://trac-us.appspot.com/api/teams/?primary_team=True&access_token=" + access_token;
			RetrievePrimaryTeams asyncTeams = (RetrievePrimaryTeams) new RetrievePrimaryTeams().execute(teamURL);
			asyncTeams.delegate = this;

		}
	}
			  

			



			
}

