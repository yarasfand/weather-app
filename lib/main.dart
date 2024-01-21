import 'package:flutter/material.dart';
import 'package:weatherapp/weatherApp/model/postModels.dart';
import 'package:weatherapp/weatherApp/model/weatherapi.dart';
import 'package:weatherapp/weatherApp/screens/homepage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  PostRepository postRepository = PostRepository();
  List<PostModels> postModels = await postRepository.fetchPosts();
  
  print(postModels.toString());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(

      debugShowCheckedModeBanner: false,
      home: HomePage(

      ),
    );
  }
}
