package com.example.airvision_app;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.util.SizeF;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements SensorEventListener {

    private static final String CHANNEL_PREFIX = "airvision/";
    private static final String ORIENTATION_CHANNEL = CHANNEL_PREFIX + "orientation";
    private static final String CAMERA_CHANNEL = CHANNEL_PREFIX + "camera";

    private CameraManager cameraManager;
    private SensorManager sensorManager;
    private Sensor rotationSensor;
    private boolean running;

    private double estimatedSensorAccuracy = -1;
    private final float[] quaternionWXYZ = new float[4];

    public MainActivity() {
        // Initialize as identity quaternion
        this.quaternionWXYZ[0] = 1;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        this.cameraManager = (CameraManager) getSystemService(CAMERA_SERVICE);
        this.sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        this.rotationSensor = this.sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CAMERA_CHANNEL)
                .setMethodCallHandler(this::handleCameraChannel);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), ORIENTATION_CHANNEL)
                .setMethodCallHandler(this::handleOrientationChannel);
    }

    private void handleCameraChannel(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getFov":
                getCameraFov(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void getCameraFov(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final String name = call.arguments();

        try {
            // https://stackoverflow.com/questions/39965408/what-is-the-android-camera2-api-equivalent-of-camera-parameters-gethorizontalvie

            final CameraCharacteristics info = this.cameraManager.getCameraCharacteristics(name);
            final SizeF sensorSize = info.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE);
            final float[] focalLengths = info.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS);
            if (sensorSize == null || focalLengths == null)
                throw new IllegalStateException("Essential camera info isn't available.");
            // TODO: What to do if there are multiple focal lengths?
            final float focalLength = focalLengths[0];

            // Short edge of the screen
            final double x = Math.min(sensorSize.getHeight(), sensorSize.getWidth());
            // Longest edge of the screen
            final double y = Math.max(sensorSize.getHeight(), sensorSize.getWidth());

            final double[] fov = new double[2];
            fov[0] = Math.toDegrees(2 * Math.atan(x / (2 * focalLength)));
            fov[1] = Math.toDegrees(2 * Math.atan(y / (2 * focalLength)));

            result.success(fov);
        } catch (CameraAccessException e) {
            throw throwUnchecked(e);
        }
    }

    private void handleOrientationChannel(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getQuaternion":
                getOrientationQuaternion(result);
                break;
            case "getEstimatedAccuracy":
                getEstimatedAccuracy(result);
                break;
            case "start":
                startOrientationService(result);
                break;
            case "stop":
                stopOrientationService(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void getOrientationQuaternion(@NonNull MethodChannel.Result result) {
        final double[] quaternion = new double[4];
        quaternion[0] = this.quaternionWXYZ[1];
        quaternion[1] = this.quaternionWXYZ[2];
        quaternion[2] = this.quaternionWXYZ[3];
        quaternion[3] = this.quaternionWXYZ[0];
        result.success(quaternion);
    }

    private void getEstimatedAccuracy(@NonNull MethodChannel.Result result) {
        result.success(this.estimatedSensorAccuracy);
    }

    private void startOrientationService(@NonNull MethodChannel.Result result) {
        if (this.running) {
            result.success(false);
            return;
        }
        this.running = this.sensorManager.registerListener(this,
                this.rotationSensor, SensorManager.SENSOR_DELAY_NORMAL);
        result.success(this.running);
    }

    private void stopOrientationService(@NonNull MethodChannel.Result result) {
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
        SensorManager.getQuaternionFromVector(this.quaternionWXYZ, event.values);

        if (event.values.length >= 4) {
            final double accuracy = event.values[3];
            this.estimatedSensorAccuracy = accuracy == -1 ? -1 : Math.toDegrees(accuracy);
        }
    }

    @Override
    public void onAccuracyChanged(@NonNull Sensor sensor, int accuracy) {
    }

    /**
     * Throws the {@link Throwable} as an unchecked exception.
     *
     * @param t The throwable to throw
     * @return A runtime exception
     */
    private static @NonNull RuntimeException throwUnchecked(@NonNull Throwable t) {
        throwUnchecked0(t);
        throw new AssertionError("Unreachable.");
    }

    @SuppressWarnings("unchecked")
    private static <T extends Throwable> void throwUnchecked0(@NonNull Throwable t) throws T {
        throw (T) t;
    }
}
