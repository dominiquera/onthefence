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