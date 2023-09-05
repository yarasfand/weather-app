import 'package:dio/dio.dart';
import 'package:weatherapp/Repository/API/api.dart';
import 'package:weatherapp/datamodels/postModels.dart';

class PostRepository{

  API api = API();
  Future <List<PostModels>> fetchPosts () async{

    try{

      Response response = await api.sendRequests.get("/weather?q=Chicago&appid=bd5e378503939ddaee76f12ad7a97608");

      List<dynamic> postMaps = response.data;

      return postMaps.map((postMap) => PostModels.fromJson(postMap)).toList();


    }
    catch(err){
      throw(err);
    }
  }
}