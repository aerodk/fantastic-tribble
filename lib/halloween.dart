import 'dart:async';
import 'dart:convert';

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
  double brightness = 60.0;
  List<String> responseList = [];
  bool sending = false;
  int loopCount = 1; // Antal gentagelser (startværdi)
  int currentLoop = 0; // Aktuel gentagelse

  Timer? messageTimer;
  Timer? charTimer;

  @override
  void dispose() {
    messageTimer?.cancel();
    charTimer?.cancel();
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
              messageTimer?.cancel();
              charTimer?.cancel();
              currentLoop = 0;
            });
          },
          child: Text('Stop'),
        )
            : ElevatedButton(
          onPressed: () {
            setState(() {
              sending = true;
              currentLoop = loopCount;
            });
            startSendingMessages();
          },
          child: Text('Start'),
        ),
        Slider(
          value: loopCount.toDouble(),
          min: 1,
          max: 100,
          onChanged: (newValue) {
            setState(() {
              loopCount = newValue.toInt();
            });
          },
        ),
        Text('Loop Count: ${loopCount == 100 ? '∞' : loopCount}'),
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
    const morseCode = ".... .- .- .- .- . . - . -... - .-- .";
    const dotDuration = Duration(milliseconds: 200);
    const dashDuration = Duration(milliseconds: 350);
    const pauseDuration = Duration(milliseconds: 450);
    const charSpacingDuration = Duration(milliseconds: 1000); // Pause mellem tegn

    final message = morseCode.split('').where((char) => char != ' ').toList();
    int currentIndex = 0;

    void sendMessage() {
      if (currentIndex < message.length) {
        final char = message[currentIndex];
        if (char == '.') {
          sendDot();
          currentIndex++;
          charTimer = Timer(dotDuration, () {
            sendPause();
            currentIndex++;
            charTimer = Timer(charSpacingDuration, () {
              sendMessage();
            });
          });
        } else if (char == '-') {
          sendDash();
          currentIndex++;
          charTimer = Timer(dashDuration, () {
            sendPause();
            currentIndex++;
            charTimer = Timer(charSpacingDuration, () {
              sendMessage();
            });
          });
        } else {
          sendPause();
          currentIndex++;
          charTimer = Timer(pauseDuration, () {
            sendMessage();
          });
        }
      } else {
        if (sending && (loopCount == 100 || currentLoop > 0)) {
          if (currentLoop < 100) {
            currentLoop--;
          }
          currentIndex = 0;
          sendMessage();
        } else {
          setState(() {
            sending = false;
            currentLoop = loopCount; // Sæt til startværdien, ikke 0
          });
        }
      }
    }

    sendMessage();
  }

  void sendDot() {
    final body = jsonEncode({'on': true, 'xy': [0.6, 0.4], 'bri': brightness.toInt()});
    sendCommand(body);
  }

  void sendDash() {
    final body = jsonEncode({'on': true, 'xy': [0.675, 0.322], 'bri': brightness.toInt()});
    sendCommand(body);
  }

  void sendPause() {
    final body = jsonEncode({'on': false});
    sendCommand(body);
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
      if (kDebugMode) {
        print('Kommando sendt med succes');
      }
      responseList.insert(0, 'Response: ${response.body}');
      if (responseList.length > 20) {
        responseList.removeLast();
      }
      setState(() {});
    } else {
      if (kDebugMode) {
        print('Kunne ikke sende kommando');
      }
    }
  }
}
