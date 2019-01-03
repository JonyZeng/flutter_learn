import 'package:flutter/material.dart';
import 'package:flutter_learn/HttpEchoServer.dart';
import 'package:flutter_learn/HttpEchoClient.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filutter UX demo',
      home: MessageListScreen(),
    );
  }
}

//下面是消息列表的页面
class MessageListScreen extends StatelessWidget {
  final messageListKey =
      GlobalKey<_MessageListState>(debugLabel: 'messageListKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Echo client'),
      ),
      body: MessageList(key: messageListKey),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Message result = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddMessageScreen()));
          //
          if (_client == null) return;
          //把消息发送给服务器
          Message msg = await _client.send(result.msg);
          if (msg != null) {
            messageListKey.currentState.addMessage(msg);
          } else {
            debugPrint('fail to send $result');
          }
        },
        tooltip: 'Add message',
        child: Icon(Icons.add),
      ),
    );
  }
}

class MessageList extends StatefulWidget {
  MessageList({Key key}) : super(key: key);

  @override
  State createState() {
    // TODO: implement createState
    return _MessageListState();
  }
}

HttpEchoServer _server;
HttpEchoClient _client;

class _MessageListState extends State<MessageList> with WidgetsBindingObserver {
  final List<Message> messages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    const port = 6060;
    _server = HttpEchoServer(port);
    //initState不是一个async函数，这里不能直接await _server.start(),
    //flutter.then(...)跟await是等价的
    _server.start().then((_) {
      //等服务器启动后才创建客户端
      _client = HttpEchoClient(port);
      _client.getHistory().then((list) {
        setState(() {
          messages.addAll(list);
        });
      });
      WidgetsBinding.instance.addObserver(this);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      var server = _server;
      _server = null;
      server?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemBuilder: (context, index) {
        final msg = messages[index];
        final subtitle = DateTime.fromMillisecondsSinceEpoch(msg.timestamp)
            .toLocal()
            .toIso8601String();
        return ListTile(
          title: Text(msg.msg),
          subtitle: Text(subtitle),
        );
      },
      itemCount: messages.length,
    );
  }

  void addMessage(Message msg) {
    setState(() {
      messages.add(msg);
    });
  }
}

class Message {
  final String msg;
  final int timestamp;

  Message(this.msg, this.timestamp);

  Message.create(String msg)
      : msg = msg,
        timestamp = DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {"msg": "$msg", "timestamp": timestamp};

  Message.fromJson(Map<String, dynamic> json)
      : msg = json['msg'],
        timestamp = json['timestamp'];

  @override
  String toString() {
    return 'Message{msg: $msg, timestamp: $timestamp}';
  }
}

//下面是发送消息的页面
class AddMessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Message'),
      ),
      body: MessageFrom(),
    );
  }
}

class MessageFrom extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MessageFromState();
  }
}

class _MessageFromState extends State<MessageFrom> {
  final editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          //让输入框占满一行里除按钮外的所有空间
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Input message',
                  contentPadding: EdgeInsets.all(0.0),
                ),
                style: TextStyle(fontSize: 22.0, color: Colors.black54),
                controller: editController,
                //自动获取焦点，弹出输入法
                autofocus: true,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              debugPrint('send: ${editController.text}');
              var message = Message(
                  editController.text, DateTime.now().millisecondsSinceEpoch);
              Navigator.pop(context, message);
            },
            onDoubleTap: () => debugPrint('double tapped'),
            onLongPress: () => debugPrint('long pressed'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(5.0)),
              child: Text('send'),
            ),
          )
        ],
      ),
    );
  }

//widget的生命中后期中，dispose生命周期方法在对象被widget树里永久移除的时候调用，这里可以被理解为对象要销毁了。我们这里主动调用dispose表示释放资源
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    editController.dispose();
  }
}
