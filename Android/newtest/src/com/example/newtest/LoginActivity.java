package com.example.newtest;

import java.io.IOException;

import org.apache.http.HttpResponse;

import com.google.gson.Gson;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.TextView;

/**
 * Activity which displays a login screen to the user, offering registration as
 * well.
 */
public class LoginActivity extends Activity {
	
	// private static Context context;
	
	private static String var; 
	/**
	 * A dummy authentication store containing known user names and passwords.
	 * TODO: remove after connecting to a real authentication system.
	 */
	private static final String[] DUMMY_CREDENTIALS = new String[] {
			"foo@example.com:hello", "bar@example.com:world" };

	/**
	 * The default email to populate the email field with.
	 */
	public static final String EXTRA_EMAIL = "com.example.android.authenticatordemo.extra.EMAIL";

	/**
	 * Keep track of the login task to ensure we can cancel it if requested.
	 */
	private UserLoginTask mAuthTask = null;

	// Values for email and password at the time of the login attempt.
	private String mEmail;
	private String mPassword;

	// UI references.
	private EditText mEmailView;
	private EditText mPasswordView;
	private View mLoginFormView;
	private View mLoginStatusView;
	private TextView mLoginStatusMessageView;
	private String access_token;
	private AlertDialog alertDialog;
	private static String userVariable; 
	
	
	 public void onBackPressed() {
		   Intent intent = new Intent(Intent.ACTION_MAIN);
		   intent.addCategory(Intent.CATEGORY_HOME);
		   intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		   startActivity(intent);
		 }
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_login);
		
		//create alert box if no internet
		alertDialog = new AlertDialog.Builder(this).create();
		alertDialog.setTitle("No Internet Connectivity");
		alertDialog.setMessage("Please connect to the internet and try again.");
		alertDialog.setIcon(R.drawable.trac_launcher);
		alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
			
			}
			});
		
		// Is there a token present?
		SharedPreferences userDetails = getSharedPreferences("userdetails",MODE_PRIVATE);
		   access_token = userDetails.getString("token","");
		   Log.d("Access_token, Login Activity:", access_token);
		
		//Set Context
		//LoginActivity.context = getApplicationContext();

		// Set up the login form.
		mEmail = getIntent().getStringExtra(EXTRA_EMAIL);
		mEmailView = (EditText) findViewById(R.id.email);
		mEmailView.setText(mEmail);

		mPasswordView = (EditText) findViewById(R.id.password);
		mPasswordView
				.setOnEditorActionListener(new TextView.OnEditorActionListener() {
					@Override
					public boolean onEditorAction(TextView textView, int id,
							KeyEvent keyEvent) {
						if (id == R.id.login || id == EditorInfo.IME_NULL) {
							attemptLogin();
							return true;
						}
						return false;
					}
				});

		mLoginFormView = findViewById(R.id.login_form);
		mLoginStatusView = findViewById(R.id.login_status);
		mLoginStatusMessageView = (TextView) findViewById(R.id.login_status_message);

		findViewById(R.id.sign_in_button).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View view) {
						//on click of signin, attemptLogin function called
				        attemptLogin();
				       // startActivity(new Intent(LoginActivity.this, CalendarActivity.class));
					}
				});
	}

	 //public static Context getAppContext() {
	 //       return LoginActivity.context;
	//    }
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);
		getMenuInflater().inflate(R.menu.login, menu);
		return true;
	}

	/**
	 * Attempts to sign in or register the account specified by the login form.
	 * If there are form errors (invalid email, missing fields, etc.), the
	 * errors are presented and no actual login attempt is made.
	 */
	public void attemptLogin() {
		if (mAuthTask != null) {
			return;
		}

		// Reset errors.
		mEmailView.setError(null);
		mPasswordView.setError(null);

		// Store values at the time of the login attempt.
		mEmail = mEmailView.getText().toString();
		mPassword = mPasswordView.getText().toString();

		boolean cancel = false;
		View focusView = null;

		// Check for a valid password.
		if (TextUtils.isEmpty(mPassword)) {
			mPasswordView.setError(getString(R.string.error_field_required));
			focusView = mPasswordView;
			cancel = true;
		} else if (mPassword.length() < 4) {
			mPasswordView.setError(getString(R.string.error_invalid_password));
			focusView = mPasswordView;
			cancel = true;
		}

		// Check for a valid email address.
		if (TextUtils.isEmpty(mEmail)) {
			mEmailView.setError(getString(R.string.error_field_required));
			focusView = mEmailView;
			cancel = true;
		} 

		if (cancel) {
			// There was an error; don't attempt login and focus the first
			// form field with an error.
			focusView.requestFocus();
		} else {
			// Show a progress spinner, and kick off a background task to
			// perform the user login attempt.
			mLoginStatusMessageView.setText(R.string.login_progress_signing_in);
			showProgress(true);
			mAuthTask = new UserLoginTask();
			mAuthTask.execute("https://trac-us.appspot.com/oauth2/access_token");
		}
	}

	/**
	 * Shows the progress UI and hides the login form.
	 */
	@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR2)
	private void showProgress(final boolean show) {
		// On Honeycomb MR2 we have the ViewPropertyAnimator APIs, which allow
		// for very easy animations. If available, use these APIs to fade-in
		// the progress spinner.
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR2) {
			int shortAnimTime = getResources().getInteger(
					android.R.integer.config_shortAnimTime);

			mLoginStatusView.setVisibility(View.VISIBLE);
			mLoginStatusView.animate().setDuration(shortAnimTime)
					.alpha(show ? 1 : 0)
					.setListener(new AnimatorListenerAdapter() {
						@Override
						public void onAnimationEnd(Animator animation) {
							mLoginStatusView.setVisibility(show ? View.VISIBLE
									: View.GONE);
						}
					});

			mLoginFormView.setVisibility(View.VISIBLE);
			mLoginFormView.animate().setDuration(shortAnimTime)
					.alpha(show ? 0 : 1)
					.setListener(new AnimatorListenerAdapter() {
						@Override
						public void onAnimationEnd(Animator animation) {
							mLoginFormView.setVisibility(show ? View.GONE
									: View.VISIBLE);
						}
					});
		} else {
			// The ViewPropertyAnimator APIs are not available, so simply show
			// and hide the relevant UI components.
			mLoginStatusView.setVisibility(show ? View.VISIBLE : View.GONE);
			mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
		}
	}

	/**
	 * Represents an asynchronous login/registration task used to authenticate
	 * the user.
	 */
  	OkHttpClient client = new OkHttpClient();
	Gson gson = new Gson();
	
	private static final String DEBUG_TAG = "Login Attempt";
	  public static final MediaType JSON = MediaType.parse("application/x-www-form-urlencoded; charset=utf-8");
	
	public class UserLoginTask extends AsyncTask<String, Void, Boolean> {
		@Override
		protected Boolean doInBackground(String... params) {
			// Attempt authentication against a network service.
			Log.d("Username:", mEmail);
			Log.d("Password:",mPassword);
			//inserts text into string
			String pre_json = "username="+mEmail+"&password="+mPassword+"&grant_type=password"+"&client_id="+mEmail;
			Log.d(DEBUG_TAG, "Pre JSON Data: "+ pre_json);
			
			//String json = gson.toJson(pre_json);
			//Log.d(DEBUG_TAG, "JSON "+ json);
			
			
			
			RequestBody body = RequestBody.create(JSON, pre_json);
			Log.d(DEBUG_TAG, "Request Body "+ body);
			
			
			
			Request request = new Request.Builder()
	        .url(params[0])
	        .post(body)
	        .build();
			
			Log.d(DEBUG_TAG, "Request Data: "+ request);
			try {
			    Response response = client.newCall(request).execute();
			    Log.d(DEBUG_TAG, "Response Data: "+ response);
			    
			    int codevar = response.code();
			    Log.d(DEBUG_TAG, "Response Code: "+ codevar);
			    
			    Log.d(DEBUG_TAG, "Request Data: "+ request);
			    var = response.body().string();
			    
			    Log.d(DEBUG_TAG, "VAR: "+ var);
			    
			    if (codevar == 200) {
			    return true;
			    }
			    else {
			    return false;
			    }
			    
			} catch (IOException e) {
				Log.d(DEBUG_TAG, "IoException" + e.getMessage());
				return null;
			}
			
			
			/*try {
				// Simulate network access.
				Thread.sleep(2000);
			} catch (InterruptedException e) {
				return false;
			}

			for (String credential : DUMMY_CREDENTIALS) {
				String[] pieces = credential.split(":");
				if (pieces[0].equals(mEmail)) {
					// Account exists, return true if the password matches.
					return pieces[1].equals(mPassword);
				}
			}
*/
			// TODO: register the new account here.
			//return true;
		}

		@Override
		protected void onPostExecute(final Boolean success) {
			mAuthTask = null;
			showProgress(false);
			if (success == null){
				alertDialog.show();
			}
			else if (success) {
				//finish();
				//store the token in Shared Preferences for other Acitivties to access
				Gson gson = new Gson();
				AccessToken parsedLogin = gson.fromJson(var, AccessToken.class);
				Log.d("Test Test var ???", var);
				String access_token = parsedLogin.access_token;
				Log.d("Test Test var ???", access_token);
				
				//context = getAppContext();
				SharedPreferences pref = getSharedPreferences("userdetails", MODE_PRIVATE);
				Editor edit = pref.edit();
				edit.putString("token", access_token);
				edit.commit();
				
				//SharedPreferences userDetails = getSharedPreferences("userdetails",MODE_PRIVATE);
				//   String access_token2 = userDetails.getString("token","");
				  // Log.d("Access_token", access_token2);
				
				//go to calendar page
     			 UserType userType = new UserType();
     			 String url = "https://trac-us.appspot.com/api/userType/?access_token="+access_token;
     			 userType.execute(url);
     			 
				 Intent intent = new Intent(LoginActivity.this, CalendarActivity.class);
				 startActivity(intent);
				 
			} else {
				mPasswordView
						.setError(getString(R.string.error_incorrect_password));
				mPasswordView.requestFocus();
			}
		}

		@Override
		protected void onCancelled() {
			mAuthTask = null;
			showProgress(false);
		}
	}
	
	public class UserType extends AsyncTask<String, Void, Boolean> {
		@Override
		protected Boolean doInBackground(String... params) {
			// Attempt authentication against a network service.

			
			Request request = new Request.Builder()
	        .url(params[0])
	        .build();
			
			Log.d(DEBUG_TAG, "Request Data: "+ request);
			try {
			    Response response = client.newCall(request).execute();
			    Log.d(DEBUG_TAG, "Response Data: "+ response);
			    
			    int codevar = response.code();
			    Log.d(DEBUG_TAG, "Response Code: "+ codevar);
			    
			    Log.d(DEBUG_TAG, "Request Data: "+ request);
			    userVariable = response.body().string();
			    
			    Log.d(DEBUG_TAG, "USERTYPE RESPONSE: "+ userVariable);
			    
			    if (codevar == 200) {
			    return true;
			    }
			    else {
			    return false;
			    }
			    
			} catch (IOException e) {
				Log.d(DEBUG_TAG, "IoException" + e.getMessage());
				return null;
			}

		}

		@Override
		protected void onPostExecute(final Boolean success) {
			Log.d("On Post Execute", "Coach Athlete Activity");
			mAuthTask = null;

			if (success == null){
				alertDialog.show();
			}
			else if (success) {
				//go to calendar page
				Log.d("Success","Coach or Athlete");
				SharedPreferences pref = getSharedPreferences("userdetails", MODE_PRIVATE);
				Editor edit = pref.edit();
				edit.putString("usertype", userVariable);
				edit.commit();

			} else {
				//It it doesnt work segue to login page
				Log.d("NOPE","NO WORK");

			}
		}

		@Override
		protected void onCancelled() {
			mAuthTask = null;

		}
	}
	
}
