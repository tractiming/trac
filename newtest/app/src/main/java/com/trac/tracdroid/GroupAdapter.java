package com.trac.tracdroid;

import android.content.Context;
import android.os.SystemClock;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

public class GroupAdapter extends BaseAdapter{
	//class for group fragment
	private List<Runners> parsedJson; 
	private Context context;
	private ArrayList<Runners> runnersList;
	private HashMap<String, List<String>> resultData;
	private boolean checkStatus;
	ArrayList<Boolean> positionArray;
	ArrayList<String> athleteIDArray;
	ArrayList<String> athleteTimeArray;
	private boolean clearCheckboxes;
	ArrayList<String> totalCountArray;
	ArrayList<String> totalSizeArray;
	ArrayList<String> totalAthleteID;
	ArrayList<String> runningToastStore;
	ArrayList<String> timeArray;
	public boolean addingRow;
	
	
	public GroupAdapter(List<Runners> workout, Context context, HashMap<String, List<String>> resultData) {
	 runnersList = new ArrayList<Runners>();
	 this.parsedJson = workout;
	 this.context = context;
	 this.resultData = resultData;
	 runnersList.addAll(parsedJson);
	 checkStatus = false;
		runningToastStore = new ArrayList<String>();
	 athleteIDArray = new ArrayList<String>();
	 athleteTimeArray = new ArrayList<String>();
	 //iterate through array and put false in for every entry--checkboxes
	 timeArray = new ArrayList<String>(parsedJson.size());
	 positionArray = new ArrayList<Boolean>(parsedJson.size());
	    for(int k=0; k < parsedJson.size(); k++){
	        positionArray.add(false);
	        timeArray.add(Integer.toString(0));
	    }
	    
	totalCountArray = new ArrayList<String>(parsedJson.size());
		for(int k=0; k < parsedJson.size(); k++){
	        totalCountArray.add(resultData.get(parsedJson.get(k).id).get(2).toString());
	    }
		
	totalSizeArray = new ArrayList<String>(parsedJson.size());
		for(int k=0; k < parsedJson.size(); k++){
			totalSizeArray.add(resultData.get(parsedJson.get(k).id).get(1).toString());
	    }
	totalAthleteID = new ArrayList<String>(parsedJson.size());
		for(int k=0; k < parsedJson.size(); k++){
			totalAthleteID.add(parsedJson.get(k).id);
	    }
	}


	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return this.parsedJson.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return this.parsedJson.get(position);
	}

	@Override
	public long getItemId(int arg0) {
		// TODO Auto-generated method stub
		return 0;
	}


	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		//Inflate a view to show peoples names
		//constantly update totalsize array
		//Log.d("has split","split");
		if(parsedJson.get(position).has_split.equalsIgnoreCase("true"))
			totalSizeArray.set(position,Integer.toString(parsedJson.get(position).interval.size()));
		else 
			totalSizeArray.set(position,Integer.toString(0));

		View row = convertView;
	    Holder holder = null;
		
		if (convertView == null) {
			//Log.d("null","null");
			holder = new Holder();
			convertView = LayoutInflater.from(context).inflate(R.layout.list_item_group, null);
			holder.ckbox = (CheckBox) convertView.findViewById(R.id.checkBox);
			convertView.setTag(holder);
		}
		else {
			holder = (Holder) convertView.getTag();
			holder.ckbox.setOnCheckedChangeListener(null);
		}
		
		if (clearCheckboxes)
		{
			holder.ckbox.setChecked(false);
		}
		holder.ckbox.setChecked(positionArray.get(position));
	
		holder.ckbox.setFocusable(false);
	   if(!addingRow){ 
		   holder.ckbox.setChecked(positionArray.get(position));
		   addingRow = false;
	   }
		final View finalConvertView = convertView;
		holder.ckbox.setOnCheckedChangeListener(new OnCheckedChangeListener() {

	        @Override
	        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {

	            if(isChecked){
	            	changeBool();
	                positionArray.set(position, true);
	                athleteIDArray.add(parsedJson.get(position).id);
					SimpleDateFormat dateFormatGmt = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");
					dateFormatGmt.setTimeZone(TimeZone.getTimeZone("GMT"));
					final String utcTime = dateFormatGmt.format(new Date());
					athleteTimeArray.add(utcTime);
					runningToastStore.add(Long.toString(SystemClock.elapsedRealtime()));

	            }
	            else if(!isChecked){
	                positionArray.set(position, false);
	            //if its in there and its unchecked...
		            if(athleteIDArray.contains(parsedJson.get(position).id)){
		            	int athleteindex = athleteIDArray.indexOf(parsedJson.get(position).id);
		            	athleteIDArray.remove(athleteindex);
						athleteTimeArray.remove(athleteindex);
						runningToastStore.remove(athleteindex);

		            }
	            }
	            //System.out.println(positionArray);
				//If array has anything in it, flip button value

	        }

	    });
	  
		//this finds the name and displays it
		TextView textView =(TextView) convertView.findViewById(R.id.list_text);
		textView.setText(parsedJson.get(position).name);
		
		
		TextView textView4 =(TextView) convertView.findViewById(R.id.list_text3);

		
		RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)textView.getLayoutParams();
		if (checkStatus){
			params.setMargins(50, 0, 0, 0); //substitute parameters for left, top, right, bottom
			textView.setLayoutParams(params);
			holder.ckbox.setVisibility(View.VISIBLE);
		}
		else{
			params.setMargins(0, 0, 0, 0); //substitute parameters for left, top, right, bottom
			textView.setLayoutParams(params);
			holder.ckbox.setVisibility(View.GONE);
		}

		//This determines the what is the most recent split, and display it
		TextView textView2 = (TextView) convertView.findViewById(R.id.list_text2);
		List<String[]> intervals = parsedJson.get(position).interval;

		if (parsedJson.get(position).has_split.equalsIgnoreCase("true") && !intervals.isEmpty()){
			int ii = parsedJson.get(position).interval.get(intervals.size() - 1).length - 1;
			
			float firstsplitfloat = Float.parseFloat(parsedJson.get(position).interval.get(intervals.size() - 1)[ii]);
			if (firstsplitfloat>90){
				int min = (int) Math.floor(firstsplitfloat/60);
				int sec = (int) (((firstsplitfloat*60)-Math.floor(firstsplitfloat/60)*3600)/60);
				int mili = (int) (firstsplitfloat*100-Math.floor(firstsplitfloat)*100);
				StringBuilder sb = new StringBuilder();
				if (sec < 10)
				{
					sb.append(min + ":0" + sec +"." + mili );
				}
				else
				{
					sb.append(min + ":" +sec +"."+ mili);		
				}
				textView2.setText(sb.toString());
			}
			else{
				textView2.setText(parsedJson.get(position).interval.get(intervals.size() - 1)[ii]);
			}
			//Add times together and display elapsed time for split
				    float temp_var = 0; 
					for (int i = Integer.parseInt(totalCountArray.get(position)); i < parsedJson.get(position).interval.size();i++)	
						
					{
						
						//float foo = Float.parseFloat(parsedJson.runners.get(position).interval.get(intervals.size() - 1)[1]);
						//Log.d("Loop Variable in Adapter",parsedJson.runners.get(position).interval.get(i).toString());
						
						for (String splits: parsedJson.get(position).interval.get(i)){
							float temp = Float.parseFloat(splits);
							String f1Str = Float.toString(temp);   
							//Log.d("Splits??!?!?!",f1Str);
							temp_var=temp_var + temp;
						}
					}
					StringBuilder sb = new StringBuilder();
					int min = (int) Math.floor(temp_var/60);
					int sec = (int) (((temp_var*60)-Math.floor(temp_var/60)*3600)/60);
					int mili = (int) (temp_var*100-Math.floor(temp_var)*100);
					if (sec < 10)
					{
						sb.append(min + ":0" + sec +"." + mili );
					}
					else
					{
						sb.append(min + ":" +sec +"."+ mili);
					}
					
					String strI = sb.toString();
					
					textView4.setText(strI);
			    
		}
		else if (parsedJson.get(position).has_split.equalsIgnoreCase("true") && intervals != null){
			textView2.setText("NT");
			textView4.setText("NT");
			Log.d("has split","NT");
		}
		else {
			textView2.setText("DNS");
			textView4.setText("DNS");
			Log.d("has split","DNS");
			
		}
				
		//Fill that view with data
		//Return that view
		return convertView;
	}
	
	public ArrayList<String> getCheckArrayID(){
		return athleteIDArray;
	}
	public ArrayList<String> getCheckTimeArray(){
		return athleteTimeArray;
	}
	public void resetCheckArray(){
		athleteIDArray.clear();
		athleteTimeArray.clear();
		runningToastStore.clear();
	}
	public void clearCheckboxes(){
		clearCheckboxes = true;
		Log.d("Fired", "Clear");
		    for(int k=0; k < positionArray.size(); k++){
		    	positionArray.set(k, false);
		    }
	}
	public void changeBool(){
		clearCheckboxes = false;
		
	}
	public void splitButtonPressed(ArrayList<String> splitArray){
		String currentTime = Long.toString(SystemClock.elapsedRealtime());
		System.out.println("Split Button pressed split" + splitArray.toString() + totalAthleteID.toString());
		if(splitArray.size() == 0 || splitArray == null)
		{
			System.out.println("entered the null guy");
			splitArray = getAllIDs();
			for (int i = 0; i < splitArray.size(); i++) {
				System.out.println("null guy");
				//iterate through fed array and see if it matches id to any temp dict
				Boolean tempBool = totalAthleteID.contains(splitArray.get(i));
				//If its in there, replace the values, reset the timer array
				System.out.println("Split Check Boolean Value" + Boolean.toString(tempBool));
				if (tempBool) {
					System.out.println("Do Vlaues even match?");
					//If new json has more entries than old json, update
					//Find the relevant index in java; find result.get(i).id
					int tempIndex = totalAthleteID.indexOf(splitArray.get(i));
					//If the current resetcount is within 1 of the total json count, reset the stopwatch time
					Log.d(totalCountArray.get(tempIndex), totalSizeArray.get(tempIndex));

					int tempCount = Integer.parseInt(totalCountArray.get(tempIndex)) - 1;
					System.out.println("Debug what's the value of " + runningToastStore.toString());
					if (parsedJson.get(tempIndex).has_split.equalsIgnoreCase("false")) {
						Log.d("Entered", "The DNS FUnction");
						int temporaryCount = Integer.parseInt(totalSizeArray.get(tempIndex));
						totalCountArray.set(tempIndex, Integer.toString(temporaryCount));
						timeArray.set(tempIndex,currentTime);

					} else if (totalSizeArray.get(tempIndex) == Integer.toString(tempCount)) {
						Log.d("Entered", "The Everything else FUnction");
						timeArray.set(tempIndex, currentTime);
					}
				}

			}
		}
		else {
			for (int i = 0; i < splitArray.size(); i++) {
				//iterate through fed array and see if it matches id to any temp dict
				Boolean tempBool = totalAthleteID.contains(splitArray.get(i));
				//If its in there, replace the values, reset the timer array
				System.out.println("Split Check Boolean Value" + Boolean.toString(tempBool));
				if (tempBool) {
					System.out.println("Do Vlaues even match?");
					//If new json has more entries than old json, update
					//Find the relevant index in java; find result.get(i).id
					int tempIndex = totalAthleteID.indexOf(splitArray.get(i));
					//If the current resetcount is within 1 of the total json count, reset the stopwatch time
					Log.d(totalCountArray.get(tempIndex), totalSizeArray.get(tempIndex));

					int tempCount = Integer.parseInt(totalCountArray.get(tempIndex)) - 1;
					System.out.println("Debug what's the value of " + runningToastStore.toString());
					if (parsedJson.get(tempIndex).has_split.equalsIgnoreCase("false")) {
						Log.d("Entered", "The DNS FUnction");
						int temporaryCount = Integer.parseInt(totalSizeArray.get(tempIndex));
						totalCountArray.set(tempIndex, Integer.toString(temporaryCount));
						timeArray.set(tempIndex, runningToastStore.get(i));

					} else if (totalSizeArray.get(tempIndex) == Integer.toString(tempCount)) {
						Log.d("Entered", "The Everything else FUnction");
						timeArray.set(tempIndex, runningToastStore.get(i));
					}
				}

			}
		}
		notifyDataSetChanged();
		
	
	}
	
	public void resetButtonPressed(ArrayList<String> resetArray){
		//1. replace dictionary values.
		//2. re-run everything

		List<String> tempDict = new ArrayList<String>(resultData.keySet());
		//System.out.print(tempDict.toString() + totalAthleteID.toString());
		for (int i = 0; i < resetArray.size(); i++){
			//iterate through fed array and see if it matches id to any temp dict
			Boolean tempBool = totalAthleteID.contains(resetArray.get(i));		

			//If its in there, replace the values, refresh the reset view

			if (tempBool) {
        		//If new json has more entries than old json, update
        		//Find the relevant index in java; find result.get(i).id
				int tempIndex = totalAthleteID.indexOf(resetArray.get(i));
				int tempCount = Integer.parseInt(totalSizeArray.get(tempIndex)) + 1;
				totalCountArray.set(tempIndex, Integer.toString(tempCount));
				timeArray.set(tempIndex, Long.toString(SystemClock.elapsedRealtime()));
				
        	}

		}
		changeBool();
		notifyDataSetChanged();
		
	}
	
	
	public void changeCheck(Boolean checkstats){
		checkStatus = checkstats;
		notifyDataSetChanged();
	}
	
	public ArrayList<String> getTimes(){

		return timeArray;
	}

 	public ArrayList<String> getSplitReset(){

		return totalCountArray;
	}

	public ArrayList<String> getAllIDs(){

		return totalAthleteID;
	}

	public void passInTimeResetID(ArrayList<String> time, ArrayList<String> resetSplits, ArrayList<String> runnerIDs){
		//TODO: Reorder arrays to match what the jsonID array outputs has; aka the order of the indicies.
		//Replace the
		//List<String> tempDict = new ArrayList<String>(resultData.keySet());
		//Log.d("Temp Dict-----",tempDict.toString());
		for (int i = 0; i < runnerIDs.size(); i++){
			Boolean tempBool = totalAthleteID.contains(runnerIDs.get(i));
			if (tempBool){
				//if its in the array from previous, add its time
				for (int j = 0; j < totalAthleteID.size();j++)
				{
					if((totalAthleteID.get(j)).equals(runnerIDs.get(i))){
						System.out.println("Old Index:"+j+"new index"+i);
						timeArray.set(j,time.get(i));
						totalCountArray.set(j,resetSplits.get(i));
					}
				}
			}
		}
		System.out.println("Adapter Total Count Array:" + totalCountArray.toString() + "Time Array:" + timeArray.toString());
		notifyDataSetChanged();
	}
	
	public void updateResults(List<Runners> result) {
        //Log.d("Log",resultData.toString());
        List<String> tempDict = new ArrayList<String>(resultData.keySet());
        //Log.d("Dict Values Extracted",tempDict.toString());
        
        //update specific arrays as necessary.
        for (int i = 0; i < result.size(); i++){
        	//Does athelte id exist? check recently polled json from stored dictionary
        	//If doesnt exist add to end

        	Boolean tempBool = tempDict.contains(result.get(i).id);
        	//if its not in the array add it
        	if (!tempBool){

        		totalCountArray.add(Integer.toString(0));
        		timeArray.add(Integer.toString(0));
        		totalSizeArray.add(Integer.toString(0));
        		totalAthleteID.add(result.get(i).id);
        		parsedJson.add(result.get(i));
        		positionArray.add(false);
        		
        		
        		notifyDataSetChanged();
        		List<String> tempArray = new ArrayList<String>();
        		tempArray.add(result.get(i).name);
				tempArray.add(Integer.toString(result.get(i).interval.size()));
				tempArray.add(Integer.toString(0));
        		resultData.put(result.get(i).id, tempArray);
        		addingRow = true;
        		
        		
        	}
        	else if(tempBool) {
        		if(result.get(i).interval == null){
        			continue;
        		}
        		else if (result.get(i).interval != null & result.get(i).interval.size() > Integer.parseInt(resultData.get(result.get(i).id).get(1))){
	        		//If new json has more entries than old json, update
	        		//Find the relevant index in java; find result.get(i).id
	        		List<String> tempArray = new ArrayList<String>();
	        		if(parsedJson != null){
		        		for(int jj = 0; jj < parsedJson.size();jj++){
		        			tempArray.add(parsedJson.get(jj).id);
		        		}
		        		//Log.d("Does this worK?",Integer.toString(parsedJson..indexOf(result.get(i).id)));
		        		parsedJson.set(tempArray.indexOf(result.get(i).id),result.get(i));
		        		notifyDataSetChanged();
	        		}
        		}
        	}
        }
        //Triggers the list update
        
    }
	
	
	public void getFilter(String charText) {
		charText = charText.toLowerCase(Locale.getDefault());
		parsedJson.clear();
				if (charText.length() == 0) {
					parsedJson.addAll(runnersList);
		} 
		else 
		{
			for (Runners wp : runnersList) 
			{
				if (wp.name.toLowerCase(Locale.getDefault()).contains(charText)) 
				{
					parsedJson.add(wp);
				}
			}
		}
		notifyDataSetChanged();
	}

	static class Holder
	{
	   
	    CheckBox ckbox;

	}

}
