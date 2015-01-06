package com.example.newtest;
 
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
 
public class SplashScreen extends Activity {
 
    // Splash screen timer, hold 3 seconds
    private static int SPLASH_TIME_OUT = 3000;
    private String access_token;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        
        //check if there is a token
        SharedPreferences userDetails = getSharedPreferences("userdetails",MODE_PRIVATE);
		   access_token = userDetails.getString("token","");
		   Log.d("Access_token, SplashScreen:", access_token);
		   
		  
        
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
      			   //TODO: Check if token is actually valid.
      			   startActivity(new Intent(SplashScreen.this,CalendarActivity.class));
      		   }
 
                // close this activity
              //  finish();
            }
        }, SPLASH_TIME_OUT);
    }
 
}