package com.trac.tracdroid;
 
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import com.amplitude.api.Amplitude;
import com.google.gson.Gson;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import java.io.IOException;
 
public class SplashScreen extends Activity {
 
    // Splash screen timer, hold 3 seconds
    private static int SPLASH_TIME_OUT = 3000;
    private String access_token;
	private static String var; 
	private TokenValidation mAuthTask = null;
	private AlertDialog alertDialog ;

    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
		Amplitude.getInstance().initialize(this, "5ff966491ad403914c656a3da163d2f4").enableForegroundTracking(getApplication());
		Amplitude.getInstance().trackSessionEvents(true);
        //check if there is a token
        SharedPreferences userDetails = getSharedPreferences("userdetails",MODE_PRIVATE);
		   access_token = userDetails.getString("token","");
		   Log.d("Access_token, SplashScreen:", access_token);
		   
			//create alert box if no internet
			alertDialog = new AlertDialog.Builder(this).create();
			alertDialog.setTitle("No Internet Connectivity");
			alertDialog.setMessage("Please connect to the internet and try again.");
			alertDialog.setIcon(R.drawable.trac_launcher);
			alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
				
				}
				});
		   
		  
        
        new Handler().postDelayed(new Runnable() {
 
            /*
             * Showing splash screen with a timer. 
             */
 
            @Override
            public void run() {
                // This method will be executed once the timer is over
                // Start your app main activity
            	//if token is blank go to login, else go to calendaractivity
            	 if(access_token == "")
      		   {
      			 Intent i = new Intent(SplashScreen.this, LoginActivity.class);
                 startActivity(i);
                 //startActivity(new Intent(SplashScreen.this,LoginActivity.class));
      		   }
      		   else
      		   {
      			   //Check if token is actually valid.If it is go to 
      			   //startActivity(new Intent(SplashScreen.this,CalendarActivity.class));
      			 mAuthTask = new TokenValidation();
      			 
     			 mAuthTask.execute("https://trac-us.appspot.com/api/verifyLogin/?token="+access_token);
      		   }
 
                // close this activity
              //  finish();
            }
        }, SPLASH_TIME_OUT);
    }
    
    
    
	OkHttpClient client = new OkHttpClient();
	Gson gson = new Gson();
	
	private static final String DEBUG_TAG = "Token Check";
	  public static final MediaType JSON = MediaType.parse("application/x-www-form-urlencoded; charset=utf-8");
	
	public class TokenValidation extends AsyncTask<String, Void, Boolean> {
		@Override
		protected Boolean doInBackground(String... params) {
			// Attempt authentication against a network service.
			
			
			
			Request request = new Request.Builder()
	        .url(params[0])
	        .get()
	        .build();
			
			//Log.d(DEBUG_TAG, "Request Data: "+ request);
			try {
			    Response response = client.newCall(request).execute();
			   // Log.d(DEBUG_TAG, "Response Data: "+ response);
			    
			    int codevar = response.code();
			   // Log.d(DEBUG_TAG, "Response Code: "+ codevar);

			   // Log.d(DEBUG_TAG, "Request Data: "+ request);
			    var = response.body().string();
			    
			   // Log.d(DEBUG_TAG, "VAR: "+ var);
			    
			    if (codevar == 200) {
			    return true;
			    }
			    else {
			    }
			    
			} catch (IOException e) {
				//Log.d(DEBUG_TAG, "IoException" + e.getMessage());
				return false;
			}

		}

		@Override
		protected void onPostExecute(final Boolean success) {
			mAuthTask = null;

			if (success == null){
				alertDialog.show();
			}
			else if (success) {
				//go to calendar page
				//Log.d("HE","WORK");
				 Intent intent = new Intent(SplashScreen.this, CalendarActivity.class);
				 startActivity(intent);
			} else {
				//It it doesnt work segue to login page
				//Log.d("NOPE","NO WORK");
				Intent intent = new Intent(SplashScreen.this, LoginActivity.class);
				 startActivity(intent);
				 
			}
		}

		@Override
		protected void onCancelled() {
			mAuthTask = null;

		}
	}
    
	
	
    
    
    
}

