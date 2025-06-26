import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  var messages = [
    {"role": "user", "content": "Bonjour"},
    {"role": "assistant", "content": "Que puis-je faire"},
  ];

  TextEditingController userController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "DWM Chatbot",
          style: TextStyle(color: Theme.of(context).indicatorColor),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, "/");
            },
            icon: Icon(Icons.logout, color: Theme.of(context).indicatorColor),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        messages[index]['type'] == 'user'
                            ? SizedBox(width: 80)
                            : SizedBox(width: 0),
                        Expanded(
                          child: Card.outlined(
                            margin: EdgeInsets.all(6),

                            color:
                                messages[index]['type'] == 'user'
                                    ? Color.fromARGB(30, 0, 255, 0)
                                    : Colors.white,

                            child: Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      "${messages[index]['content']}",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        messages[index]['type'] == 'assistant'
                            ? SizedBox(width: 80)
                            : SizedBox(width: 0),
                      ],
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                      hintText: "Message",
                      //icon: Icon(Icons.lock),
                      //prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 1,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    String question = userController.text;
                    Uri uri = Uri.parse(
                      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyBrKugQFqn2KkjrLfEDb2ratjifqrOaQkY",
                    );
                    var headers = {"Content-Type": "application/json"};

                    // Build conversation history for context
                    List<Map<String, dynamic>> contents = [];

                    // Add all previous messages to maintain context
                    for (var message in messages) {
                      contents.add({
                        "role": message["role"] == "user" ? "user" : "model",
                        "parts": [
                          {"text": message["content"]},
                        ],
                      });
                    }

                    // Add the current user question
                    contents.add({
                      "role": "user",
                      "parts": [
                        {"text": question},
                      ],
                    });

                    var body = {"contents": contents};

                    http
                        .post(uri, headers: headers, body: json.encode(body))
                        .then((resp) {
                          var aiResponse = json.decode(resp.body);
                          // Corrected path to access the text content
                          String answer =
                              aiResponse['candidates'][0]['content']['parts'][0]['text'];

                          setState(() {
                            messages.add({"role": "user", "content": question});
                            messages.add({
                              "role": "assistant",
                              "content": answer,
                            });
                          });

                          // Clear the input field
                          userController.clear();
                        })
                        .catchError((err) {
                          print(err);
                        });
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
