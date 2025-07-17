import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Password Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> passwords = [];
  bool loading = false;

  Future<String> _fetchPassword() async {
    final String url =
        "https://api.genratr.com/?length=16&uppercase&lowercase&special&numbers";
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final result = jsonDecode(res.body);
      return result['password'];
    } else {
      throw Exception();
    }
  }

  Future<void> _getPassword() async {
    setState(() {
      loading = true;
    });

    try {
      final password = await _fetchPassword();
      setState(() {
        passwords.insert(0, password);
      });
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _getPassword,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                ),
                child: loading
                    ? CircularProgressIndicator()
                    : Text(
                        "GENERATE PASSWORD".toUpperCase(),
                        style: TextStyle(
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 16),
            passwords.isEmpty
                ? SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Text("Belum ada password yang ditambahkan"),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: passwords.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ListTile(
                            title: Text(passwords[index]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: passwords[index]),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Password Copied!"),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.copy),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passwords.removeAt(index);
                                    });
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
