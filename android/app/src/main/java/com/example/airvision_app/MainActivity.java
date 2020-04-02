package com.example.airvision_app;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.os.PersistableBundle;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.IntStream;


public class MainActivity extends FlutterActivity implements SensorEventListener {
    private static final String CHANNEL = "airvision/orientation";

    private SensorManager mSensorManager;
    private Sensor mAccelerometer;
    private Sensor mMagnetometer;
    private Sensor mRotationSensor;

    private float[] currentOrientationRotationMatrix = new float[16];

    private float[] mLastAccelerometer = new float[3];
    private float[] mLastMagnetometer = new float[3];
    private boolean mLastAccelerometerSet = false;
    private boolean mLastMagnetometerSet = false;

    private float[] mR = new float[9];
    private float[] mOrientation = new float[3];
    private float[] mQuaterion = new float[4]; // = output



    @Override
    public void onCreate(@Nullable Bundle savedInstanceState, @Nullable PersistableBundle persistentState) {
        super.onCreate(savedInstanceState, persistentState);
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        mSensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        mMagnetometer = mSensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
        mRotationSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            switch (call.method) {
                                case "getDeviceOrientation":
                                    if (mQuaterion != null) {
                                        double[] output = new double[mQuaterion.length];
                                        for (int i = 0; i < mQuaterion.length; i++) {
                                            output[i] = mQuaterion[i];
                                        }
                                        result.success(output);
                                    } else {
                                        result.error("UNAVAILABLE", "Devices orientation not available.", null);
                                    }
                                    break;
                                case "startListeningDeviceOrientation":
                                    mLastAccelerometerSet = false;
                                    mLastMagnetometerSet = false;
                                    mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_FASTEST);
                                    mSensorManager.registerListener(this, mMagnetometer, SensorManager.SENSOR_DELAY_FASTEST);
                                    mSensorManager.registerListener(this, mRotationSensor, SensorManager.SENSOR_DELAY_FASTEST);
                                    break;
                                case "stopListeningDeviceOrientation":
                                    mSensorManager.unregisterListener(this);
                                    break;
                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }
                );
    }


//    @Override
//    public void onSensorChanged(SensorEvent event) {
//        if (event.sensor == mAccelerometer) {
//            System.arraycopy(event.values, 0, mLastAccelerometer, 0, event.values.length);
//            mLastAccelerometerSet = true;
//        } else if (event.sensor == mMagnetometer) {
//            System.arraycopy(event.values, 0, mLastMagnetometer, 0, event.values.length);
//            mLastMagnetometerSet = true;
//        }
//        if (mLastAccelerometerSet && mLastMagnetometerSet) {
//            SensorManager.getRotationMatrix(mR, null, mLastAccelerometer, mLastMagnetometer);
//            SensorManager.getOrientation(mR, mOrientation);
//        }
//    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        // we received a sensor event. it is a good practice to check
        // that we received the proper event
        if (event.sensor.getType() == Sensor.TYPE_ROTATION_VECTOR) {
            // convert the rotation-vector to a 4x4 matrix. the matrix
            // is interpreted by Open GL as the inverse of the
            // rotation-vector, which is what we want.
//            SensorManager.getRotationMatrixFromVector(currentOrientationRotationMatrix.matrix, event.values);

            // Get Quaternion
            // Calculate angle. Starting with API_18, Android will provide this value as event.values[3], but if not, we have to calculate it manually.
//            SensorManager.getQuaternionFromVector(temporaryQuaternion, event.values);
//            currentOrientationQuaternion.setXYZW(temporaryQuaternion[1], temporaryQuaternion[2], temporaryQuaternion[3], -temporaryQuaternion[0]);

            float[] quaterionWXYZ = new float[4];
            SensorManager.getQuaternionFromVector(quaterionWXYZ, event.values);

            mQuaterion[0] = quaterionWXYZ[1];
            mQuaterion[1] = quaterionWXYZ[2];
            mQuaterion[2] = quaterionWXYZ[3];
            mQuaterion[3] = quaterionWXYZ[0];

        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }
}
