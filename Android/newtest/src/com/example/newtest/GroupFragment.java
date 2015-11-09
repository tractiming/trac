package com.example.newtest;



import java.io.IOException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.CancellationException;
import java.util.concurrent.ExecutionException;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Parcelable;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.CheckBox;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import android.os.Bundle;
import android.os.SystemClock;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Chronometer;


public class GroupFragment extends ListFragment {
	
	private ListView labels;
	View detailListHeader;
	View detailListHeader2;
	View detailListHeader3;
	public ListView lview;
	private String message;
	//private final static int INTERVAL = 1000; //runs every 2 minutes
	//private Handler mHandler;
	private View mLoginStatusView;
	public static Timer timer;
	public TimerTask doAsynchronousTask;
	public static AsyncServiceCall asyncServiceCall;
	public static String testvar;
	public static String title;
	public static String date;
	public GroupAdapter groupList;
	public GroupAsyncResponse delegate; 
	public boolean executed;
	List<String> resultData;
	HashMap<String, List<String>> athleteDictionary;
	List<String> subAthelteDictionary;
	private boolean editStatus;
	private String access_token;
	public Boolean asyncStatus;
	public List<Runners> tempRunVar;
	private Handler customHandler = new Handler();
	public Handler mHandler;
	long updatedTime = 0L;
	long startTime = 0L;
	long timeSwapBuff = 0L;
	long timeInMilliseconds =0L;
	long storedTime = 0L;
	public volatile boolean shutdown;
	int counter;

	
	public static void backButtonWasPressed() {
		timer.cancel();
		asyncServiceCall.cancel(true);
        //Log.d("HI","Passed");
        testvar = null;
    }

	public void onPause(){
		super.onPause();
		timer.cancel();
		asyncServiceCall.cancel(true);
	}
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		startTime = SystemClock.elapsedRealtime();
		
		
		Bundle args = getArguments();
		access_token = args.getString("AccessToken","");
		
		setHasOptionsMenu(true);
		//Log.d("Instance State in Group on Create",savedInstanceState.toString());
		View rootView = inflater.inflate(R.layout.fragment_group_view, container,
				false);
        //Inflate ID and Workout Numbers
		mTextView = (TextView) rootView.findViewById(R.id.workout_date_view);
		mTextView1 = (TextView) rootView.findViewById(R.id.workout_id_view);
		//boolean values for checkmark and async task
		editStatus = true;
		executed = false;
		
		if(testvar != null){
			timer.cancel();
			asyncServiceCall.cancel(true);
			mLoginStatusView = rootView.findViewById(R.id.login_status);
		    mLoginStatusView.setVisibility(View.GONE);
		    mTextView1.setText("Date: " + date.substring(0,10));
		    mTextView.setText("Workout Name: " + title);

		}
		else{
			testvar = "FragmentCheckCreation";
			mLoginStatusView = rootView.findViewById(R.id.login_status);
		    mLoginStatusView.setVisibility(View.VISIBLE);
		}
		
		
		// 1. get passed intent from MainActivity
		Intent intent = getActivity().getIntent();
		
        // 2. get message value from intent
        message = intent.getStringExtra("message");
		//message = "http://10.0.2.2:8000/api/sessions/17/individual_results/?access_token=LiuG7SFs8nU7fY0GtryR6PPqjbeMAW";
        title = intent.getStringExtra("workoutName");
        date = intent.getStringExtra("workoutDate");
        //Log.d("The passed Variable in frag baby", message);
        

        asyncServiceCall = new AsyncServiceCall();
    	asyncServiceCall.execute(message);
        
		    

		//Inflate Header--gives titles above names and splits
		detailListHeader = rootView.findViewById(R.id.header);
		detailListHeader2 = rootView.findViewById(R.id.header2);
		detailListHeader3 = rootView.findViewById(R.id.header3);
		
		final Button b2 = (Button) rootView.findViewById(R.id.split);
	    b2.setOnClickListener( new View.OnClickListener() {
		    public void onClick(View v) {
		    	
		    	ArrayList<String> checkArray = groupList.getCheckArrayID();
		    	
		    	//Log.d("Array has data?2 ??",checkArray.toString());
		    	
	        	String url = "https://trac-us.appspot.com/api/individual_splits/?access_token=" + access_token;;
	        	//http://10.0.2.2:8000/api/individual_splits/?access_token=TIqT4duj7LnkyE5YwDO3qV2a7AJET8
	        	SplitAsyncCall splitCall = new SplitAsyncCall(checkArray,url);
	        	splitCall.execute();
	        	groupList.splitButtonPressed(checkArray);
	        	groupList.clearCheckboxes();
	        	try {
					asyncStatus = splitCall.get();
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
	        	if(asyncStatus){
	        	
	        		asyncServiceCall = new AsyncServiceCall();
                	asyncServiceCall.execute(message);
                	try {
						tempRunVar = asyncServiceCall.get();
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (ExecutionException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch(CancellationException e){
						e.printStackTrace();
					}
	        		if(tempRunVar != null){
	        			groupList.resetCheckArray();
	        			//groupList.changeBool();
	        		}
	        	
	        	}
	        	else{
	        		
	        		
	        	}
	        	//Log.d("Array has data? 3?",checkArray.toString());
	        	//groupList.resetCheckArray();
	        	//groupList.clearCheckboxes();
		    }
		  });
	    
	    final Button b1 = (Button) rootView.findViewById(R.id.reset);
	    b1.setOnClickListener( new View.OnClickListener() {
		    public void onClick(View v) {
		      ArrayList<String> checkArray = groupList.getCheckArrayID();
		      groupList.resetButtonPressed(checkArray);
		      groupList.resetCheckArray();
		      groupList.clearCheckboxes();
		      
		    }
		  });
		

		return rootView;
	}	
	
	

	
	@Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        //Toggle CheckBox from not selected to selected and vice versa.
        if (v != null) {
            CheckBox checkBox = (CheckBox)v.findViewById(R.id.checkBox);
            checkBox.setChecked(!checkBox.isChecked());
        }
    }
	
	
	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
	    inflater.inflate(R.menu.group_view, menu);
	    super.onCreateOptionsMenu(menu, inflater);
	}
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		
	    switch (item.getItemId()) {
	        case R.id.action_edit: 
	        	//do something
	        	//only does for one right now..
	        	groupList.changeCheck(editStatus);
	        	if(editStatus){
	        		editStatus = false;
	        		LinearLayout footer = (LinearLayout) getActivity().findViewById(R.id.footer);
		            footer.setVisibility(LinearLayout.VISIBLE);
	        	}
	        	else{
	        		editStatus = true;
	        		LinearLayout footer = (LinearLayout) getActivity().findViewById(R.id.footer);
		            footer.setVisibility(LinearLayout.GONE);
	        	}
	        	
	            return true;
	    }
	    return super.onOptionsItemSelected(item);
	} 
	
	public void onResume(){
		super.onResume();
		 timer = new Timer();
		    doAsynchronousTask = new TimerTask() {       
		                public void run() {       
		                    try {
		                    	asyncServiceCall.cancel(true);
		                    	asyncServiceCall = new AsyncServiceCall();
		                        // PerformBackgroundTask this class is the class that extends AsynchTask 
		                    	//Log.d("URL:", message);
		                    	//performs async service call on the message--url--passed
		                    	asyncServiceCall.execute(message);
		                    	Log.i(DEBUG_TAG, "counter");
		                    } catch (Exception e) {
		                        // TODO Auto-generated catch block
		                    }
		        }
		    };
		    timer.schedule(doAsynchronousTask, 0, 5000); //execute in every 4.0 seconds
		
		
	}
	

	 Runnable updateTimerThread = new Runnable() {
		public void run(){

			if(!shutdown){
	            timeInMilliseconds = SystemClock.elapsedRealtime() - startTime;
	            updatedTime = timeSwapBuff + timeInMilliseconds;
	            
	            if (storedTime !=0)
	            {
	            	updatedTime = SystemClock.elapsedRealtime() - storedTime;
	            }
	            int hours = (int)(updatedTime / (3600 * 1000));
	            int remaining = (int)(updatedTime % (3600 * 1000));
	            
	            int mins = (int)(remaining / (60 * 1000));
	            remaining = (int)(remaining % (60 * 1000));
	            
	            int secs = (int)(remaining / 1000);
	            remaining = (int)(remaining % (1000));
	            
	            int milliseconds = (int)(((int)updatedTime % 1000) / 100);
	            String text = "";
	            DecimalFormat df = new DecimalFormat("00");
	            
	            if (hours > 0) {
	            	text += df.format(hours) + ":";
	            }

	            text += df.format(mins) + ":";
	           	text += df.format(secs) + ":";
	           	text += Integer.toString(milliseconds);
	            
				Message msg=new Message();
	            msg.obj=text;
	            mHandler.sendMessage(msg);
	            customHandler.post(this);
	            counter++;
	            //Log.d("Run",Integer.toString(counter));
	            if (counter>1000){
	            	shutdown = true;
	            	counter = 0;
	            }
			}
            


			
		}
		
	};

  @Override
  public void onActivityCreated(Bundle savedInstanceState) {
    super.onActivityCreated(savedInstanceState);
    lview = getListView();
    
    lview.setOnItemLongClickListener(new OnItemLongClickListener() {


		public boolean onItemLongClick(AdapterView<?> arg0, View arg1,
                int arg2, long arg3) {
			counter = 0;
			shutdown = false;
		
         ArrayList<String> tempList = groupList.getTimes();
        
       	//final String timeVar = time.updateText(SystemClock.elapsedRealtime(),Long.parseLong(tempList.get(arg2)));
         storedTime = Long.parseLong(tempList.get(arg2));
         customHandler.post(updateTimerThread);
       	
       	final Toast toast = Toast.makeText(getActivity(), "", Toast.LENGTH_LONG);
       	toast.show();
       	 mHandler = new Handler() { 
             @Override public void handleMessage(Message msg) { 
                String mString=(String)msg.obj;
                toast.setText(mString);
              
             }
         };
         // Toast...
         Log.d("Hello","Helo");
            return true;
        }
    });
    //new AsyncServiceCall().execute("http://76.12.155.219/trac/json/test.json");
    
  }
  


 
  private TextView mTextView;
  private TextView mTextView1;

  
  
  	private final OkHttpClient client = new OkHttpClient();
	Gson gson = new Gson();
	private static final String DEBUG_TAG = "Debug";
	
	  private class AsyncServiceCall extends AsyncTask<String, Void, List<Runners>> {
		  protected void onPreExecute(){
			  //Log.d("Async", "PreExcute");
		  }
		  
		    @Override
		    protected void onCancelled() {
		        //Log.d("Canceled", "canceld");
		    }
		  
			@Override
			protected List<Runners> doInBackground(String... params) {
				Request request = new Request.Builder()
		        .url(params[0])
		        .build();
				try {
				    Response response = client.newCall(request).execute();

				    IndividualResults preFullyParsed = gson.fromJson(response.body().charStream(), IndividualResults.class);
				    
				    List<Runners> text = preFullyParsed.results;
				    
				    Workout test = null;

				    return text;
				    
				} catch (IOException e) {
					
					return null;
				}
			}
			
			@Override
			protected void onPostExecute(List<Runners> result) {

				 mLoginStatusView.setVisibility(View.GONE);
				//did not have popup appear if null due to async every 2 seconds being called. Popup will continuously popup then
				if(result==null){
					return;
				}
				else
				{
					//store result into dictionary
					resultData = new ArrayList<String>();
					athleteDictionary = new HashMap<String, List<String>>();
					//subAthelteDictionary = new ArrayList<String>();
					for (int i = 0; i < result.size(); i++){
						List<String> tempArray = new ArrayList<String>();
						resultData.add(result.get(i).id);
						if(result.get(i).interval == null){
							tempArray.add(result.get(i).name);
							tempArray.add(Integer.toString(-1));
							tempArray.add(Integer.toString(0));
							athleteDictionary.put(resultData.get(i), tempArray);	
							continue; 
						}
						for (int j = 0; j < result.get(i).interval.size(); j++){
							
							float temp = Float.parseFloat(result.get(i).interval.get(j)[0]);
							if (temp>90){
								int min = (int) Math.floor(temp/60);
								int sec = (int) (((temp*60)-Math.floor(temp/60)*3600)/60);
								int mili = (int) (temp*100-Math.floor(temp)*100);
								StringBuilder sb = new StringBuilder();
								if (sec < 10)
								{
									
									sb.append(min + ":0" + sec +"." + mili );
								}
								else
								{
									
									sb.append(min + ":" +sec +"."+ mili);
								}
								//tempArray.add(sb.toString());
							}
							else{
								//tempArray.add(result.get(i).interval.get(j)[0].toString());
							}				
							//Log.d("Interval to String", result.get(i).interval.get(j)[0].toString());
						}
						tempArray.add(result.get(i).name);
						tempArray.add(Integer.toString(result.get(i).interval.size()));
						tempArray.add(Integer.toString(0));
						//athleteDictionary.put(result.get(i).id, tempArray);
						//resultData.add(athleteDictionary);
						//store name, [last time, total time, total count, last counted]
						athleteDictionary.put(resultData.get(i), tempArray);
					}
					//Log.d("Dictionary",athleteDictionary.toString());
					
					
					//set result to show on screen
					Parcelable state = lview.onSaveInstanceState();
					if (executed == false){
						//Log.d(DEBUG_TAG,result.toString());
						//Log.d(DEBUG_TAG,athleteDictionary.toString());
						groupList = new GroupAdapter(result, getActivity(),athleteDictionary);
					    setListAdapter(groupList);	
					    
					    //Set Headers
					    mTextView.setText("Workout Name: " + title);
					    mTextView1.setText("Date: " + date.substring(0,10));
					    executed = true;
					}
					else{
						groupList.updateResults(result);
						
					}
				    delegate.processFinish(groupList);
				 
				   //lview.onRestoreInstanceState(state);
				}
			}
			  
		  }


  
  
} 