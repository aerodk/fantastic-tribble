import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HalloweenScreenBody extends StatefulWidget {
  @override
  _HalloweenScreenBodyState createState() => _HalloweenScreenBodyState();
}

class _HalloweenScreenBodyState extends State<HalloweenScreenBody> {
  double xValue = 0.1;
  double yValue = 0.1;
  List<String> responseList = [];
  bool sending = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        sending
            ? ElevatedButton(
                onPressed: () {
                  setState(() {
                    sending = !sending;
                  });
                },
                child: Text('Stop commands'),
              )
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    sending = !sending;
                  });
                  sendCommands();
                },
                child: Text('Send Commands'),
              ),
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

  Future<void> sendCommands() async {
    while (sending) {
      for (double x = 0.01; x <= 0.9; x += 0.01) {
        if (!sending) {
          break;
        }
        for (double y = 0.01; y <= 0.9; y += 0.01) {
          if (!sending) {
            break;
          }
          final response = await http.put(
            Uri.parse(
                'http://192.168.86.244/api/d7dSMMYAi0qTzvpvKyZbIg4RNDM9BOJ0npXFLOdf/lights/4/state'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              'xy': [x, y]
            }),
          );

          if (response.statusCode == 200) {
            responseList.insert(0, 'Response: ${response.body}');
            if (responseList.length > 20) {
              responseList.removeLast();
            }
            setState(() {});
          } else {
            print('Kunne ikke sende kommando ${response.body}');
          }
          await Future.delayed(
              Duration(milliseconds: 100)); // 10 kommandoer pr. sekund
        }
      }
    }
  }
}
