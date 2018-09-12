import 'dart:async';

import 'package:flutter/services.dart';


class BaiduLocation{
  final String time;
  final String locationDescribe;
  final int locType;
  final double latitude;
  final double longitude;
  final double radius;
  final String countryCode;
  final String country;
  final String cityCode;
  final String city;
  final String district;
  final String street;
  final String address;
  final String province;
  final double direction;

  BaiduLocation({this.time, this.locationDescribe, this.locType,
      this.latitude, this.longitude, this.radius, this.countryCode,
      this.country, this.cityCode, this.city, this.district, this.street,
      this.address, this.province, this.direction});

  factory BaiduLocation.fromMap(dynamic value){
    return new BaiduLocation(

    );
  }

}

class BaiduLocationClient {


  static StreamController<BaiduLocation> _locationUpdateStreamController = new StreamController.broadcast();
  /// 定位改变监听
  static Stream<BaiduLocation> get onLocationUpate =>
      _locationUpdateStreamController.stream;


  static bool _init = false;

  static const MethodChannel _channel =
      const MethodChannel('baidu_location');

  static Future<bool> setApiKey(String key) async{
    //这里的key设置错误，百度地图很恶心的居然没有回调，那么用超时来解决
    var value = await _channel.invokeMethod('setKey');
    return value as bool;
  }

  static void _privateInit(){
    if(!_init){
      _init = true;
      _channel.setMethodCallHandler(handler);
    }
  }

  /// 在整个应用程序退出的时候调用
  static void shutdown(){
    _locationUpdateStreamController.close();
  }

  /// 开始定位，在定位收到之后就会有监听
  static Future<bool> startLocation() async {
    _privateInit();
    var value = await _channel.invokeMethod('startLocation');
    return value as bool;
  }

  /// 这个方法无须监听直接获取到定位，但是不能在正在定位的时候使用。
  static Future<BaiduLocation> getLocation() async {
    _privateInit();
    var value = await _channel.invokeMethod('getLocation');
    return new BaiduLocation.fromMap(value);
  }


  /// 关闭定位，不要忘记在程序退出的时候关闭
  static Future<bool> stopLocation() async{
    var value = await _channel.invokeMethod('stopLocation');
    return value as bool;
  }


  static Future<dynamic> handler(MethodCall call) {
    String method = call.method;

    switch (method) {
      case "updateLocation":
        {
          Map args = call.arguments;
          _locationUpdateStreamController.add(BaiduLocation.fromMap(args));
        }
        break;
    }
    return new Future.value("");
  }


}
