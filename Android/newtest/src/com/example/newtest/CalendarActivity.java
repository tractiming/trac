package com.example.newtest;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import com.google.gson.reflect.TypeToken;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.app.SearchManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.TextView;
import android.widget.Toast;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;



public class CalendarActivity extends ListActivity implements OnScrollListener{
	//protected Context context;
	private String access_token;
	private ArrayList<Results> positionArray;
	private View mLoginStatusView;
	private AlertDialog alertDialog;
	private  SwipeRefreshLayout swipeLayout;
	private String url;
	private AsyncServiceCall asyncCall;
	public CalendarAdapter var;
	private boolean executing = false;
	private OnScrollListener scrollListener;
    protected TextView firstVisibleItemText;
    protected TextView visibleItemCountText;
    protected TextView totalItemCountText;
    private ListView list;
    public boolean asyncExecuted = false;
    private int nextFifteen;
    int fakedTotalItemCount = 16;
	

	 public void onBackPressed() {
		   asyncCall.cancel(true);
		   Intent intent = new Intent(Intent.ACTION_MAIN);
		   intent.addCategory(Intent.CATEGORY_HOME);
		   intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		   startActivity(intent);

		 }
	public void onPause(){
		super.onPause();
		   asyncCall.cancel(true);
	}
	  
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		//This controls the OnText Change Listener and Inflates it

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);

	    // Get the SearchView and set the searchable configuration
	    SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
	    SearchView searchView = (SearchView) menu.findItem(R.id.action_search2).getActionView();
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
                	((CalendarAdapter)getListAdapter()).getFilter(newText);
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
			asyncCall.cancel(true);
			
			Intent i = new Intent(CalendarActivity.this, LoginActivity.class);
			i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK); 
			startActivity(i);
		}
		else if (id == R.id.create_workout){
			Log.d("Pressed","Create Workout");
			createTask createworkout = new createTask();
			String url = "https://trac-us.appspot.com/api/sessions/?access_token=" + access_token;
			String pre_json = "name=On-The-Run Workout";
			createworkout.execute(url,pre_json);
			String urlSession = "https://trac-us.appspot.com/api/session_Pag/?i1=1&i2=15&access_token=" + access_token;
			asyncExecuted = false;
			asyncCall =  (AsyncServiceCall) new AsyncServiceCall().execute(urlSession);
		}
		return super.onOptionsItemSelected(item);
	}

	
	
	 public void onCreate(Bundle savedInstanceState) {
		    super.onCreate(savedInstanceState);
		    //initialize content views
		    setContentView(R.layout.activity_calendar);
		    mLoginStatusView = findViewById(R.id.login_status);
		    mLoginStatusView.setVisibility(View.VISIBLE);
		    
		    //Set Listeners for infinite scroll
		    //listView = (InfiniteScrollListView) this.getListView();
		    list = getListView();
		    list.setOnScrollListener(this);
		    //scrollListener = new OnScrollListener(this);
		    //listView.setListener(scrollListener);
		    //CalendarAdapter adapter = new CalendarAdapter(result, getApplicationContext());
			//setListAdapter(adapter);
		    
		    
		    //Get token from Shared Preferences and create url endpoint with token inserted
		    SharedPreferences userDetails = getSharedPreferences("userdetails",MODE_PRIVATE);
			   access_token = userDetails.getString("token","");
			   Log.d("Access_token, CalendarActivity:", access_token);
			   
			   
			  
			   
			
			   
		    //Initialize swipe to refresh layout, what happens when swiped: async task called again
		    swipeLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_container);
		    swipeLayout.setColorScheme(android.R.color.holo_blue_dark, android.R.color.holo_blue_light, android.R.color.holo_green_light, android.R.color.holo_green_light);
	        swipeLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
	            @Override
	            public void onRefresh() {
	                swipeLayout.setRefreshing(true);
	                Log.d("Swipe", "Refreshing Number");
	                asyncExecuted = false;
	                url = "https://trac-us.appspot.com/api/session_Pag/?i1=1&i2=15&access_token=" + access_token;
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
		    

	        
		  
		   //When No Internet connection, display alert dialog
		   
	        alertDialog = new AlertDialog.Builder(this).create();
			alertDialog.setTitle("No Internet Connectivity");
			alertDialog.setMessage("Please connect to the internet and reopen application.");
			alertDialog.setIcon(R.drawable.trac_launcher);
			alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
				}});
			
			 url = "https://trac-us.appspot.com/api/session_Pag/?i1=1&i2=15&access_token=" + access_token;
			 // Log.d("URL ! : ", url);
			//OnCreate Async Task Called, see below for async task class
			asyncCall =  (AsyncServiceCall) new AsyncServiceCall().execute(url);
		    
		  }
	 

		  @Override
		  protected void onListItemClick(ListView l, View v, int position, long id) {
			  	// 1. create an intent pass class name or intnet action name 
			  
			  	Log.d("Debug Tag", "THIS IS THE POSITION " + position);
			  	String idPosition = positionArray.get(position).id;
			  	Log.d("Position ID", idPosition);
			  
			  	// On Click, intent to go to main activity from calendar activity
		        Intent intent = new Intent(CalendarActivity.this, MainActivity.class);
		        Log.d("Token On Pass CLICK?", access_token);
		        
		        // 2. put key/value data to pass on mainactivity load
		        intent.putExtra("message", "https://trac-us.appspot.com/api/sessions/" + idPosition +"/?access_token=" + access_token);
		        intent.putExtra("positionID", idPosition);
		        intent.putExtra("token", access_token);

		        // 3. or you can add data to a bundle
		        Bundle extras = new Bundle();
		        extras.putString("status", "Data Received!");
		 
		        // 4. add bundle to intent
		        intent.putExtras(extras);
		 
		        
		        startActivity(intent);
		  }
		  
		  OkHttpClient client = new OkHttpClient();
			Gson gson = new Gson();
			private static final String DEBUG_TAG = "Debug";
			
			  public class AsyncServiceCall extends AsyncTask<String, Void, ArrayList<Results>> {
				  
				  @Override
				  protected void onPreExecute(){
					  Log.d("On Pre Execute", "Calendar Activity");
					 //mLoginStatusView.setVisibility(View.VISIBLE);
					  //swipeLayout.setRefreshing(true);
					  
				  }
				  
					@Override
					protected ArrayList<Results> doInBackground(String... params) {
						Request request = new Request.Builder()
				        .url(params[0])
				        .build();
						try {
							   Response response = client.newCall(request).execute();
							  // JsonParser parser = new JsonParser();
							  // Results preFullyParsed = gson.fromJson(response.body().charStream(), Results.class);
								//String text = preFullyParsed.results;
							   
							   //Type collectionType = new TypeToken<Collection<Results>>(){}.getType();
							   
							   
							   
							   //Parse each entry in json array and add to new array
							   JsonParser parser = new JsonParser();
							    JsonArray jArray = parser.parse(response.body().charStream()).getAsJsonArray();

							    ArrayList<Results> lcs = new ArrayList<Results>();

							    for(JsonElement obj : jArray )
							    {
							        Results cse = gson.fromJson( obj , Results.class);
							        lcs.add(cse);
							        //Log.d("ID NUMBA!",cse.id);
							    }
							   
							   // Log.d("ID NUmbers", cse.name);
							   Log.d("Array", lcs.toString());
							 //Reverse calendar array
							   Collections.reverse(lcs);
						    return lcs;
						    
						} catch (IOException e) {
							//Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
							return null;
						}
					}
					
					@Override
					protected void onPostExecute(ArrayList<Results> result) {
						//Log.d("Finished", "Calendar Activity");
						
						//If the array/string doesnt come through alert will popup, hide spinner
						
						
						if(result==null){
							alertDialog.show();
							mLoginStatusView.setVisibility(View.GONE);
							// swipeLayout.setRefreshing(false);
						}
						else{
							//else parse the result and put in adapter, hide spinner
							var = new CalendarAdapter(result, getApplicationContext());
							if(asyncExecuted == false ){
								//Log.d("First","Execution");
								setListAdapter(var);
								asyncExecuted = true;
								positionArray = result;
							    fakedTotalItemCount = 16;
							}
							else{
								//Log.d("Add","Second...Work?");
								//positionArray.addAll(result);
								((CalendarAdapter)getListAdapter()).add(result);
								//((CalendarAdapter)getListAdapter()).getCount();
								//((CalendarAdapter)getListAdapter()).notifyDataSetChanged();
							
						}
						

						
						mLoginStatusView.setVisibility(View.GONE);
						executing = false;
						// swipeLayout.setRefreshing(false);
						}
					}
			  }

			  

			@Override
			public void onScrollStateChanged(AbsListView view, int scrollState) {
				Log.d("State Change","StateChange");
				int totalItemCount = view.getCount();
				
				
				Log.d("Total Item Count",Integer.toString(fakedTotalItemCount));
				nextFifteen = fakedTotalItemCount + 15; 
				Log.d("Next 15",Integer.toString(nextFifteen));
				
				System.out.println("onScroll");
				//Log.d("State Change","on Scroll");
				if (executing == false){
					executing = true;
					String url2 = "https://trac-us.appspot.com/api/session_Pag/?i1="+Integer.toString(fakedTotalItemCount)+"&i2="+Integer.toString(nextFifteen)+"&access_token=" + access_token;
					fakedTotalItemCount = fakedTotalItemCount + 16;
					Log.d("Dynamic URL",url2);
					asyncCall =  (AsyncServiceCall) new AsyncServiceCall().execute(url2);
					
					
				}
				else if (executing == true){
					Log.d("Dont fire again","Don't fire again");
					
				}
				
				
			}
			@Override
			public void onScroll(AbsListView view, int firstVisibleItem,
					int visibleItemCount, int totalItemCount) {
				
				//System.out.println("onScrollStateChanged");
				//Log.d("on Scroll","on Scroll");
				
				
				 if (totalItemCount - (firstVisibleItem + 1 + visibleItemCount) < 2 &&
			                visibleItemCount < totalItemCount) {
					//Log.d("First",Integer.toString(firstVisibleItem));
					//Log.d("Visible Count",Integer.toString(visibleItemCount));
					//Log.d("Total Count",Integer.toString(totalItemCount)); 
					//know when on bottom of page and append from here.
					
					
					//TODO: Get Search working again
					//url = "https://trac-us.appspot.com/api/session_Pag/?i1="+Integer.toString(totalItemCount)+"&i2="+Integer.toString(nextFifteen)+"&access_token=" + access_token;
					//Log.d("Dynamic URL",url);
					//asyncCall =  (AsyncServiceCall) new AsyncServiceCall().execute(url);

			        }

			        // Item visibility code
			        //listener.onScrollCalled(firstVisibleItem, visibleItemCount, totalItemCount);
				
			}
			



			
}
