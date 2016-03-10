package com.trac.tracdroid;

import android.graphics.drawable.Drawable;

public class ListViewItem {
    public final Drawable icon;       // the drawable for the ListView item ImageView
    public final String title;        // the text for the ListView item title
    public final String description;  // the text for the ListView item description
    public final Boolean sensorSwitch;
    public final Boolean sensorShow;
    
    public ListViewItem(Drawable icon, String title, String description, Boolean sensorSwitch, Boolean sensorShow) {
        this.icon = icon;
        this.title = title;
        this.description = description;
        this.sensorSwitch = sensorSwitch;
        this.sensorShow = sensorShow;
    }
}