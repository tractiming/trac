package com.trac.tracdroid;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.Switch;
import android.widget.TextView;

import com.amplitude.api.Amplitude;

import java.util.List;

public class SettingsAdapter extends ArrayAdapter<ListViewItem> {

    public String storedToken;
    public String sessionPrimaryKey;
    RaceCalibration raceAuth;
    RaceStop raceStop;

    public SettingsAdapter(Context context, List<ListViewItem> items) {
        super(context, R.layout.fragment_settings, items);
    }
 
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final ViewHolder viewHolder;
        
        if(convertView == null) {
            // inflate the GridView item layout
            LayoutInflater inflater = LayoutInflater.from(getContext());
            convertView = inflater.inflate(R.layout.fragment_settings, parent, false);
            
            // initialize the view holder
            viewHolder = new ViewHolder();
            viewHolder.ivIcon = (ImageView) convertView.findViewById(R.id.ivIcon);
            viewHolder.tvTitle = (TextView) convertView.findViewById(R.id.tvTitle);
            viewHolder.tvDescription = (TextView) convertView.findViewById(R.id.tvDescription);


            convertView.setTag(viewHolder);
        } else {
            // recycle the already inflated view 
            viewHolder = (ViewHolder) convertView.getTag();
        }
        
        // update the item view
        final ListViewItem item = getItem(position);
        viewHolder.ivIcon.setImageDrawable(item.icon);
        viewHolder.tvDescription.setText(item.description);
        if(position == 3) {
            viewHolder.switchToggle = (Switch) convertView.findViewById(R.id.switchToggle);
            System.out.println("Value of Sensor Show " + item.sensorShow);
            Boolean tempBoolean = item.sensorSwitch;
            System.out.println("Value of Boolean " + tempBoolean);
            if(tempBoolean == null){
                System.out.println("Disabled");
                viewHolder.switchToggle.setClickable(false);
                viewHolder.tvTitle.setText("Sensor is Disabled");
            }
            else if (!tempBoolean){
                System.out.println("Value of Flse");
                viewHolder.switchToggle.setChecked(false);
                viewHolder.tvTitle.setText("Sensor is Off");
            }
            else{

                System.out.println("Val of True");
                viewHolder.switchToggle.setChecked(true);
                viewHolder.tvTitle.setText("Sensor is On");
            }

            viewHolder.switchToggle.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if(isChecked) {
                        viewHolder.tvTitle.setText("Sensor is On");  //To change the text near to switch
                        Amplitude.getInstance().logEvent("SettingsFragment_Calibrate");
                        //Calibrate start, start:now, finish:today+1day
                        raceAuth = new RaceCalibration();
                        String url = "https://trac-us.appspot.com/api/sessions/"+sessionPrimaryKey+"/open/?access_token=" + storedToken;

                        raceAuth.execute(url);

                    }
                    else {
                        viewHolder.tvTitle.setText("Sensor is Off");  //To change the text near to switch
                        Amplitude.getInstance().logEvent("SettingsFragment_End");
                        raceStop = new RaceStop();
                        String url = "https://trac-us.appspot.com/api/sessions/"+sessionPrimaryKey+"/close/?access_token=" + storedToken;
                        raceStop.execute(url);

                    }

                }
            });
        }
        else
        {
            viewHolder.switchToggle = (Switch) convertView.findViewById(R.id.switchToggle);
            viewHolder.switchToggle.setVisibility(View.GONE);
            viewHolder.tvTitle.setText(item.title);
        }

        //viewHolder.switchToggle.;
        
        return convertView;
    }

    public void passToken(String token, String primaryKey){
        storedToken = token;
        sessionPrimaryKey = primaryKey;

    }
    
    /**
     * The view holder design pattern prevents using findViewById()
     * repeatedly in the getView() method of the adapter.
     * 
     * @see http://developer.android.com/training/improving-layouts/smooth-scrolling.html#ViewHolder
     */
    private static class ViewHolder {
        ImageView ivIcon;
        TextView tvTitle;
        TextView tvDescription;
        Switch switchToggle;
    }
}
