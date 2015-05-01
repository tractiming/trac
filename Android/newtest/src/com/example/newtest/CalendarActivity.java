package com.example.newtest;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;

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
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.Toast;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;

public class CalendarActivity extends ListActivity{
	//protected Context context;
	private String access_token;
	private ArrayList<Results> positionArray;
	private View mLoginStatusView;
	private AlertDialog alertDialog;
	private  SwipeRefreshLayout swipeLayout;
	private String url;
	private static AsyncServiceCall asyncCall;

	

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

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
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
		return super.onOptionsItemSelected(item);
	}

	
	
	 public void onCreate(Bundle savedInstanceState) {
		    super.onCreate(savedInstanceState);
		    //initialize content views
		    setContentView(R.layout.activity_calendar);
		    mLoginStatusView = findViewById(R.id.login_status);
		    mLoginStatusView.setVisibility(View.VISIBLE);
		    
		    //Get token from Shared Preferences and create url endpoint with token inserted
		    SharedPreferences userDetails = getSharedPreferences("userdetails",MODE_PRIVATE);
			   access_token = userDetails.getString("token","");
			   Log.d("Access_token, CalendarActivity:", access_token);
			   
			   
			   url = "https://trac-us.appspot.com/api/sessions/?access_token=" + access_token;
			   Log.d("URL ! : ", url);
			   
		    //Initialize swipe to refresh layout, what happens when swiped: async task called again
		    swipeLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_container);
		    swipeLayout.setColorScheme(android.R.color.holo_blue_dark, android.R.color.holo_blue_light, android.R.color.holo_green_light, android.R.color.holo_green_light);
	        swipeLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
	            @Override
	            public void onRefresh() {
	                swipeLayout.setRefreshing(true);
	                Log.d("Swipe", "Refreshing Number");
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
				
				}
				});
			
			
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
			private static final String DEBUG_TAG = "griffinSucks";
			
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
							Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
							return null;
						}
					}
					
					@Override
					protected void onPostExecute(ArrayList<Results> result) {
						Log.d("Finished", "Calendar Activity");
						//If the array/string doesnt come through alert will popup, hide spinner
						if(result==null){
							alertDialog.show();
							mLoginStatusView.setVisibility(View.GONE);
							// swipeLayout.setRefreshing(false);
						}
						else{
							//else parse the result and put in adapter, hide spinner
						CalendarAdapter var = new CalendarAdapter(result, getApplicationContext());
						setListAdapter(var);
						positionArray = result;
						mLoginStatusView.setVisibility(View.GONE);
						// swipeLayout.setRefreshing(false);
						}
					}
			  }
}
