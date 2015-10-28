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
import android.widget.TextView;

public class GroupAdapter extends BaseAdapter{
	//class for group fragment
	private List<Runners> parsedJson; 
	private Context context;
	private ArrayList<Runners> runnersList;
	List<String> resultData;
	HashMap<String, List<String>> athelteDictionary;
	List<String> subAthelteDictionary;
	
	public GroupAdapter(List<Runners> workout, Context context) {
	 runnersList = new ArrayList<Runners>();
	 this.parsedJson = workout;
	 this.context = context;
	 runnersList.addAll(parsedJson);
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
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		//Inflate a view to show peoples names
		if (convertView == null) {
			convertView = LayoutInflater.from(context).inflate(R.layout.list_item_group, null);
		}
		
		
		//this finds the name and displays it
		TextView textView =(TextView) convertView.findViewById(R.id.list_text);
		textView.setText(parsedJson.get(position).name);
		
		
		TextView textView4 =(TextView) convertView.findViewById(R.id.list_text3);
		
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

	public void updateResults(List<Runners> result) {
        
        //Triggers the list update
        notifyDataSetChanged();
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


	
}
