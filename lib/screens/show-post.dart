import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'package:onthefence/models/comment.dart';
import 'package:onthefence/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowPostPage extends StatefulWidget {
  ShowPostPage({Key key, @required this.item, @required this.category}) : super(key: key);

  final Post item;
  final String category;

  @override
  _ShowPostPageState createState() => _ShowPostPageState();

}


class _ShowPostPageState extends State<ShowPostPage> {

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

            Container(
                color: Color(0xFF191e23),
                child: Image(image: widget.item.image.image,fit: BoxFit.fitHeight, height: 300,)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 15, 5),
              child: Row(
                  children: <Widget>[
                    Text(
                        "Posted on ${widget.item.dateFormatted()}, ${widget.item.author}",
                        style: TextStyle(color: Colors.grey))
                  ]
              ),
            ),
            Row(
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.all(0),
                    icon: new Icon(_liked ? Icons.favorite : Icons.favorite_border),
                    onPressed: () {
                      _LikeItem();
                    },
                    color: _liked ? Colors.red : null,
                  ),
                  Text(_likes)
                ]
            ),

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