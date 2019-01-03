import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter_learn/main.dart';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite/sqflite.dart';

class HttpEchoServer {
  static const GET = 'GET';
  static const POST = 'POST';
  final List<Message> messages = []; //加上了一个static
  String historyFilePath;
  final int port;
  HttpServer httpServer;

  static const tableName = 'History';
  static const columnId = 'id';
  static const columMsg = 'msg';
  static const columTimestamp = 'timestamp';

  Database database;

  //在Dart里面，函数也是first class object，所以直接把函数放到Map里面
  Map<String, void Function(HttpRequest)> routes;

  HttpEchoServer(this.port) {
    _initRoutes();
  }

  void _initRoutes() {
    routes = {
      '/history': _history,
      '/echo': _echo,
    };
  }

  // 返回一个Future，这样客户端就能够在start完成之后做一些事情
  Future start() async {
    await _initDatabase();
    historyFilePath = await _historyPath();
    //在启动服务器之前，先加载历史记录
    await _loadMessages();
    //1.创建一个HttpServer
    httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    //2.开始监听客户端
    return httpServer.listen((request) {
      final path = request.uri.path;
      final handler = routes[path];
      if (handler != null) {
        handler(request);
      } else {
        //给客户返回404
        request.response.statusCode = HttpStatus.notFound;
        request.response.close();
      }
    });
  }

  Future<String> _historyPath() async {
    //获取应用私有的文件目录
    final directory = await path_provider.getApplicationDocumentsDirectory();
    return directory.path + '/messages.json';
  }

  void _history(HttpRequest request) {
    //查询历史记录的sql操作
    if (request.method != GET) {
      _unsupportedMethod(request);
      return;
    }
    String historyData = json.encode(messages);
    request.response.write(historyData);
    request.response.close();
  }

  void _echo(HttpRequest request) async {
    //提供echo服务
    if (request.method != POST) {
      _unsupportedMethod(request);
      return;
    }
    //获取客户端POST请求的body，
    String body = await request.transform(utf8.decoder).join();
    if (body != null) {
      var message = Message.create(body);
      messages.add(message);
      request.response.statusCode = HttpStatus.ok;
      //json是convert包里的对象，encode方法还有第二个参数toEncodable。当遇到对象不是Dart得内置对象时，如果提供这个参数，就会调用它对对象进行序列化。
      //这里我们没有提供，所以，encode方法会调用对象的toJson方法
      var data = json.encode(message);
      //把响应写回客户端
      request.response.write(data);
      _storeMessages(message);
    } else {
      request.response.statusCode = HttpStatus.badRequest;
    }
    request.response.close();
  }

  void _unsupportedMethod(HttpRequest request) async {
    request.response.statusCode = HttpStatus.methodNotAllowed;
    request.response.close();
  }

  void close() async {
    var server = httpServer;
    httpServer = null;
    await server?.close();

    var db = database;
    database = null;
    db?.close();
  }
  void _storeMessages(Message msg) async {
  //保存记录到数据库
    database.insert(tableName, msg.toJson());
  }
/*
  Future<bool> _storeMessages() async {
    try {
      //json.encode支持List Map
      final data = json.encode(messages);
      //File 是dart：io的类
      final file = File(historyFilePath);
      final exists = await file.exists();
      if (!exists) {
        await file.create();
      }
      file.writeAsString(data);
      return true;
    } catch (e) {
      print('_storeMessages: $e');
      return false;
    }
  }*/

  //存储在文件中
/*  Future _loadMessages() async {
    try {
      var file = File(historyFilePath);
      var exists = await file.exists();
      if (!exists) return;

      var content = await file.readAsString();
      var list = json.decode(content);
      for (var msg in list) {
        var message = Message.fromJson(msg);
        messages.add(message);
      }
    } catch (e) {
      print('_loadMessages:$e');
    }
  }*/
  Future _loadMessages() async {
    var list = await database.query(tableName,
        columns: [columMsg, columTimestamp], orderBy: columnId);
    for (var item in list) {
      // fromJson 也适用于使用数据库的场景
      var message = Message.fromJson(item);
      messages.add(message);
    }
  }

  Future _initDatabase() async {
    var path = await getDatabasesPath() + '/history.db';
    database =
        await openDatabase(path, version: 1, onCreate: (db, version) async {
      var sql = '''
        CREATE TABLE $tableName(
        $columnId INTEGER PRIMARY KEY,
        $columMsg TEXT,
        $columTimestamp INTEGER
        )
        ''';
      await db.execute(sql);
    });
  }
}
