package com.example.airvision_app;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

import androidx.annotation.NonNull;

import java.util.Arrays;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements SensorEventListener {

    private static final String CHANNEL = "airvision/orientation";

    private SensorManager sensorManager;
    private Sensor rotationSensor;
    private boolean running;

    private final float[] quaternion = new float[4];

    public MainActivity() {
        // Initialize as identity quaternion
        this.quaternion[3] = 1;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        this.sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        this.rotationSensor = this.sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "getQuaternion":
                                    getQuaternion(result);
                                    break;
                                case "start":
                                    start(result);
                                    break;
                                case "stop":
                                    stop(result);
                                    break;
                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }
                );
    }

    private void getQuaternion(@NonNull MethodChannel.Result result) {
        final double[] quaternion = new double[this.quaternion.length];
        for (int i = 0; i < quaternion.length; i++) {
            quaternion[i] = this.quaternion[i];
        }
        result.success(quaternion);
    }

    private void start(@NonNull MethodChannel.Result result) {
        if (this.running) {
            result.success(false);
            return;
        }
        this.running = this.sensorManager.registerListener(this,
                this.rotationSensor, SensorManager.SENSOR_DELAY_NORMAL);
        result.success(this.running);
    }

    private void stop(@NonNull MethodChannel.Result result) {
        if (!this.running) {
            result.success(false);
            return;
        }
        this.running = false;
        this.sensorManager.unregisterListener(this);
        result.success(true);
    }

    @Override
    public void onSensorChanged(@NonNull SensorEvent event) {
        final float[] quaternionWXYZ = new float[4];
        SensorManager.getQuaternionFromVector(quaternionWXYZ, event.values);

        this.quaternion[0] = quaternionWXYZ[1];
        this.quaternion[1] = quaternionWXYZ[2];
        this.quaternion[2] = quaternionWXYZ[3];
        this.quaternion[3] = quaternionWXYZ[0];
    }

    @Override
    public void onAccuracyChanged(@NonNull Sensor sensor, int accuracy) {
    }
}
