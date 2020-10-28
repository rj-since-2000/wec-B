import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'api_request.dart';
import 'chat_message.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatBot',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.orange),
          caption: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.grey),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePageDialogflow(),
    );
  }
}

class HomePageDialogflow extends StatefulWidget {
  HomePageDialogflow({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageDialogflow createState() => _HomePageDialogflow();
}

class _HomePageDialogflow extends State<HomePageDialogflow> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    response('hello');
  }

  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();

  var isTyping = false;
  String answer;

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 2)),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: "Ask something..."),
              ),
            ),
            Container(
              //decoration: BoxDecoration(
              //borderRadius: BorderRadius.circular(10),
              //border: Border.all(color: Colors.white, width: 2)),
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.orange[900],
                    semanticLabel: 'Send Message',
                  ),
                  onPressed: () => _handleSubmitted(_textController.text)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> apiRequests(String check) async {
    final response = await http.get('https://sheetdb.io/api/v1/ozmgk4qj2bs3b');

    if (check == 'upcoming-events') {
      answer = 'Upcoming events are as follows -\n';
      List<dynamic> eventData = jsonDecode(response.body);
      eventData.forEach((element) {
        Event e = Event.fromJson(element);
        if (e.dateTime.isAfter(DateTime.now())) {
          String dateTime = DateFormat('dd/MM/yyyy hh:mm').format(e.dateTime);
          String ans = '\n${e.title} on $dateTime at ${e.venue}';
          answer = answer + ans;
        }
      });
    } else if (check == 'last-event') {
      answer = 'Last event conducted was ';
      List<dynamic> eventData = jsonDecode(response.body);
      Event temp = Event.fromJson(eventData[0]);
      eventData.forEach((element) {
        Event e = Event.fromJson(element);
        if (e.dateTime.isBefore(DateTime.now()) &&
            e.dateTime.isAfter(temp.dateTime)) {
          temp = e;
        }
      });
      String dateTime = DateFormat('dd/MM/yyyy hh:mm').format(temp.dateTime);
      answer = answer + '${temp.title} on $dateTime at ${temp.venue}';
    } else if (check.length > 16 &&
        check.substring(0, 16) == 'event-in-a-month') {
      int space = check.indexOf(' ');
      int slash = check.indexOf('/');
      String date1 = check.substring(space + 1, slash);
      String date2 = check.substring(slash + 1);

      DateTime dateTime1 = DateTime.parse(date1);
      dateTime1 = dateTime1.subtract(Duration(days: 1));
      dateTime1 = DateTime(DateTime.now().year, dateTime1.month, dateTime1.day);
      DateTime dateTime2 = DateTime.parse(date2);
      if (dateTime2.month != 12) dateTime2 = dateTime2.add(Duration(days: 1));
      dateTime2 = DateTime(DateTime.now().year, dateTime2.month, dateTime2.day);

      List<dynamic> eventData = jsonDecode(response.body);
      answer = '';
      eventData.forEach((element) {
        Event e = Event.fromJson(element);

        if (e.dateTime.isAfter(dateTime1) && e.dateTime.isBefore(dateTime2)) {
          String ans = '\n${e.title}';
          answer = answer + ans;
        }
      });
      if (answer == '')
        answer = 'No events were conducted in this month';
      else
        answer = 'Events conducted in this month are as follows -\n' + answer;
    } else if (check.length > 10 && check.substring(0, 10) == 'event-info') {
      int space = check.indexOf(' ');
      String event = check.substring(space + 1);
      answer = 'Event Info -';
      List<dynamic> eventData = jsonDecode(response.body);
      eventData.forEach((element) {
        Event e = Event.fromJson(element);
        if (e.title == event) {
          String date = DateFormat('dd/MM/yyyy').format(e.dateTime);
          String time = DateFormat('hh:mm').format(e.dateTime);
          answer = answer +
              '\n\nEvent - ${e.title}\nDate - $date\nTime - $time\nVenue - ${e.venue}\nAbout - ${e.description}';
          return;
        }
      });
    } else if (check == 'next-event') {
      answer = 'Next upcoming event is -';
      List<dynamic> eventData = jsonDecode(response.body);
      Event temp = Event.fromJson(eventData.firstWhere(
          (element) => Event.fromJson(element).dateTime.isAfter(DateTime.now()),
          orElse: () => null));
      if (temp == null)
        answer = 'There is no upcoming event for now';
      else {
        eventData.forEach((element) {
          Event e = Event.fromJson(element);
          if (e.dateTime.isAfter(DateTime.now()) &&
              e.dateTime.isBefore(temp.dateTime)) {
            temp = e;
            return;
          }
        });
        String date = DateFormat('dd/MM/yyyy').format(temp.dateTime);
        String time = DateFormat('hh:mm').format(temp.dateTime);
        answer = answer +
            '\n\nEvent - ${temp.title}\nDate - $date\nTime - $time\nVenue - ${temp.venue}\nAbout - ${temp.description}';
      }
    }
  }

  void response(query) async {
    _textController.clear();
    setState(() {
      isTyping = true;
    });
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/dsc-nitk-chatbot-12b0fa767665.json")
            .build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogflow.detectIntent(query);
    String queryResult = response.getMessage() ??
        new CardDialogflow(response.getListMessage()[0]).title;
    if (queryResult[0] == '#') {
      await apiRequests(queryResult.substring(1));
      ChatMessage message = new ChatMessage(
        text: answer,
        name: 'wec-B',
        type: false,
      );
      setState(() {
        _messages.insert(0, message);
        isTyping = false;
      });
    } else {
      ChatMessage message = new ChatMessage(
        text: queryResult,
        name: "wec-B",
        type: false,
      );
      setState(() {
        _messages.insert(0, message);
        isTyping = false;
      });
    }
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.trim() == '') return;
    ChatMessage message = ChatMessage(
      text: text,
      name: "you",
      type: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
    response(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: MediaQuery.of(context).size.height >
                          MediaQuery.of(context).size.width
                      ? AssetImage('assets/screenshot_mobile_view.png')
                      : AssetImage('assets/background.png'),
                  fit: MediaQuery.of(context).size.height >
                          MediaQuery.of(context).size.width
                      ? BoxFit.fill
                      : BoxFit.fill,
                ),
                color: Colors.black,
              ),
              height: double.infinity,
              alignment: Alignment.center,
            ),
            Positioned(
              right: MediaQuery.of(context).size.width * 0.1,
              bottom: MediaQuery.of(context).size.height * 0.2,
              child: Card(
                elevation: 10,
                color: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  width: MediaQuery.of(context).size.height >
                          MediaQuery.of(context).size.width
                      ? MediaQuery.of(context).size.width * 0.8
                      : MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(children: <Widget>[
                    AppBar(
                      backgroundColor: Colors.black,
                      centerTitle: true,
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              "wec-B",
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: Colors.orange,
                                  backgroundColor: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "NITK WEB CLUB ASSISTANT",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                backgroundColor: Colors.black,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black,
                            Colors.orange,
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                        child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index) => _messages[index],
                      itemCount: _messages.length,
                    )),
                    Divider(height: 1.0),
                    if (isTyping == true)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Image.asset('assets/webclub-logo-orange.png'),
                        ),
                        title: Text(
                          'wec-B is typing...',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10))),
                      child: _buildTextComposer(),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),

      //       Container(
      //   decoration: BoxDecoration(
      //     image: DecorationImage(
      //       image: AssetImage('assets/background.png'),
      //       fit: BoxFit.fill,
      //     ),
      //   ),
      //   height: double.infinity,
      //   alignment: Alignment.center,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [
      //       ,
      //       Container(
      //         width: MediaQuery.of(context).size.width * 0.2,
      //       ),
      //     ],
      //   ),
      // ),
    );
    //);
  }
}
