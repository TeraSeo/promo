class LikeUser {
  String? name;
  String? email;
  String? profilePic;
  String? backgroundPic;
  String? uid;
  int? likes;
  String? registered;
  String? intro;
  int? ranking;
  Map<String, dynamic>? posts;
  
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
      });

  factory LikeUser.fromJson(Map<String, dynamic> data) {

    String name = data['name'] as String;
    String email = data['email'] as String;
    String profilePic = data['profilePic'] as String;
    String backgroundPic = data['backgroundPic'] as String;
    String uid = data['uid'] as String;
    int likes = data['likes'] as int;
    String registered = data['registered'] as String;
    String intro = data['intro'] as String;
    int ranking = data['ranking'] as int;
    Map<String, dynamic> posts = data['posts'] as Map<String, dynamic>;

    return LikeUser(name: name, email: email, profilePic: profilePic,backgroundPic: backgroundPic,
                    uid: uid, likes: likes, registered: registered,
                    intro: intro, ranking: ranking, posts: posts);

  }

}
