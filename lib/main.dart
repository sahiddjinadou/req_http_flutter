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

Future<Users> fetchUsers() async {
  final response =
      await http.get(Uri.parse('https://api.github.com/users/mojombo'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
  late Future<Users> futureUsers;

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
          child: FutureBuilder<Users>(
            future: futureUsers,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                          radius: 150,
                          backgroundImage:
                              NetworkImage(snapshot.data!.avatarUrl)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Login : ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
                                color: Colors.blueAccent,
                              )),
                          Text(
                            snapshot.data!.login,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                                fontFamily: AutofillHints.birthdayDay),
                            )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Rejoindre le repos : ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
                                color: Colors.blueAccent,
                              )),
                          ElevatedButton(
                            onPressed: () async {
                              await launchUrl(
                                  Uri.parse(snapshot.data!.htmlUrl));
                            },
                            child: const Text('Voici moi compte git',
                                style: TextStyle(
                                        fontSize: 17.0,
                                        fontFamily: AutofillHints.fullStreetAddress,
                                        color: Color.fromARGB(255, 255, 255, 255),
                                    )
                                ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
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
