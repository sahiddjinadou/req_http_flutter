import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Users {
  final int userId;
  final String login;
  final String htmlUrl;
  final String avatarUrl;

  const Users({
    required this.userId,
    required this.login,
    required this.htmlUrl,
    required this.avatarUrl,
  });

  //creation d'une methode qui va envoyer une instance de la classe factory methode
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['id'] as int,
      login: json['login'] as String,
      htmlUrl: json['html_url'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }
}

Future<List<dynamic>> fetchUsers() async {
  final response = await http.get(Uri.parse('https://api.github.com/users'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var userTab = [] as List<dynamic>;
    for (var element in jsonDecode(response.body) as List<dynamic>) {
      // print(element);
      // print(Users(
      //   userId:element['id'] as int,
      //   login:element['login'] as String,
      //   htmlUrl:element['html_url'] as String,
      //   avatarUrl:element['avatar_url'] as String,
      // ).fromJSON(element as Map<String, dynamic>));
      print(Users.fromJson(element));
      userTab.add(Users.fromJson(element as Map<String, dynamic>));
    }
    return userTab;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load github Users');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<dynamic>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Les super héros',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('C🤠🤠L'),
        ),
        body: Center(
          child: FutureBuilder<List<dynamic>>(
            future: futureUsers,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // print(snapshot.data!);
                return ListView(children: const <Widget>[
                  ListTile(
                    leading: Icon(Icons.map),
                    title: Text('Map'),
                  ),
                ]);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

void main() => runApp(const MyApp());
