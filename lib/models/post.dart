import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Post {
  final DateTime date;

  final int id;
  final String title;
  final String content;
  final Image image;
  final int category;
  final String author;
  bool isRead = false;

  final _dateFormatter = DateFormat('dd.MM.yyyy');

  Post({this.date, this.id, this.title, this.content, this.image,this.category, this.author});

  factory Post.fromJson(Map<String, dynamic> json) {

    return Post(
        date: DateTime.parse(json['post_date']),
        id: json['ID'],
        title: json['post_title'],
        content: json['post_content'].replaceAll(new RegExp('\\[.*?\\]'), ''),
        image: Image.network(json['image']),
        category: json["categories"][0],
        author: json["post_author"]
    );
  }

  @override
  String toString() {
    return this.title;
  }

  String dateFormatted(){
    return _dateFormatter.format(this.date);
  }

}