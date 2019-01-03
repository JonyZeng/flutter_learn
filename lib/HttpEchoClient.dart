import 'package:flutter_learn/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpEchoClient {
  final int port;
  final String host;

  HttpEchoClient(this.port) : host = 'http://localhost:$port';

  Future<Message> send(String msg) async {
    //http.post用来执行一个HTTP POST请求
    //它的body参数是一个dynamic，可以支持不同类型的body,这里我们直接把
    //客户端输入的消息发送给服务端就OK了。由于msg是一个String.post方法会自动设置HTTP的Content-Type为text/plain
    final response = await http.post(host + '/echo', body: msg);
    if (response.statusCode == 200) {
      //json是convert包提供的
      Map<String, dynamic> msgJson = json.decode(response.body);
      //Dart并不知道我们的Message长啥样，需要通过map来构造对象
      var message = Message.fromJson(msgJson);
      return message;
    } else {
      return null;
    }
  }

  Future<List<Message>> getHistory() async {
    try {
      //http包的get方法用来执行HTTP GET请求
      final response = await http.get(host + '/history');
      if (response.statusCode == 200) {
        return _decodeHistory(response.body);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  List<Message> _decodeHistory(String response) {
    //json数组decode出来是一个<Map<String,dynamic>>[]
    var messages = json.decode(response);
    var list = <Message>[];
    for (var msgJson in messages) {
      list.add(Message.fromJson(msgJson));
    }
    return list;
  }
}
