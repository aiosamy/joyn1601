package sh.calaba.instrumentationbackend.actions.specific;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.Context;
import android.os.Bundle;

import sh.calaba.instrumentationbackend.InstrumentationBackend;
import sh.calaba.instrumentationbackend.Result;
import sh.calaba.instrumentationbackend.actions.Action;


import com.jayway.android.robotium.solo.Solo;

public class ClearNotifications implements Action {

    @Override
    public Result execute(String... args) {

        System.out.println("************************** ClearNotifications started ");
        
///TODO please use Context.NOTIFICATION_SERVICE 
Solo solo = InstrumentationBackend.solo;
NotificationManager notificationManager = (NotificationManager) solo.getCurrentActivity().getSystemService(Context.NOTIFICATION_SERVICE);
	//NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
	if(null==notificationManager)
	        System.out.println("************************** ClearNotifications NULL NULL NULL");
	else	
	notificationManager.cancelAll();
 

        System.out.println("************************** ClearNotifications ending ");
	return Result.successResult();
    }

    @Override
    public String key() {
        return "clear_notification";
    }

}
