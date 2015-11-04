package com.example.newtest;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class GroupAdapter extends BaseAdapter{
	//class for group fragment
	private List<Runners> parsedJson; 
	private Context context;
	private ArrayList<Runners> runnersList;
	private HashMap<String, List<String>> resultData;
	private boolean checkStatus;
	ArrayList<Boolean> positionArray;
	ArrayList<String> athleteIDArray;
	private boolean clearCheckboxes;
	
	
	public GroupAdapter(List<Runners> workout, Context context, HashMap<String, List<String>> resultData) {
	 runnersList = new ArrayList<Runners>();
	 this.parsedJson = workout;
	 this.context = context;
	 this.resultData = resultData;
	 runnersList.addAll(parsedJson);
	 checkStatus = false;
	 athleteIDArray = new ArrayList<String>();
	 //iterate through array and put false in for every entry--checkboxes
	 positionArray = new ArrayList<Boolean>(parsedJson.size());
	    for(int k=0; k < parsedJson.size(); k++){
	        positionArray.add(false);
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
		View row = convertView;
	    Holder holder = null;
		
		if (convertView == null) {
			holder = new Holder();
			convertView = LayoutInflater.from(context).inflate(R.layout.list_item_group, null);
			holder.ckbox = (CheckBox) convertView.findViewById(R.id.checkBox);
			convertView.setTag(holder);
		}
		else {
			holder = (Holder) convertView.getTag();
		}
		
		if (clearCheckboxes)
		{
			holder.ckbox.setChecked(false);
			Log.d("Switch???!","Ckbox");
		}
		holder.ckbox.setFocusable(false);
	    holder.ckbox.setChecked(positionArray.get(position));
	    holder.ckbox.setOnCheckedChangeListener(new OnCheckedChangeListener() {
	    	
	        @Override
	        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
	            if(isChecked){
	                positionArray.set(position, true);
	                athleteIDArray.add(parsedJson.get(position).id);
	                Log.d("Adding it","adding it");
	            }
	            else if(!isChecked){
	                positionArray.set(position, false);
	            //if its in there and its unchecked...
		            if(athleteIDArray.contains(parsedJson.get(position).id)){
		            	int athleteindex = athleteIDArray.indexOf(parsedJson.get(position).id);
		            	athleteIDArray.remove(athleteindex);
		            	Log.d("Removing it","removing it");
		            }
	            }
	            System.out.println(athleteIDArray);
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
		if (intervals != null && !intervals.isEmpty()){
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
				for (int i = 0; i < parsedJson.get(position).interval.size();i++)	
					
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
		else{
			Log.d("Throwing the ","Exception");
			textView2.setText("NT");
			textView4.setText("NT");
		}
				
		//Fill that view with data
		//Return that view
		return convertView;
	}
	
	public ArrayList<Boolean> getCheckArray(){
		return positionArray;
	}
	public ArrayList<String> getCheckArrayID(){
		return athleteIDArray;
	}
	public void resetCheckArray(){
		athleteIDArray.clear();
	}
	public void clearCheckboxes(){
		clearCheckboxes = true;
		Log.d("Fired","Clear");
		notifyDataSetChanged();	
	}
	public void changeBool(){
		clearCheckboxes = false;
		
	}
	
	public void changeCheck(Boolean checkstats){
		checkStatus = checkstats;
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
        	
        	//Log.d("Works?",resultData.get(result.get(i).id).get(1).toString());
        
        	Boolean tempBool = tempDict.contains(result.get(i).id);
        	if (!tempBool){
        		//Log.d("In Boolean Again","Boolean Check");
        		parsedJson.add(result.get(i));
        		notifyDataSetChanged();
        		List<String> tempArray = new ArrayList<String>();
        		tempArray.add(result.get(i).name);
				tempArray.add(Integer.toString(result.get(i).interval.size()));
				tempArray.add(Integer.toString(0));
        		resultData.put(result.get(i).id, tempArray);
        		
        	}
        	else if (tempBool & result.get(i).interval.size() > Integer.parseInt(resultData.get(result.get(i).id).get(1))) {
        		//If new json has more entries than old json, update
        		//Find the relevant index in java; find result.get(i).id
        		List<String> tempArray = new ArrayList<String>();
        		for(int jj = 0; jj < parsedJson.size();jj++){
        			tempArray.add(parsedJson.get(jj).id);
        		}
        		//Log.d("Does this worK?",Integer.toString(parsedJson..indexOf(result.get(i).id)));
        		parsedJson.set(tempArray.indexOf(result.get(i).id),result.get(i));
        		notifyDataSetChanged();
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
