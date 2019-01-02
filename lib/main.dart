import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter animation demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Animation'),
        ),
        body: AnimationDemoView(),
      ),
    );
  }
}

class AnimationDemoView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AnimationState();
  }
}

class _AnimationState extends State<AnimationDemoView>
    with SingleTickerProviderStateMixin {
  static const padding = 16.0;

  AnimationController controller;
  Animation<double> left;
  Animation<Color> color;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //只有在initState执行完，我们才能通过MediaQuery.of(context)获取mediaQueryData。
    //这里通过创建一个Future从而在Dart事件队列里插入一个事件，以达到延迟执行的目的(类似于在Android中post一个Runable)
    Future(_initState);
  }

  void _initState() {
    controller = AnimationController(
        //注意类定义的 with SingleTickerProviderStateMixin，提供 vsync 最简单的方法
        //就是继承一个SingleTickerProviderStateMixin。这里的vsync跟Android里的vsync类似
        vsync: this,
        duration: const Duration(milliseconds: 2000));
    color = ColorTween(begin: Colors.red, end: Colors.blue).animate(controller);
    //我们通过MediaQuery获取屏幕的宽度
    final mediaQueryData = MediaQuery.of(context);
    var displayWidth = mediaQueryData.size.width;
    debugPrint('width = $displayWidth');
    left =
        Tween(begin: padding, end: displayWidth - padding).animate(controller)
          ..addListener(() {
            //调用setState触发重新build一个widget，在build方法里，我们根据Animation<T>的当前值来创建widget,达到动画的效果
            setState(() {});
          }) //监听动画状态变化
          ..addStatusListener((status) {
            //让动画重复执行

            //一次动画完成
            if (status == AnimationStatus.completed) {
              controller.reverse();
            } else if (status == AnimationStatus.dismissed) {
              controller.forward();
            }
          });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final unit = 24.0;
    final marginLeft = left == null ? padding : left.value;

    //把marginleft单位化
    final unitizeLeft = (marginLeft - padding) / unit;
    final unitizeTop = math.sin(unitizeLeft);

    //unitizeTop+1 是把【-1，1】之间的值映射到【0.2】
    //(unitizeTop+1)*unit 后是把单位化的值转回来
    final marginTop = (unitizeTop + 1) * unit + padding;
    final color = this.color == null ? Colors.red : this.color.value;
    return Container(
      //我们根据动画的进度设置圆点的位置
      child: Container(
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(7.5)),
        width: 15.0,
        height: 15,
      ),
      //根据动画的进度设置圆点的位置
      margin: EdgeInsets.only(left: marginLeft, top: marginTop),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }
}
