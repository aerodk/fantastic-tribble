import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:halloween/halloween.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Flutter App'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Main'),
                Tab(text: 'Halloween'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              MainScreen(),
              HalloweenScreenBody(),
            ],
          ),
        ),
      ),
    );
  }
}
class MainScreen extends StatelessWidget {
  double xValue = 0.5;
  double yValue = 0.5;
  List<String> responseList = [];

  MainScreen({super.key});

  Future<void> sendCommand(double newX, double newY) async {
    final response = await http.put(
      Uri.parse('http://192.168.86.244/api/d7dSMMYAi0qTzvpvKyZbIg4RNDM9BOJ0npXFLOdf/lights/4/state'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'xy':  [xValue, yValue]}),
    );

    if (response.statusCode == 200) {
      // Anmodning blev behandlet med succes
      print('Kommando sendt med succes');
      responseList.add(response.body);
    } else {
      // Der opstod en fejl
      print('Kunne ikke sende kommando');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('REST API Slider App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Slider(
                value: xValue,
                onChanged: (newValue) {
                  if ((newValue - xValue).abs() > 0.05) {
                    sendCommand(newValue, yValue);
                  }
                  xValue = newValue;
                },
              ),
              Text('X: ${xValue.toStringAsFixed(2)}'),
              Slider(
                value: yValue,
                onChanged: (newValue) {
                  if ((newValue - yValue).abs() > 0.05) {
                    sendCommand(xValue, newValue);
                  }
                  yValue = newValue;
                },
              ),
              Text('Y: ${yValue.toStringAsFixed(2)}'),
              Expanded(
                child: ListView.builder(
                  itemCount: responseList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Response: ${responseList[index]}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }
