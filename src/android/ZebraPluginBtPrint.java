package zebra_plugin_btprint;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.os.Handler;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONException;

import java.util.UUID;

public class BtPrint extends CordovaPlugin {
    private static String LOG_TAG = "BluetoothPrint";

    private BluetoothAdapter bluetoothAdapter;

    private long turnBluetoothOffDelay = 0;
    private Handler turnBluetoothOffHandler;
    private Runnable turnBluetoothOffRunnable;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        Log.i(LOG_TAG, "initialize");

        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        turnBluetoothOffHandler = new Handler();

        turnBluetoothOffRunnable = new Runnable() {
            @Override
            public void run() {
                Log.i(LOG_TAG, "Disabling bluetooth");

                try {
                    bluetoothAdapter.disable();
                } catch (Exception x) {
                    Log.e(LOG_TAG, "Unable to disable bluetooth off", x);
                }
            }
        };
    }

    @Override
    public void onResume(boolean multitasking) {
        // Log.i(LOG_TAG, "onResume(" + multitasking + ")");
    }

    @Override
    public void onPause(boolean multitasking) {
        // Log.i(LOG_TAG, "onPause(" + multitasking + ")");

        turnBluetoothOffHandler.removeCallbacks(turnBluetoothOffRunnable);
    }

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {

        if ("initialize".equals(action)) {
            try {
                turnBluetoothOffDelay = args.getLong(0);
            } catch (Exception x) {

            }

            Log.i(LOG_TAG, "Delay: " + turnBluetoothOffDelay);

            callbackContext.success();

            return true;
        } else if ("print".equals(action)) {
            String mac = args.getString(0);
            String data = args.getString(1);

            Log.i(LOG_TAG, "Printing to: " + mac);

            print(mac, data, callbackContext);

            return true;
        }

        return false;
    }

    private void print(final String mac, final String data, final CallbackContext callbackContext) {
        turnBluetoothOffHandler.removeCallbacks(turnBluetoothOffRunnable);

        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {

                BluetoothSocket socket = null;

                try {
                    String channelId = "00001101-0000-1000-8000-00805F9B34FB";

                    // enable bluetooth if disabled
                    if (bluetoothAdapter.getState() != BluetoothAdapter.STATE_ON) {
                        Log.i(LOG_TAG, "Bluetooth is disabled, enabling");
                        bluetoothAdapter.enable();

                        long startTime = System.currentTimeMillis();

                        while (bluetoothAdapter.getState() != BluetoothAdapter.STATE_ON) {
                            Thread.sleep(100);

                            // try to enable for 10 seconds
                            if (System.currentTimeMillis() - startTime > 10000) {
                                throw new Exception("Unable to enable bluetooth");
                            }
                        }

                        // just wait a little after bluetooth is enabled
                        Thread.sleep(250);

                        Log.i(LOG_TAG, "Bluetooth successfully enabled");
                    }

                    BluetoothDevice device = bluetoothAdapter.getRemoteDevice(mac);

                    socket = device.createInsecureRfcommSocketToServiceRecord(UUID.fromString(channelId));

                    socket.connect();

                    socket.getOutputStream().write(data.getBytes());

                    socket.getOutputStream().flush();

                    Thread.sleep(500);

                    callbackContext.success("ok");
                } catch (Exception x) {
                    Log.e(LOG_TAG, "Unable to print", x);

                    callbackContext.error(x.getMessage());
                } finally {
                    if (socket != null) {
                        try {
                            socket.close();
                        } catch (Exception x) {
                            Log.d(LOG_TAG, "Unable to close socket", x);
                        }
                    }

                    if (turnBluetoothOffDelay > 0) {
                        Log.d(LOG_TAG, "Disabling bluetooth in " + turnBluetoothOffDelay / 1000 + "s");

                        turnBluetoothOffHandler.postDelayed(turnBluetoothOffRunnable, turnBluetoothOffDelay);
                    }
                }
            }
        });
    }
}