package com.xgs.flutter_live;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

import androidx.annotation.Nullable;

/**
 * Created  on 2019/10/12.
 *
 * @author grey
 */
public class TestActivity extends Activity {

    TextView fullerTextView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.a_test);

        fullerTextView = findViewById(R.id.flutterText);

        String flutterTest = "未有接受到参数";
        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            String userName = bundle.getString("userName");
            String userNum = bundle.getString("userNum");
            String userAvatar = bundle.getString("userAvatar");
            String sign = bundle.getString("sign");
            String roomId = bundle.getString("roomId");
            flutterTest =
                    "接受Flutter数据："
                            + "\nuserName = " + userName
                            + "\nuserNum = " + userNum
                            + "\nuserAvatar = " + userAvatar
                            + "\nsign = " + sign
                            + "\nroomId = " + roomId;
        }

        fullerTextView.setText(flutterTest);
    }
}
