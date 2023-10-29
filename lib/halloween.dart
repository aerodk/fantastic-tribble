import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HalloweenScreenBody extends StatefulWidget {
  @override
  _HalloweenScreenBodyState createState() => _HalloweenScreenBodyState();
}

class _HalloweenScreenBodyState extends State<HalloweenScreenBody> {
  double xValue = 0.1;
  double yValue = 0.1;
  int messagesPerSecond = 1;
  double brightness = 0.0;
  List<String> responseList = [];
  bool sending = false;

  Timer? messageTimer;

  @override
  void dispose() {
    messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        sending
            ? ElevatedButton(
          onPressed: () {
            setState(() {
              sending = false;
            });
            messageTimer?.cancel();
          },
          child: Text('Stop'),
        )
            : ElevatedButton(
          onPressed: () {
            setState(() {
              sending = true;
            });
            startSendingMessages();
          },
          child: Text('Start'),
        ),
        Slider(
          value: messagesPerSecond.toDouble(),
          min: 1,
          max: 10,
          onChanged: (newValue) {
            setState(() {
              messagesPerSecond = newValue.toInt();
            });
          },
        ),
        Text('Messages Per Second: $messagesPerSecond'),
        Slider(
          value: brightness,
          min: 0,
          max: 254,
          onChanged: (newValue) {
            setState(() {
              brightness = newValue;
            });
          },
        ),
        Text('Brightness: ${brightness.toInt()}'),
        Expanded(
          child: ListView.builder(
            itemCount: responseList.length > 20 ? 20 : responseList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Response: ${responseList[index]}'),
              );
            },
          ),
        ),
      ],
    );
  }

  void startSendingMessages() {
    final random = Random();
    messageTimer = Timer.periodic(Duration(seconds: 1 ~/ messagesPerSecond), (timer) {
      if (sending) {
        String body;

        var nextDouble = random.nextDouble();
        if(nextDouble < 1/3) {
          body = jsonEncode({'on': true, 'xy': [0.6, 0.4], 'bri': brightness.toInt()});
        } else if (nextDouble < 2/3) {
          body = jsonEncode({'on': true, 'xy': [0.675, 0.322], 'bri': brightness.toInt()});
        } else {
          body = jsonEncode({'on' : false});
        }
        sendCommand(body);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> sendCommand(String body) async {
    final response = await http.put(
      Uri.parse(
          'http://192.168.86.244/api/d7dSMMYAi0qTzvpvKyZbIg4RNDM9BOJ0npXFLOdf/lights/4/state'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      responseList.insert(0, 'Response: ${response.body}');
      if (responseList.length > 20) {
        responseList.removeLast();
      }
      setState(() {});
    } else {
      if (kDebugMode) {
        print('Kunne ikke sende kommando ${response.body}');
      }
    }
  }
}