class PostDB {

  String? postId;
  String? email;
  List<String>? images;
  String? description;
  String? writer;   // email
  String? category;
  List<String>? tags;
  List<String>? comments;
  List<dynamic>? likes;
  String? posted; // date
  bool? withComment;
  int? postNumber;
  String? uId;
  List<dynamic>? bookMarks;

  PostDB({
    this.postId,
    this.email,
    this.images,
    this.description,
    this.writer,
    this.category,
    this.tags,
    this.comments,
    this.likes,
    this.posted,
    this.withComment,
    this.postNumber,
    this.uId,
    this.bookMarks
  });



  factory PostDB.fromJson(Map<String, dynamic> data) {

    String postId = data['postId'] as String;
    String email = data['email'] as String;
    List<String> images = data['images'] as List<String>;
    String description = data['description'] as String;
    String writer = data['writer'] as String;
    String category = data['category'] as String;
    List<String> tags = data['tags'] as List<String>;
    List<String> comments = data['comments'] as List<String>;
    List<dynamic> likes = data['likes'] as List<dynamic>;
    String posted = data['posted'] as String;
    bool withComment = data['withComment'] as bool;
    int postNumber = data['postNumber'] as int;
    String uId = data['uId'] as String;
    List<dynamic> bookMarks = data['bookMarks'] as List<dynamic>;
 
    return PostDB(postId: postId, description: description, category: category, comments: comments,
                  posted: posted, tags: tags,
                  likes: likes, postNumber: postNumber, images: images, writer: writer,
                  withComment: withComment, email: email, uId: uId, bookMarks: bookMarks);

  }
}