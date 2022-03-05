import 'dart:convert';
import 'package:bulletin/article.dart';
import 'package:bulletin/screens/newsdescription.dart';
import 'package:device_region/device_region.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _page = 1;
  final int _pageSize = 10;
  int totalPages = 0;


  final RefreshController _refreshController = RefreshController(initialRefresh: true);


  List<Article> newsArticles = [];
  Map<String, String> get headers => {
    "Accept": "application/json",
    "Authorization": "ca29ab7c3bec4f0f93a447c3ac53ff7e",
  };

  Future<bool> _getNewsFromAPICall({bool isRefresh = false, String category = 'general'}) async{

    if(isRefresh){
      _page = 1;
    }else{
      if(_page >= totalPages){
        _refreshController.loadNoData();
        return false;
  }
  }
    final result = await DeviceRegion.getSIMCountryCode();
    String countryCode = result ?? 'us';

    var baseUrl = 'https://newsapi.org/v2/top-headlines';
    Map<String, String> queryParams = {
      'country': countryCode,
      'pageSize': '$_pageSize',
      'page': '$_page',
      'category': '$category',
    };
    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = baseUrl + '?' + queryString;
    var url = Uri.parse(requestUrl);
    var response = await http.get(url, headers: headers);

    List<Article> tempArr = [];

    var jsonResponse = jsonDecode(response.body);
    print(response.body);
    if(jsonResponse['status'] == 'ok'){

      for(var itr = 0; itr<_pageSize; itr++) {
        Article article = Article(
          author: jsonResponse['articles'][itr]['author'],
          title: jsonResponse['articles'][itr]['title'],
          description: jsonResponse['articles'][itr]['description'],
          url: jsonResponse['articles'][itr]['url'],
          urlToImage: jsonResponse['articles'][itr]['urlToImage'],
          publishedAt: DateTime.parse(jsonResponse['articles'][itr]['publishedAt']),
          content: jsonResponse['articles'][itr]['content'],
        );
        tempArr.add(article);
      }
      if(isRefresh){
        newsArticles = List.from(tempArr);

      }
      else{
        newsArticles.addAll(tempArr);
        setState(() {

        });
      }
      _page++;
      totalPages =  (jsonResponse['totalResults']/_pageSize).toInt() +1;
      setState(() {

      });

      return true;
    }else{
      return false;
    }
  }
  _getBusinessNewsFromAPICall()async{
    _getNewsFromAPICall(isRefresh: true, category: 'business');
  }
  _getEntertainmentNewsFromAPICall()async{
    _getNewsFromAPICall(isRefresh: true, category: 'entertainment');
  }
  _getHealthNewsFromAPICall()async{
    _getNewsFromAPICall(isRefresh: true, category: 'health');
  }
  _getScienceNewsFromAPICall()async{
    _getNewsFromAPICall(isRefresh: true, category: 'science');
  }
  _getTechnologyNewsFromAPICall()async{
    _getNewsFromAPICall(isRefresh: true, category: 'technology');
  }
  _getSportsNewsFromAPICall()async{
    _getNewsFromAPICall(isRefresh: true, category: 'sports');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Image.asset('assets/images/daily-bulletin.png', fit: BoxFit.contain, height: 400,),
        ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            height: 40.0,
            child: ListView(
              // This next line does the trick.
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                GestureDetector(
                  onTap: _getBusinessNewsFromAPICall,
                  child: newsMenuItem('business'),
                ),
                GestureDetector(
                  onTap: _getEntertainmentNewsFromAPICall,
                  child: newsMenuItem('entertainment'),
                ),
                GestureDetector(
                  onTap: _getHealthNewsFromAPICall,
                  child: newsMenuItem('health'),
                ),
                GestureDetector(
                  onTap: _getScienceNewsFromAPICall,
                  child: newsMenuItem('science'),
                ),
                GestureDetector(
                  onTap: _getSportsNewsFromAPICall,
                  child: newsMenuItem('sports'),
                ),
                GestureDetector(
                  onTap: _getTechnologyNewsFromAPICall,
                  child: newsMenuItem('technology'),
                ),
                GestureDetector(
                  onTap: _getNewsFromAPICall,
                  child: newsMenuItem('general'),
                ),

              ],
            ),
          ),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullUp: true,
              onRefresh: () async{
                final result = await _getNewsFromAPICall(isRefresh: true);
                if(result){
                  _refreshController.refreshCompleted();
                }else{
                  _refreshController.refreshFailed();
                }
              },
              onLoading: () async{
                final result = await _getNewsFromAPICall(isRefresh: false);
                if(result){
                  _refreshController.loadComplete();
                }else{
                  _refreshController.loadFailed();
                }
              },
              child: ListView.builder(

                itemCount: newsArticles.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return NewsDetails(newsArticles[index]);
                      }));
                    },
                    child: Card(
                      color: Colors.grey.shade300,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              ListTile(
                                  title: Text(
                                    newsArticles[index].title,
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                  trailing: (newsArticles[index].urlToImage == null )
                                      ? const CircleAvatar(
                                    radius: 40,
                                    backgroundImage: AssetImage('assets/images/bulletin-logo.png'),
                                  )
                                      : CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(newsArticles[index].urlToImage),
                                  )
                              ),
                            ],
                          )
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      )
    );
  }

  Padding newsMenuItem(String newsItem) {
    return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color(0xff474747),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 5, ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          newsItem,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
  }
}
