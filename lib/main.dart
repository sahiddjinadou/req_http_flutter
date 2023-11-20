import 'package:flutter/material.dart'; // le package material est importé pour utiliser ses widgets deja existant 
import 'package:http/http.dart' as http; // permet  à  flutter d'effectuer des requettes http
import 'dart:convert';// fournit des fonctionnalités de codage et de décodage pour différents formats de données, tels que JSON et UTF-8.
import 'package:url_launcher/url_launcher.dart';//Ce package offre des fonctionnalités permettant de lancer des URLs dans le navigateur par défaut du périphérique ou de lancer des applications tierces spécifiques (telles que le client mail, le client de cartes, etc.) en fonction de l'URL fournie.
 //je definis la forme d'un user 
class Users {
  // je definit les champs ou propréité de la classe Users
  final int userId;
  final String login;
  final String htmlUrl;
  final String avatarUrl;
//je creée mon constructeur 
  const Users({
    required this.userId,
    required this.login,
    required this.htmlUrl,
    required this.avatarUrl,
  });
//factory permet de creer une instance de la classe dans laquel il est 
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['id'] as int,
      login: json['login'] as String,
      htmlUrl: json['html_url'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }
  //permet de recuperer les valeurs reels 
  @override
  String toString() {
    return 'User{userId: $userId, login: $login, htmlUrl: $htmlUrl, avatarUrl: $avatarUrl}';
  }
}

// c'est la methode qui lance le fetch la requette
Future<List<Users>> fetchUsers() async {
  final response = await http.get(
    Uri.parse('https://api.github.com/users'),
    headers: {
      'Authorization': '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',
    },
  );

  if (response.statusCode == 200) {
    List<Users> userTab = [];
    for (var element in jsonDecode(response.body) as List<dynamic>) {
      userTab.add(Users.fromJson(element as Map<String, dynamic>));
    }
    return userTab;
  } else {
    throw Exception('Failed to load github Users');
  }
}
//c'est un StatefulWidget car c'est pas un  widget imuable
//je lui crée un state 
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
// je definis sont state 
class _MyAppState extends State<MyApp> {
  //le future c'est pour dire qu'il va recevoir dans le future genre de façon asynchrone 
  late Future<List<Users>> futureUsers;
  PageController _pageController = PageController(initialPage: 0);
  double currentIndex = 0;

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
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('C🤠🤠L'),
        ),
        body: Center(
          child: FutureBuilder<List<Users>>(
            future: futureUsers,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: snapshot.data!.length,
                        onPageChanged: (index) {
                          setState(() {
                            currentIndex = index.toDouble();
                          });
                        },
                        itemBuilder: (context, index) {
                          return Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 150,
                                  backgroundImage: NetworkImage(
                                    snapshot.data![index].avatarUrl,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Login : ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data![index].login,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black54,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Rejoindre le repos : ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await launchUrl(Uri.parse(snapshot.data![index].htmlUrl));
                                      },
                                      child: const Text(
                                        'Voici moi compte git',
                                        style: TextStyle(
                                          fontSize: 17.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_pageController.page! > 0) {
                              _pageController.previousPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                            }
                          },
                          child: Text('Précédent'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_pageController.page! < snapshot.data!.length - 1) {
                              _pageController.nextPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                            }
                          },
                          child: Text('Suivant'),
                        ),
                      ],
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  Future<void> launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

void main() => runApp(const MyApp());
