import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'onthefence',
      theme: ThemeData(
        primaryColor: Color(0xFF191e23),
        accentColor: Color(0xFFe94828),
      ),
      home: DefaultTabController(

        length: 4,
        child: MyHomePage(title: 'onthefence'),

      )
    );
  }
}

class Post {
  final String date;
  final int id;
  final String title;
  final String content;
  final Image image;
  final int category;

  Post({this.date, this.id, this.title, this.content, this.image,this.category});

  factory Post.fromJson(Map<String, dynamic> json) {

    return Post(
      date: json['post_date'],
      id: json['ID'],
      title: json['post_title'],
      content: json['post_content'].replaceAll(new RegExp('\\[.*?\\]'), ''),
      image: Image.network(json['image']),
      category: json["categories"][0]
    );
  }
  @override
  String toString() {
    return this.title;
  }

}

class Category {
  final int id;
  final String name;
  Category({this.id,this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name']
    );
  }
}

class Comment {
  final int id;
  final String content;
  final String author_name;
  Comment({this.id,this.content,this.author_name});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        id: json['id'],
        content: json['content']["rendered"].replaceAll(new RegExp('\\[.*?\\]'), ''),
        author_name: json['author_name']
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class ShowPostState extends StatefulWidget {
  ShowPostState({Key key, @required this.item, @required this.category}) : super(key: key);

  final Post item;
  final String category;

  @override
  SecondRoute createState() => SecondRoute();

}


class SecondRoute extends State<ShowPostState> {

  bool _liked = false;
  String _likes = "";
  List<Comment> comments = new List();
  String input = "";

  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLiked();
    fetchLikes();
    //comment();
    fetchComments();
  }

  _loadLiked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _liked = (prefs.getBool(widget.item.id.toString()) ?? false);
    });
  }

  _LikeItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _liked = (prefs.getBool(widget.item.id.toString()) ?? false);
      _liked = !_liked;
      prefs.setBool(widget.item.id.toString(), _liked);
      if(_liked) {
        likePost();
      } else {
        dislikepost();
      }

    });
  }



  Future<Post> fetchComments() async {

    print('fetching comments...'+widget.item.id.toString());

    final response =
    await get('https://www.onthefence.news/wp-json/wp//v2/comments/?post='+widget.item.id.toString());


    if (response.statusCode == 200) {
      setState(() {
        comments = new List();
        //

        for(var x in json.decode(response.body)) {
          comments.add(Comment.fromJson(x));
        }

      });

      return null;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<Null> comment(String content) async {

    print('making comment...'+widget.item.id.toString());

    Map<String, String> headers = new Map();
    headers.putIfAbsent("post", () => widget.item.id.toString());
    headers.putIfAbsent("content", () => content);

    final response =
    await post('https://www.onthefence.news/wp-json/wp/v2/comments', body: headers);



    if (response.statusCode == 201) {
      return null;
    } else {
      print(response.statusCode);
      throw Exception('Failed to make comment');
    }
  }

  Future<Null> likePost() async {

    print('liking post...');

    final response =
    await get('https://www.onthefence.news/wp-json/dominiquera/v2/likepost/'+widget.item.id.toString());


    if (response.statusCode == 200) {
      setState(() {
        print(response.body);
        _likes = response.body;
      });

      return null;
    } else {
      throw Exception('Failed to get likes');
    }
  }

  Future<Null> dislikepost() async {

    print('disliking post...');

    final response =
    await get('https://www.onthefence.news/wp-json/dominiquera/v2/dislikepost/'+widget.item.id.toString());


    if (response.statusCode == 200) {
      setState(() {
        print(response.body);
        _likes = response.body;
      });

      return null;
    } else {
      throw Exception('Failed to get likes');
    }
  }

  Future<Null> fetchLikes() async {

    print('fetching likes...'+widget.item.id.toString());

    final response =
    await get('https://www.onthefence.news/wp-json/dominiquera/v2/postlike/'+widget.item.id.toString());


    if (response.statusCode == 200) {
      setState(() {
        print(response.body);
        _likes = response.body;
      });

      return null;
    } else {
      throw Exception('Failed to get likes');
    }
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Column(children: <Widget>[Html(data:widget.item.title, defaultTextStyle: TextStyle(fontFamily: 'Lucida'),customTextStyle: (element,style) {
          return TextStyle(fontFamily: 'Lucida',fontWeight: FontWeight.w700);

        },)],crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,),
        titleSpacing: 0.0,
      ),
      body: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: <Widget>[

            Image(image: widget.item.image.image,fit: BoxFit.cover,height: 200,),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,

                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Html(data:widget.item.title,defaultTextStyle: TextStyle(fontSize: 25,fontWeight: FontWeight.w700,color: Color(0xFFe94828),fontFamily: 'Lucida'),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Text(widget.category,style: TextStyle(fontWeight: FontWeight.w700),),

                      IconButton(
                        padding: EdgeInsets.all(0),
                        icon: new Icon(_liked ? Icons.favorite : Icons.favorite_border),
                        onPressed: () {
                          _LikeItem();
                        },
                        color: _liked ? Colors.red : null,
                      ),
                      Text(_likes),
                    ],
                  ),

                ],
              ),
            ),

            Html(data: widget.item.content,padding: EdgeInsets.fromLTRB(10, 0, 15, 5),
              onLinkTap: (url) {
                print(url);
                launch(url);
              },
              defaultTextStyle: TextStyle(fontSize: 16),customTextAlign: (element) {
              if(element.localName == "p") {
                return TextAlign.justify;
              }
            }, customTextStyle: (element,style) {
              return TextStyle(fontFamily: 'Textfont',color: Color(0XFF000000),fontSize: 16,);

            },),
            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFe94828),width: 2))),
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text("Comments:",style: TextStyle(fontWeight: FontWeight.w700,fontFamily: 'Lucida'),),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Text(comments[index].author_name == "" ? "Anomynous:" : comments[index].author_name+":",textAlign: TextAlign.left,style: TextStyle(fontFamily: 'Textfont',color: Color(0XFF000000)),),
                            Html(data:comments[index].content,padding: EdgeInsets.fromLTRB(0, 0, 0, 0),customTextStyle: (element,style) {
                              return TextStyle(fontFamily: 'Textfont',color: Color(0XFF000000),fontSize: 14,);

                            },)
                          ],
                        );
                    },
                  separatorBuilder: (BuildContext context, int index) => const Divider(), itemCount: comments.length)
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Enter your comment here...'),
                    style: TextStyle(fontFamily: 'Textfont'),
                    controller: myController,
                    onChanged: (String c) {input = c;},
                  ),
                  FlatButton(onPressed: () {
                    if(input != "") {
                      comment(input);
                      showDialog(context: context,builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Success"),
                          content: Text("The comment will be published once it has been approved by the admin."),
                          actions: <Widget>[
                            FlatButton(onPressed: () {Navigator.of(context).pop();}, child: Text("OK"))
                          ],);
                      });
                      myController.clear();
                    }

                    }, child: Text("Post Comment",style: TextStyle(fontFamily: 'Lucida'),),color: Color(0xFFe94828),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),textColor: Color(0xFFFFFFFF),)
                ],
              ),
            )


          ],
        )


    );
  }
}



  class _MyHomePageState extends State<MyHomePage> {

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
          posts.add(Post.fromJson(x));
        }

      });

      return null;
    } else {
      throw Exception('Failed to load post');
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => new ShowPostState(item: posts[i],category: categories[posts[i].category].name,)
            ),
          );
        },
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

              Html(data: posts[i].title,defaultTextStyle: TextStyle(fontSize: 25,fontWeight: FontWeight.w700,color: Color(0xFFe94828),fontFamily: 'Lucida'),padding: EdgeInsets.fromLTRB(0, 0, 0, 0),),

            ],
          ),
        )
      ));
      items.add(item);

    }
    return items;
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
        leading: Image.asset("assets/onthefence.png",),
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
