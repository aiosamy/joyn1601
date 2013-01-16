package sh.calaba.instrumentationbackend.actions.specific;

import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.List;

import sh.calaba.instrumentationbackend.InstrumentationBackend;
import sh.calaba.instrumentationbackend.Result;
import sh.calaba.instrumentationbackend.TestHelpers;
import sh.calaba.instrumentationbackend.actions.Action;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.ImageView;
import android.view.ViewGroup;
import android.graphics.Rect;

public class isJoynCheckBoxPresent implements Action {

	
    @Override
    public Result execute(String... args) {
Result r = new Result(true);
String output="";

        try {

  	ListView listView = InstrumentationBackend.solo.getCurrentListViews().get(0);
    	int childPos = listView.getCount() - 1;

	View LastLayoutRow = null;
	// find last visible list item
	for (int i=0;i< listView.getCount() ; i++)
	{
	    	View mostActualRow = listView.getChildAt(i);
    	
		if(mostActualRow!=null)
		{
		LastLayoutRow = mostActualRow;
		}
	}

	View xx=LastLayoutRow;
	View vv = ((ViewGroup )LastLayoutRow).getChildAt(0);
	if(vv!=null)
	{	
	output += " XXXXX view id: " + vv.getClass().getSimpleName();
		xx=vv;

int childCount = ((ViewGroup )xx).getChildCount();
for(int i = 0; i < childCount; i++) {
    View v = ((ViewGroup )xx).getChildAt(i);
    // do whatever you want to with the view
	if(v!=null)
	{
		output += " | *** HH = " + i + " Name: " + v.getClass().getSimpleName() + " *** |" ;
		if (v instanceof TextView)
		output += " | *** TEXT VIEW TEXT: " + ((TextView)v).getText() + " *** |" ;
		if (v instanceof ImageView)
{
		output += " | " 
			+ ((ImageView)v). getBaseline() + " |" 
                      + ((ImageView)v).getDrawable() + " |"
 + ((ImageView)v).getContentDescription() + " |"

 + ((ImageView)v).getHeight() + " |"
 + ((ImageView)v).getLeft() + " |"
 	+ ((ImageView)v).getMeasuredWidth() + " |"
+ ((ImageView)v).getTag() + " |"
+ ((ImageView)v).getVisibility() + " |"
+ ((ImageView)v).getWindowVisibility() + " |"
+ ((ImageView)v).isEnabled() + " |"
+ ((ImageView)v).isShown() + " |"
				+ ((View)v).getBottom() + " |" 
	+ ((ImageView)v).getId() + " |" 

;



}
	}
}






 		vv = ((ViewGroup )vv).getChildAt(2);
 		output += " TEXTID " + ((ViewGroup )xx).getChildAt(0).getClass().getSimpleName();
		output += " TIME " + ((TextView) ((ViewGroup )xx).getChildAt(0)).getText();
	
	}
	else 
	output += " NOT FOUND VVVVV view id: " + vv.getClass().getSimpleName();

if (vv!= null && vv instanceof ImageView && ((ImageView)vv).isShown())
{
	r = new Result(true);
 	//output += "FOUND view id: " + vv.getClass().getSimpleName()  + vv.getVisibility() + " FOUND";
	output="FOUND";
}
else
	output = "NOT-F";



        /*if(IsCheckBoxVisible())
    		output="Found";*/

	r.addBonusInformation(output);
        return r;
       }
       catch (Exception e) {
                System.out.println("Got an Exception: " + e.getMessage() + " OUTPUT: " + output );
		r.addBonusInformation("Got an Exception: " + e.getMessage() + " OUTPUT: " + output );
		return r;
            }
	
    }
    
   
    @Override
    public String key() {
        return "isJoynCheckBoxPresent";
    }
}