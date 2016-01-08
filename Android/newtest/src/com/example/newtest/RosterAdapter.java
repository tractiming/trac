package com.example.newtest;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import com.example.newtest.GroupAdapter.Holder;
import com.trac.trac.R;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.CompoundButton.OnCheckedChangeListener;

public class RosterAdapter extends BaseAdapter {
	//Adapter specifically for CalendarActivity.class
	private ArrayList<RosterJson> parsedJson; 
	private List<RosterJson> parsedJsonList = null;
	private Context context;
	private boolean checkStatus;
	private boolean clearCheckboxes;
	ArrayList<Boolean> positionArray;
	ArrayList<String> athleteIDArray;


	
	public RosterAdapter(List<RosterJson> parsedJsonList, Context context) {
	 this.parsedJsonList = parsedJsonList;
	 this.parsedJson = new ArrayList<RosterJson>();
	 this.parsedJson.addAll(parsedJsonList);
	 this.context = context;
	 positionArray = new ArrayList<Boolean>(parsedJsonList.size());
	 athleteIDArray = new ArrayList<String>();
	 checkStatus = false;
	 
	 for(int k=0; k < parsedJson.size(); k++){
	        positionArray.add(false);
	    }
	}
	
	
	public void add(List<RosterJson> result){
        if (result.size() > 0) {
        	this.parsedJsonList.addAll(result);
        	//Log.d("Size of Array",Integer.toString(result.size()));
		
        	this.getCount();
		
        	notifyDataSetChanged();
			this.parsedJson = new ArrayList<RosterJson>();
			this.parsedJson.addAll(parsedJsonList);
			//Log.d("Enters","Add SubClass");
        }
        else{
        	
        	//Log.d("Enters","DO Nothing");
        }
		
		
		//return parsedJsonList;
	}
	
	@Override
	public int getCount() {
		// dynamically find size of array
		//Log.d("GetCount",Integer.toString(parsedJsonList.size()));
		return parsedJsonList.size();
	}

	@Override
	public Object getItem(int position) {
		// when clicked determine which position was clicked
		//Log.d("getItem","Fired");
		return parsedJsonList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}


	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		//Inflate a view to show peoples names
		Holder holder = null;
		if (convertView == null) {
			holder = new Holder();
			convertView = LayoutInflater.from(context).inflate(R.layout.list_item_roster, null);
			holder.ckbox = (CheckBox) convertView.findViewById(R.id.rosterCheck);
			convertView.setTag(holder);
		}
		else {
			holder = (Holder) convertView.getTag();
		}
		if (clearCheckboxes)
		{
			holder.ckbox.setChecked(false);
		}
	
		holder.ckbox.setFocusable(false);
		
		 holder.ckbox.setOnCheckedChangeListener(new OnCheckedChangeListener() {
		    	
		        @Override
		        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
		        	
		            if(isChecked){
		            	changeBool();
		                positionArray.set(position, true);
		                athleteIDArray.add(parsedJson.get(position).id);
		                
		            }
		            else if(!isChecked){
		                positionArray.set(position, false);
		            //if its in there and its unchecked...
			           if(athleteIDArray.contains(parsedJson.get(position).id)){
			        	   int athleteindex = athleteIDArray.indexOf(parsedJson.get(position).id);
			        	   athleteIDArray.remove(athleteindex);
			            	
			           }
		            }
		            //System.out.println(positionArray);
		        }
		        
		    });
		//this finds the name and displays it
		TextView textView =(TextView) convertView.findViewById(R.id.list_text);
		textView.setText(parsedJsonList.get(position).first +" "+  parsedJsonList.get(position).last);
		//find date adn display it, only show first 10 characters of the date--avoiding the timestamp
		TextView textView2 = (TextView) convertView.findViewById(R.id.list_text3);
		textView2.setText(parsedJsonList.get(position).id_str);
		
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
		
		//Fill that view with data
		//Return that view
		return convertView;
	}


	public void getFilter(String charText) {
		Log.d("Get Filter",charText);
		charText = charText.toLowerCase(Locale.getDefault());
		Log.d("Hello",parsedJsonList.toString());
		parsedJsonList.clear();
		 
		if (charText.length() == 0) {
			Log.d("Hello",parsedJsonList.toString());
			parsedJsonList.addAll(parsedJson);
			Log.d("Hello",parsedJsonList.toString());
		} 
		else 
		{
			Log.d("Hello","");
			for (RosterJson wp : parsedJson) 
			{
				if (wp.first.toLowerCase(Locale.getDefault()).contains(charText)) 
				{
					parsedJsonList.add(wp);
				}
			}
		}
		notifyDataSetChanged();
	}


	public void changeCheck(boolean editStatus) {
		checkStatus = editStatus;
		notifyDataSetChanged();
		
	}

	public void changeBool(){
		clearCheckboxes = false;
		
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
	}
	
	
}

