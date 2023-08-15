class PostDB {

  String? postId;
  String? email;
  List<String>? images;
  String? description;
  String? writer;   // email
  String? category;
  List<String>? tags;
  Map<String, dynamic>? comments;
  int? likes;
  String? posted; // date
  bool? withComment;
  int? postNumber;
  String? profileFileName;

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
    this.profileFileName
  });

  factory PostDB.fromJson(Map<String, dynamic> data) {

    String postId = data['postId'] as String;
    String email = data['email'] as String;
    List<String> images = data['images'] as List<String>;
    String description = data['description'] as String;
    String writer = data['writer'] as String;
    String category = data['category'] as String;
    List<String> tags = data['tags'] as List<String>;
    Map<String, dynamic> comments = data['comments'] as Map<String, dynamic>;
    int likes = data['likes'] as int;
    String posted = data['posted'] as String;
    bool withComment = data['withComment'] as bool;
    int postNumber = data['postNumber'] as int;
    String profileFileName = data['profileFileName'] as String;

    return PostDB(postId: postId, description: description, category: category, comments: comments,
                  profileFileName: profileFileName, posted: posted, tags: tags,
                  likes: likes, postNumber: postNumber, images: images, writer: writer,
                  withComment: withComment, email: email);

  }
}