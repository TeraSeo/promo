class CommentDB {

  String? commentId;
  String? username;
  String? description;
  int? likes;
  String? date;

  CommentDB({
    this.commentId,
    this.username,
    this.description,
    this.likes,
    this.date
  });

  factory CommentDB.fromJson(Map<String, dynamic> data) {

    String commentId = data['commentId'] as String;
    String username = data['username'] as String;
    String description = data['description'] as String;
    int likes = data['likes'] as int;
    String date = data['date'] as String;
   

    return CommentDB(commentId: commentId, username: username, description: description, likes: likes, date: date);

  }
}