import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onthefence/models/category.dart';
import 'dart:io';

import 'package:onthefence/models/post.dart';
import 'package:onthefence/screens/show-post.dart';
import 'package:onthefence/services/shared-prefs.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  initState() {
    super.initState();
    fetchPost();
    fetchCategory();

    firebaseCloudMessaging_Listeners();
  }


  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token){
      print("FCM token: $token");
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.configure();
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }

  List<Post> posts = new List();
  Map<int, Category> categories = new Map();


  Future<Post> fetchPost() async {

    print('fetching posts...');

    Map<String, String> headers = new Map();
    headers.putIfAbsent("Cache-Control", () => 'no-cache');
    final response = await get('https://www.onthefence.news/wp-json/cc/v1/posts',headers: headers);


    if (response.statusCode == 200) {
      setState(() {
        posts = new List();
        //

        for(var x in json.decode(response.body)) {
          Post post = Post.fromJson(x);
          posts.add(post);
          getPostReadStatus(post);
        }

      });

      return null;
    } else {
      throw Exception('Failed to load post');
    }
  }

  void getPostReadStatus(Post post) async {
    bool read = await SharedPrefs.getPostReadStatus(post.id);
    if (read) {
      setState(() {
        post.isRead = true;
      });
    }
  }


  void fetchCategory() async {

    print('fetching category...');

    final response =
    await get('https://onthefence.news/wp-json/wp/v2/categories/');
    if (response.statusCode == 200) {
      for(var x in json.decode(response.body)) {
        Category c = Category.fromJson(x);
        categories.putIfAbsent(c.id, () => c);
      }
    } else {
      throw Exception('Failed to load post');
    }
  }

  List<Widget> _getItems({int category}) {
    var items = <Widget>[];
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);

    for (int i = 0; i < posts.length; i++) {
      if(category != null && posts[i].category != category) {
        continue;
      }
      /*
      if(items.length == 0) {
        var item = GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondRoute(item: posts[i],category: categories[posts[i].category].name,),
                ),
              );
            },
            child: new Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                    height: 200,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    decoration: new BoxDecoration(
                    image: new DecorationImage(
                    image: posts[i].image.image,
                    fit: BoxFit.cover,
                  ),
              ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Html(data: posts[i].title,defaultTextStyle: TextStyle(fontSize: 25,fontWeight: FontWeight.w700,color: Color(0xFFe94828)),padding: EdgeInsets.fromLTRB(0, 0, 0, 0),),
                    posts[i].category != null ? Text(categories[posts[i].category].name,style: TextStyle(color: Colors.black,)) : Text(""),
                  ],
                ),
              )

            ],
          ),
        ));

        items.add(item);

      } else {
        var item = new Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SecondRoute(item: posts[i],category: categories[posts[i].category].name,),
                  ),
                );
              },
              child: Row(

                children: <Widget>[
                  Image(image: posts[i].image.image,width: 130,fit: BoxFit.cover,height: 80,),
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    width: queryData.size.width - 150,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      verticalDirection: VerticalDirection.down,
                      children: <Widget>[
                        Html(data: posts[i].title,defaultTextStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.w700),padding: EdgeInsets.fromLTRB(0, 0, 0, 0),),
                        Text(categories[posts[i].category].name),
                      ],
                    ),
                  )

                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: new Divider(
                height: 5.0,
              ),
            )

          ],
        );

        items.add(item);
      }
      */

      var item = GestureDetector(
          onTap: () => openPostScreen(posts[i]),
          child: new Container(
              padding: EdgeInsets.fromLTRB(0, 120, 100, 0),
              decoration: BoxDecoration(image: DecorationImage(image: posts[i].image.image,fit: BoxFit.cover)),
              //decoration: BoxDecoration(image: DecorationImage(image: posts[i].image.image,fit: BoxFit.cover),border: Border.all(color: Color(0xFFFFFFFF),width: 4)),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Container(
                decoration: BoxDecoration(color: Color.fromARGB(150, 255, 255, 255)),
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[

                    postTitle(posts[i])
                  ],
                ),
              )
          ));
      items.add(item);

    }
    return items;
  }

  openPostScreen(Post post) async {
    final Post postResult = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ShowPostPage(item: post, category: categories[post.category].name,)
      ),
    );
    if (postResult.isRead) {
      setState(() {});
    }
  }

  Widget postTitle(Post post){
    if (post.isRead) {
      return Html(
        data: post.title,
        defaultTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
          fontFamily: 'Lucida'
        ),
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0)
      );
    } else {
      return Html(
        data: post.title,
        defaultTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          color: Color(0xFFe94828),
          fontFamily: 'Lucida'
        ),
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0)
      );
    }

  }


  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    print(queryData.size.width);

    double fontSize = 18;
    bool isScrollable = false;
    double padding = 0;
    double headerSize = 25;
    if(queryData.size.width < 400) {
      fontSize = 18;
      isScrollable = true;
      padding = 20;
      headerSize = 20;
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        leading: InkWell(
          child: Image.asset("assets/onthefence.png"),
          onTap: (){
            launch("https://www.onthefence.news/about-onthefence/");
          },
        ),
        title: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(

            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                padding: EdgeInsets.fromLTRB(0, 0, 40, 0),
                child: Text(widget.title,style: TextStyle(fontFamily: 'Lucida',fontWeight: FontWeight.w700,fontSize: headerSize),),
              ),
            ],
          ),),


        bottom: PreferredSize(

            child: Container(
              padding: EdgeInsets.all(0),
              child: TabBar(

                  indicator: BoxDecoration(color: Color(0xFFe94828)),
                  isScrollable: isScrollable,
                  unselectedLabelColor: Colors.white.withOpacity(1),
                  indicatorColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.fromLTRB(padding, 0, padding, 0),

                  tabs: [
                    Tab(
                      child: Text('New',style: TextStyle(fontFamily: 'Lucida',fontSize: fontSize,fontWeight: FontWeight.w700),),

                    ),
                    Tab(
                      child: Text('Politics',style: TextStyle(fontFamily: 'Lucida',fontSize: fontSize,fontWeight: FontWeight.w700),),
                    ),
                    Tab(
                      child: Text('Society',style: TextStyle(fontFamily: 'Lucida',fontSize: fontSize,fontWeight: FontWeight.w700),),
                    ),
                    Tab(
                      child: Text('Columns',style: TextStyle(fontFamily: 'Lucida',fontSize: fontSize,fontWeight: FontWeight.w700),),
                    ),
                  ]),
            ),
            preferredSize: Size.fromHeight(50.0)
        ),
      ),
      body: TabBarView(children: <Widget>[
        Container(
          //decoration: BoxDecoration(color: Color.fromARGB(5, 0, 0, 0),),
          decoration: BoxDecoration(color: Color(0xFF191e23)),
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: RefreshIndicator(child: new ListView(
            children: _getItems(),
          ), onRefresh: fetchPost),
        ),
        Container(
          decoration: BoxDecoration(color: Color(0xFF191e23)),
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: RefreshIndicator(child: new ListView(
            children: _getItems(category: 418),
          ), onRefresh: fetchPost),
        ),
        Container(
          decoration: BoxDecoration(color: Color(0xFF191e23)),
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: RefreshIndicator(child: new ListView(
            children: _getItems(category: 419),
          ), onRefresh: fetchPost),
        ),
        Container(
          decoration: BoxDecoration(color: Color(0xFF191e23)),
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: RefreshIndicator(child: new ListView(
            children: _getItems(category: 275),
          ), onRefresh: fetchPost),
        )
      ]),



    );
  }
}