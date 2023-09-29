class CommentDB {

  String? commentId;
  String? username;
  String? description;
  String? date;
  List<dynamic>? likedUsers;

  CommentDB({
    this.commentId,
    this.username,
    this.description,
    this.date,
    this.likedUsers
  });

  factory CommentDB.fromJson(Map<String, dynamic> data) {

    String commentId = data['commentId'] as String;
    String username = data['username'] as String;
    String description = data['description'] as String;
    String date = data['date'] as String;
    List<dynamic> likedUsers = data["likedUsers"] as List<dynamic>;
   

    return CommentDB(commentId: commentId, username: username, description: description, date: date, likedUsers: likedUsers);

  }
}