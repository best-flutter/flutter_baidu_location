import 'package:flutter/material.dart';
import 'package:baidu_location/baidu_location.dart';
import 'package:easy_alert/easy_alert.dart';


void main() {
  /*============*/
  //设置ios的key
  /*=============*/
  BaiduLocationClient.setApiKey("GyaWxHbTTss1ctrid8Dxy5fipZIDSaNh");
  /*============*/
  //设置ios的key
  /*=============*/

  runApp(new AlertProvider(
    child: new MaterialApp(
      home: new Home(),
      routes: {
        "/location/get": (BuildContext context) => new LocationGet(),
        "/location/listen": (BuildContext content) => new LocationListen()
      },
    ),
  ));
}

class _LocationGetState extends State {


  BaiduLocation _loc;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('直接获取定位'),
        ),
        body: new Center(
          child:  _loc == null ? new Text("正在定位") : new Text("定位成功:${getLocationStr(_loc)}"),
        )
    );
  }

  void _checkPersmission() async{
//    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
//    bool hasPermission = permission == PermissionStatus.granted;
//    if(!hasPermission){
//      Map<PermissionGroup, PermissionStatus> map = await PermissionHandler().requestPermissions([
//        PermissionGroup.location
//      ]);
//      if(map.values.toList()[0] != PermissionStatus.granted){
//        Alert.alert(context,title: "申请定位权限失败");
//        return;
//      }
//    }
    BaiduLocation loc = await BaiduLocationClient.getLocation();
    setState(() {
      _loc = loc;
    });
  }

  @override
  void initState() {
    _checkPersmission();
    super.initState();
  }

  @override
  void dispose() {
    //这里可以停止定位
    //AMapLocationClient.stopLocation();

    super.dispose();
  }
}

class LocationGet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LocationGetState();
}

String getLocationStr(BaiduLocation loc) {
  if (loc == null) {
    return "正在定位";
  }

  if (loc.isSuccess()) {
    if (loc.hasAddress()) {
      return "定位成功: \n时间${loc.time}\n经纬度:${loc.latitude} ${loc.longitude}\n 地址:${loc.address} 城市:${loc.city} 省:${loc.province}";
    } else {
      return "定位成功: \n时间${loc.time}\n经纬度:${loc.latitude} ${loc.longitude}\n ";
    }
  } else {
    return "定位失败: \n错误:";
  }
}

class _LocationListenState extends State {
  String location;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('监听定位改变'),
        ),
        body: new Center(
          child: new Text(location),
        ));
  }
  void _checkPersmission() async{
//    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
//    bool hasPermission = permission == PermissionStatus.granted;
//    if(!hasPermission){
//      Map<PermissionGroup, PermissionStatus> map = await PermissionHandler().requestPermissions([
//        PermissionGroup.location
//      ]);
//      if(map.values.toList()[0] != PermissionStatus.granted){
//        Alert.alert(context,title: "申请定位权限失败");
//        return;
//      }
//    }
    BaiduLocationClient.onLocationUpate.listen((BaiduLocation loc) {
      if (!mounted) return;
      setState(() {
        location = getLocationStr(loc);
      });
    });


    BaiduLocationClient.startLocation();
  }
  @override
  void initState() {
    location = getLocationStr(null);
    _checkPersmission();

    super.initState();
  }

  @override
  void dispose() {
    //注意这里停止监听
    BaiduLocationClient.stopLocation();
    super.dispose();
  }
}

class LocationListen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LocationListenState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    //启动客户端,这里设置ios端的精度小一点
//    AMapLocationClient.startup(new AMapLocationOption(
//   desiredAccuracy: CLLocationAccuracy.kCLLocationAccuracyHundredMeters));
    super.initState();
  }

  @override
  void dispose() {

    //注意这里关闭
  //  AMapLocationClient.shutdown();
    super.dispose();
  }

  List<Widget> render(BuildContext context, List children) {
    return ListTile.divideTiles(
        context: context,
        tiles: children.map((dynamic data) {
          return buildListTile(
              context, data["title"], data["subtitle"], data["url"]);
        })).toList();
  }

  Widget buildListTile(
      BuildContext context, String title, String subtitle, String url) {
    return new ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(url);
      },
      isThreeLine: true,
      dense: false,
      leading: null,
      title: new Text(title),
      subtitle: new Text(subtitle),
      trailing: new Icon(
        Icons.arrow_right,
        color: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('百度地图定位'),
        ),
        body: new Scrollbar(
            child: new ListView(
              children: render(context, [
                {
                  "title": "直接获取定位",
                  "subtitle": "不需要先启用监听就可以直接获取定位",
                  "url": "/location/get"
                },
                {"title": "监听定位", "subtitle": "启动定位改变监听", "url": "/location/listen"}
              ]),
            )));
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomeState();
  }
}
