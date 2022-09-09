import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grid_pluto/pluto_grid.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: const FirebaseOptions(
    //   apiKey: "AIzaSyCfJF3hLHRsdmVcLRaUQIDbHzjCVd5-hsY",
    //   authDomain: "pluto-grid.firebaseapp.com",
    //   projectId: "pluto-grid",
    //   storageBucket: "pluto-grid.appspot.com",
    //   messagingSenderId: "424888225783",
    //   appId: "1:424888225783:web:ed2e68bc04bfea1d7c68f2",
    //   measurementId: "G-RN9TSNW5LB"
    // ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlutoGrid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Grid(),
    );
  }
}
