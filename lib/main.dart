import 'package:flutter/material.dart';

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
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Echo client'),
      ),
      body: MessageList(key: messageListKey),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddMessageScreen()));
          debugPrint('result = $result');
          if (result is Message) {
            messageListKey.currentState.addMessage(result);
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

class _MessageListState extends State<MessageList> {
  final List<Message> messages = [];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(itemBuilder: (context, index) {
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

  @override
  String toString() {
    // TODO: implement toString
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
