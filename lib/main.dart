import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      //移动设备使用这个title来表示我们的应用，具体一点说就是在Android设备里面，我们点击recent按钮打开应用列表的时候，显示的这个title
      title: "Our first Flutter app",

      //应用的"主页"
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter rolling demo"),
        ),
        //我们知道在Flutter里面，所有的东西都是控件，
        body: Center(
          child: RaisedButton(
            //用户的点击事件
            child: RollingButton(),
          ),
        ),
      ),
    );
  }
}

class RollingButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RollingState();
  }
}

class _RollingState extends State<RollingButton> {
  final _random = Random();

  List<int> _roll() {
    final roll1 = _random.nextInt(6) + 1;
    final roll2 = _random.nextInt(6) + 1;
    return [roll1, roll2];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RaisedButton(
      child: Text('Roll'),
      onPressed: _onPressed,
    );
  }

  void _onPressed() {
    debugPrint('_onPressed');
    final rollResults = _roll();
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text('Roll result: (${rollResults[0]},${rollResults[1]})'),
          );
        });
  }
}
