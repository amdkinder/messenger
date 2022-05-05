import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  Intl.defaultLocale = 'uz';
  initializeDateFormatting('uz');

  runApp(const MyApp());
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        elevation: 1,
        title: Row(
          children: const [
            CircleAvatar(child: Icon(Icons.headphones)),
            SizedBox(width: 20),
            Text("Support chat")
          ],
        ),
      ),
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: const AssetImage("assets/chat_background.jpg"),
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2), BlendMode.dstATop),
            fit: BoxFit.cover,
          )),
          child: const ChatBody()),
    );
  }
}

class ChatBody extends StatefulWidget {
  const ChatBody({Key? key}) : super(key: key);

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  var map = <String, List<Message>>{};

  @override
  void initState() {
    mapToDate();
    super.initState();
  }

  mapToDate() {
    setState(() {
      map = fakeMessages.reversed.groupBy((m) => m.getFormattedDate());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  for (var date in map.keys)
                    GroupedMessageList(
                        formattedDate: date, messages: map[date]!)
                ],
              ),
            ),
          ),
          ChatInput(
            onAddMessage: () => mapToDate(),
          )
        ],
      ),
    );
  }
}

class GroupedMessageList extends StatelessWidget {
  String formattedDate;
  List<Message> messages;

  GroupedMessageList(
      {required this.formattedDate, required this.messages, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChatMessageDate(formattedDate.substring(0, 5)),
        for (var message in messages) MessageBody(message)
      ],
    );
  }
}

class ChatMessageDate extends StatelessWidget {
  String date;

  ChatMessageDate(this.date, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                date,
                style: const TextStyle(fontSize: 11),
              ))),
    );
  }
}

class MessageBody extends StatelessWidget {
  Message message;

  MessageBody(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var me = message.author == username;
    var mainAxis = me ? MainAxisAlignment.end : MainAxisAlignment.start;
    var borderRadius = BorderRadius.only(
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
        bottomLeft: me ? const Radius.circular(8) : Radius.zero,
        bottomRight: me ? Radius.zero : const Radius.circular(8));
    return Row(
      mainAxisAlignment: mainAxis,
      children: [
        Padding(
          padding: const EdgeInsets.all(2),
          child: Card(
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              child: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                  padding: const EdgeInsets.only(
                      right: 12, left: 12, top: 8, bottom: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message.text ?? '',
                      ),
                      const SizedBox(height: 2),
                      Text(
                        getMessageTime(),
                        style:
                            const TextStyle(fontSize: 8, color: Colors.white70),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ))),
        ),
      ],
    );
  }

  String getMessageTime() => timeFormat.format(message.date!);
}

class ChatInput extends StatelessWidget {
  VoidCallback onAddMessage;

  ChatInput({required this.onAddMessage, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();

    sendMessage() {
      var text = controller.text;
      fakeMessages.insert(0, Message(text: text, author: username));
      controller.text = "";
      onAddMessage();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
            hintText: "Type message",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white24)),
            suffixIcon: IconButton(
                onPressed: () =>
                    buttonFilter(controller) ? null : sendMessage(),
                icon: const Icon(Icons.send))),
        controller: controller,
      ),
    );
  }

  bool buttonFilter(TextEditingController controller) {
    var notEmpty = controller.text == "";
    var text = controller.text;
    var nonWhiteSpace = text.replaceAll(" ", "").isEmpty;
    return notEmpty || nonWhiteSpace;
  }
}

List<Message> fakeMessages = [
  Message(text: "Ha, bir narsa soramoqchidim", author: "username"),
  Message(
      text: "Qanaqadir muammolar bormi? asdf asdf asd fdas", author: "support"),
  Message(text: "Vo alaykum Assalom", author: "support"),
  Message(text: "Salom", author: "username", date: DateTime(2022)),
];

class Message {
  String? text;
  String? author;
  DateTime? date;

  Message({this.text, this.author, this.date}) {
    date ??= DateTime.now();
  }

  getFormattedDate() {
    return dateFormat.format(date!);
  }
}

const username = "username";

final DateFormat dateFormat = DateFormat('dd.MM.yyyy');
final DateFormat timeFormat = DateFormat('HH:mm');
