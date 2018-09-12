package com.github.jzoom.baidulocation;

import android.app.Activity;
import android.location.LocationManager;

import com.baidu.location.BDAbstractLocationListener;
import com.baidu.location.BDLocation;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** BaiduLocationPlugin */
public class BaiduLocationPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "baidu_location");
    channel.setMethodCallHandler(new BaiduLocationPlugin(registrar.activity(),channel));
  }



  private Activity activity;
  private LocationManager mSysLocManager;
  private MethodChannel channel;

  public BaiduLocationPlugin(Activity activity,MethodChannel channel) {
    this.activity = activity;
    this.channel = channel;
  }


  private static LocationClientOption defaultLocOption() {
    final LocationClientOption mOption = new LocationClientOption();
    mOption.setLocationMode(LocationClientOption.LocationMode.Hight_Accuracy);//可选，默认高精度，设置定位模式，高精度，低功耗，仅设备
    mOption.setCoorType("bd09ll");//可选，默认gcj02，设置返回的定位结果坐标系，如果配合百度地图使用，建议设置为bd09ll;
    mOption.setScanSpan(0);//可选，默认0，即仅定位一次，设置发起定位请求的间隔需要大于等于1000ms才是有效的
    mOption.setIsNeedAddress(true);//可选，设置是否需要地址信息，默认不需要
    mOption.setOpenGps(true); // 可选，默认false,设置是否使用gps
    mOption.setNeedDeviceDirect(false);//可选，设置是否需要设备方向结果
    mOption.setLocationNotify(false);//可选，默认false，设置是否当gps有效时按照1S1次频率输出GPS结果
    mOption.setIgnoreKillProcess(true);//可选，默认true，定位SDK内部是一个SERVICE，并放到了独立进程，设置是否在stop的时候杀死这个进程，默认不杀死
    mOption.setIsNeedLocationDescribe(true);//可选，默认false，设置是否需要位置语义化结果，可以在BDLocation.getLocationDescribe里得到，结果类似于“在北京天安门附近”
    mOption.setIsNeedLocationPoiList(false);//可选，默认false，设置是否需要POI结果，可以在BDLocation.getPoiList里得到
    mOption.SetIgnoreCacheException(false);//可选，默认false，设置是否收集CRASH信息，默认收集
    return mOption;
  }


  private LocationClient mClient;

  private BDAbstractLocationListener listener;

  private synchronized void initClient(BDAbstractLocationListener listener){
    if(mClient==null){
      // 定位初始化
      mClient = new LocationClient(activity);
      mClient.registerLocationListener(listener);
    }

    this.listener = listener;

    LocationClientOption mOption = defaultLocOption();
    mClient.setLocOption(mOption);
    mClient.start();
  }

  private  synchronized void destroyClient(){
    if(mClient!=null){
      assert (listener!=null);
      mClient.unRegisterLocationListener(listener);
      mClient.stop();
      mClient = null;
    }
  }

  @Override
  public synchronized void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("setKey")) {
        result.success(true);
    }  else if (call.method.equals("getLocation")) {
      initClient(new OnceLocationListener(result));
    }  else if (call.method.equals("startLocation")) {
      initClient(new ListeningLocationListener());
      result.success(true);
    } else if (call.method.equals("stopLocation")) {
      destroyClient();
      result.success(true);
    } else {
      result.notImplemented();
    }
  }


  Map<String,Object> location2map(BDLocation location){
    Map<String,Object> json = new HashMap<>();
    json.put("time", location.getTime());
    json.put("locType", location.getLocType());
    json.put("locationDescribe", location.getLocationDescribe());
    json.put("latitude", location.getLatitude());
    json.put("longitude", location.getLongitude());
    json.put("radius", location.getRadius());
    json.put("countryCode", location.getCountryCode());
    json.put("country", location.getCountry());
    json.put("cityCode", location.getCityCode());
    json.put("city", location.getCity());
    json.put("district", location.getDistrict());
    json.put("street", location.getStreet());
    json.put("address", location.getAddrStr());
    json.put("province", location.getProvince());
    json.put("direction", location.getDirection());
    return json;
  }

  class OnceLocationListener extends BDAbstractLocationListener {
    Result result;

    OnceLocationListener(Result result) {
      this.result = result;
    }

    @Override
    public synchronized void onReceiveLocation(BDLocation location) {
      if (location == null) {
        return;
      }
      try {
        //为了防止万一，谨慎一点比较好,重复调用就挂了
        if(result!=null){
          result.success(location2map(location));
        }
      } finally {
        destroyClient();
        result = null;
      }
    }
  }
  class ListeningLocationListener extends BDAbstractLocationListener {

    ListeningLocationListener() {
    }

    @Override
    public void onReceiveLocation(BDLocation location) {
      if (location == null) {
        return;
      }
      channel.invokeMethod("updateLocation",location2map(location));
    }
  }

}
