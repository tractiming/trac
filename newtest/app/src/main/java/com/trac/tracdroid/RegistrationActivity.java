package com.trac.tracdroid;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.TextView;

import com.amplitude.api.Amplitude;
import com.google.gson.Gson;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import java.io.IOException;

/**
 * Activity which displays a login screen to the user, offering registration as
 * well.
 */
public class RegistrationActivity extends Activity {
	
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
	private String mConfirm;
	private String mUsername;
	private String mOrganization;

	// UI references.
	private EditText mEmailView;
	private EditText mPasswordView;
	private EditText mConfirmView;
	private EditText mUsernameView;
	private EditText mOrganizationView;
	private View mLoginFormView;
	private View mLoginStatusView;
	private TextView mLoginStatusMessageView;
	private String access_token;
	private AlertDialog alertDialog;
	private static String userVariable;
	private String client_secret;
	private String client_id;


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_register);

		getWindow().setSoftInputMode(
				WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);

		alertDialog = new AlertDialog.Builder(this).create();
		alertDialog.setTitle("Success!");
		alertDialog.setMessage("Account created");
		alertDialog.setIcon(R.drawable.trac_launcher);
		alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				//go to Login page
				Intent intent = new Intent(RegistrationActivity.this, LoginActivity.class);
				startActivity(intent);
			}
			});
		

		//Set Context
		//LoginActivity.context = getApplicationContext();

		// Set up the login form.
		mEmail = getIntent().getStringExtra(EXTRA_EMAIL);
		mEmailView = (EditText) findViewById(R.id.email);
		mEmailView.setText(mEmail);
		
		mOrganizationView = (EditText) findViewById(R.id.organization);
		mUsernameView = (EditText) findViewById(R.id.username);
		mConfirmView = (EditText) findViewById(R.id.confirm);

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
						Amplitude.getInstance().logEvent("RosterActivity_AttemptCreate");
				        attemptLogin();
				       // startActivity(new Intent(LoginActivity.this, CalendarActivity.class));
					}
				});
		
		findViewById(R.id.cancel_button).setOnClickListener(
				new View.OnClickListener() {
					@Override
					public void onClick(View view) {
						Amplitude.getInstance().logEvent("RosterActivity_Cancel");
						//on click of signin, attemptLogin function called
					       startActivity(new Intent(RegistrationActivity.this, LoginActivity.class));

				    
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
		mOrganizationView.setError(null);
		mConfirmView.setError(null);
		mUsernameView.setError(null);

		// Store values at the time of the login attempt.
		mEmail = mEmailView.getText().toString();
		mPassword = mPasswordView.getText().toString();
		mOrganization = mOrganizationView.getText().toString();
		mConfirm = mConfirmView.getText().toString();
		mUsername  = mUsernameView.getText().toString();
		
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
		} else if (!mPassword.equals(mConfirm)) {
			mPasswordView.setError(getString(R.string.error_match));
			focusView = mPasswordView;
			cancel = true;
		}

		// Check for a valid email address.
		if (TextUtils.isEmpty(mEmail)) {
			mEmailView.setError(getString(R.string.error_field_required));
			focusView = mEmailView;
			cancel = true;
		} 
		
		if (TextUtils.isEmpty(mOrganization)) {
			mOrganizationView.setError(getString(R.string.error_field_required));
			focusView = mOrganizationView;
			cancel = true;
		} 
		if (TextUtils.isEmpty(mUsername)) {
			mUsernameView.setError(getString(R.string.error_field_required));
			focusView = mUsernameView;
			cancel = true;
		} 
		if (TextUtils.isEmpty(mConfirm)) {
			mConfirmView.setError(getString(R.string.error_field_required));
			focusView = mConfirmView;
			cancel = true;
		} 

		if (cancel) {
			// There was an error; don't attempt login and focus the first
			// form field with an error.
			focusView.requestFocus();
		} else {
			// Show a progress spinner, and kick off a background task to
			// perform the user login attempt.
			mLoginStatusMessageView.setText(R.string.registerProgress);
			showProgress(true);
			mAuthTask = new UserLoginTask();
			mAuthTask.execute("https://trac-us.appspot.com/api/register/");
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
	
	public class UserLoginTask extends AsyncTask<String, Void, String> {
		@Override
		protected String doInBackground(String... params) {
			// Attempt authentication against a network service.
			Log.d("Email:", mEmail);
			Log.d("Password:",mPassword);
			Log.d("Username:",mUsername);
			//inserts text into string
			String pre_json = "username="+mUsername+"&password="+mPassword+"&email="+mEmail+"&user_type=coach"+"&organization="+mOrganization;
			//Log.d(DEBUG_TAG, "Pre JSON Data: "+ pre_json);

			//String json = gson.toJson(pre_json);
			//Log.d(DEBUG_TAG, "JSON "+ json);

			RequestBody body = RequestBody.create(JSON, pre_json);
			//Log.d(DEBUG_TAG, "Request Body "+ body);



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

				if (codevar > 200 && codevar < 300) {
					return "Success";
				}
				else if(codevar == 500) {
					return "Internal Server Error.";
				}
				else if(codevar == 400) {
					return "Username, Password, or Email are invalid.";
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
			return null;
		}

		@Override
		protected void onPostExecute(final String success) {
			mAuthTask = null;
			showProgress(false);
			if (success == null){
				alertDialog.show();
			}
			else if (success == "Success") {
				//finish();
				//store the token in Shared Preferences for other Acitivties to access

				alertDialog.show();



			} else {
				mEmailView
						.setError(success);
				mEmailView.requestFocus();
			}
		}

		@Override
		protected void onCancelled() {
			mAuthTask = null;
			showProgress(false);
		}
	}
	

	
}

