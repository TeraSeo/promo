class LikeUser {
  String? name;
  String? email;
  String? profilePic;
  String? backgroundPic;
  String? uid;
  List<dynamic>? likes;
  String? registered;
  String? intro;
  int? ranking;
  List<dynamic>? posts;
  List<dynamic>? bookmarks;
  
  LikeUser(
      {
      this.name,
      this.email,
      this.profilePic,
      this.backgroundPic,
      this.uid,
      this.likes,
      this.registered,
      this.intro,
      this.ranking,
      this.posts,
      this.bookmarks
      });

  factory LikeUser.fromJson(Map<String, dynamic> data) {

    String name = data['name'] as String;
    String email = data['email'] as String;
    String profilePic = data['profilePic'] as String;
    String backgroundPic = data['backgroundPic'] as String;
    String uid = data['uid'] as String;
    List<dynamic> likes = data['likes'] as List<dynamic>;
    String registered = data['registered'] as String;
    String intro = data['intro'] as String;
    int ranking = data['ranking'] as int;
    List<dynamic> posts = data['posts'] as List<dynamic>;
    List<dynamic> bookmarks = data['bookmarks'] as List<dynamic>;

    return LikeUser(name: name, email: email, profilePic: profilePic,backgroundPic: backgroundPic,
                    uid: uid, likes: likes, registered: registered,
                    intro: intro, ranking: ranking, posts: posts, bookmarks: bookmarks);

  }

}