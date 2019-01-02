import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'animation',
      home: Scaffold(
        appBar: AppBar(
          title: Text('animation'),
        ),
        body: AnimWidget(),
      ),
    );
  }
}

//线性动画
class AnimWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AnimWidgetState();
  }
}

class _AnimWidgetState extends State<AnimWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation curve;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 5000),
      vsync: this,
    );
    curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    controller.forward();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var scaled = ScaleTransition(
      child: FlutterLogo(size: 200.0,),
      scale: curve,
    );
    return FadeTransition(
      child: scaled,
      opacity: curve,
    );
  }
}
