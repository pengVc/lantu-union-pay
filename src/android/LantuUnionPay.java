package com.lantu.cordova.lantuUnionPay;

import android.content.Intent;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.unionpay.UPPayAssistEx;

/**
 * This class echoes a string called from JavaScript.
 */
public class LantuUnionPay extends CordovaPlugin {

    private CallbackContext currentCallbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if (action.equals("pay")) {
            String jsonMsg = args.getString(0);
            JSONObject payInfo = new JSONObject(jsonMsg);
            this.pay(payInfo, callbackContext);
            return true;
        }

        return false;
    }

    private void pay(JSONObject payInfo, CallbackContext callbackContext) throws JSONException {

        this.currentCallbackContext = callbackContext;

        String tn = payInfo.getString("tn");
        String mode = payInfo.getString("mode");

        LOG.d("支付数据:",
            "\ntn" + tn +
                "\nmode" + mode
        );

        cordova.setActivityResultCallback(this);
        UPPayAssistEx.startPay(cordova.getActivity(), null, null, tn, mode);

    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        super.onActivityResult(requestCode, resultCode, data);

        if (data == null) {
            return;
        }

        String payResult;

        try {
            payResult = data.getExtras().getString("pay_result");
        }catch (NullPointerException e){
            payResult = "";
        }

        JSONObject pluginResultInfo = new JSONObject();

        try {
            pluginResultInfo.put("code", payResult.toLowerCase());
        } catch (JSONException e) {
            e.printStackTrace();
        }

        if (payResult.equalsIgnoreCase("success")) {

            try {
                pluginResultInfo.put("msg", "支付成功");

                if(data.hasExtra("result_data")){
                    pluginResultInfo.put("successExtraData", data.getExtras().getString("result_data"));
                }

            } catch (JSONException e) {
                e.printStackTrace();
            }

            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, pluginResultInfo);
            this.currentCallbackContext.sendPluginResult(pluginResult);

        } else if (payResult.equalsIgnoreCase("fail")) {

            try {
                pluginResultInfo.put("msg", "支付失败");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, pluginResultInfo);
            this.currentCallbackContext.sendPluginResult(pluginResult);

        } else if (payResult.equalsIgnoreCase("cancel")) {

            try {
                pluginResultInfo.put("msg", "支付取消");
            } catch (JSONException e) {
                e.printStackTrace();
            }

            PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, pluginResultInfo);
            this.currentCallbackContext.sendPluginResult(pluginResult);

        }

    }

}
