import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widget/post_widget.dart';
import 'package:like_app/widgets/widgets.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  TextEditingController searchController = new TextEditingController(text: "");

  String? uId = "";

  bool isUIdLoading = true;

  List<bool> isprofLoadings = [];
  List<String> profileURLs = [];

  @override
  void initState() {
    _tabController = TabController(
      length: 3,
      vsync: this, 
    );
    getUId();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _tabController.dispose();
  }

  void getUId() async{

    await HelperFunctions.getUserUIdFromSF().then((value) => {
      uId = value,
      if (this.mounted) {
        setState(() {
          isUIdLoading = false;
        })
      }
    });
  }

  Map<dynamic, dynamic>? posts;
  bool isPostLoading = true;
  bool isLoadingMorePostsPossible = true;
  bool isMoreLoading1 = false;
  
  late final Future future1 = getPostsBySearchName(searchController.text);

  Future getPostsBySearchName(String searchedName) async {
    PostService postService = new PostService();
     await postService.getPostsBySearchName(searchedName).then((value) => {
      posts = value,
      if (this.mounted) {
          setState(() {
            isPostLoading = false;
          })
      }
    });
  }

  Future getMorePostsBySearchName(String searchedName, String postId) async {
    PostService postService = new PostService();
     await postService.loadMorePostsPostsBySearchName(searchedName, postId).then((value) => {
      if (value.length == 0) {
        setState(() {
          isLoadingMorePostsPossible = false;
        })
      }
      else {
        for (int i = 0; i < value.length; i++) {
          setState(() {
            posts![posts!.length] = value[i];
          })
        },
      },
      if (this.mounted) {
        setState(() {
          isMoreLoading1 = false;
        })
      }
    });
  }

  Map<dynamic, dynamic>? users;
  bool isUserLoading = true;
  bool isLoadingMoreUsersPossible = true;
  bool isMoreLoading2 = false;

  late final Future future2 = getUsersBySearchName(searchController.text);

  Future getUsersBySearchName(String searchedName) async {
    DatabaseService databaseService = new DatabaseService();
    databaseService.getUserBySearchedName(searchedName).then((value) => {
      users = value,
      if (this.mounted) {
        setState(() {
          isUserLoading = false;
        })
      }
    });
  }

  Future getMoreUsersBySearchName(String searchedName, String uId) async {
    DatabaseService databaseService = new DatabaseService();
     await databaseService.loadMoreUsersBySearchedName(searchedName, uId).then((value) => {
      if (value.length == 0) {
        setState(() {
          isLoadingMoreUsersPossible = false;
        })
      }
      else {
        for (int i = 0; i < value.length; i++) {
          setState(() {
            users![users!.length] = value[i];
          })
        },
      },
      
      if (this.mounted) {
        setState(() {
          isMoreLoading2 = false;
          profileURLs = [];
          isprofLoadings = [];    
        })
      }
    });
  }

  getProfileURL(String email, String profile, int index) async {

    Storage storage = new Storage();

    try {
      await storage.loadProfileFile(email, profile).then((value) => {
        profileURLs[index] = value,
        if (this.mounted) {
          setState(() {
            isprofLoadings[index] = false;
          })
        }
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isprofLoadings[index] = false;
        });
      }
    }
  }

  Map<dynamic, dynamic>? tags;
  bool isTagLoading = true;
  bool isLoadingMoreTagsPossible = true;
  bool isMoreLoading3 = false;
  
  late final Future future3 = getTagsBySearchName(searchController.text);

  Future getTagsBySearchName(String searchedName) async {
    PostService postService = new PostService();
     await postService.getTagsBySearchName(searchedName).then((value) => {
      tags = value,
      if (this.mounted) {
          setState(() {
            isTagLoading = false;
          })
      }
    });
  }

  Future getMoreTagsBySearchName(String searchedName, String date) async {
    PostService postService = new PostService();
     await postService.loadMoreTagsBySearchName(searchedName, date).then((value) => {
      if (value.length == 0) {
        setState(() {
          isLoadingMoreTagsPossible = false;
        })
      }
      else {
        for (int i = 0; i < value.length; i++) {
          setState(() {
            tags![tags!.length] = value[i];
          })
        },
      },
      if (this.mounted) {
        setState(() {
          isMoreLoading3 = false;
        })
      }
    });
  }


  int? wholePostsLength = 0;
  bool isWholePostLengthLoading = true;
  int? wholeAccountsLength = 0;
  bool isWholeAccountsLengthLoading = true;
  int? wholeTagsLength = 0;
  bool isWholeTagsLengthLoading = true;


  void getPostsLength(String searchedName) async {
    await FirebaseFirestore.instance.collection("post").
      where('description', isGreaterThanOrEqualTo: searchedName).get().then((value) => {
      wholePostsLength = value.docs.length,
      setState(() {
        isWholePostLengthLoading = false;
      }),
    });
  }

  void getAccountsLength(String searchedName) async {

    await FirebaseFirestore.instance.collection("user").
      where('name', isGreaterThanOrEqualTo: searchController.text).
      get().then((value) => {
        wholeAccountsLength = value.docs.length,
        setState(() {
          isWholeAccountsLengthLoading = false;
        }),
    });
  }

  void getTagsLength(String searchedName) async {

    await FirebaseFirestore.instance.collection("post").
      where('tags', arrayContains: searchController.text).limit(7).
      get().then((value) => {
        wholeTagsLength = value.docs.length,
        setState(() {
          isWholeTagsLengthLoading = false;
        }),
    });
  }

  @override
  Widget build(BuildContext context) {

    // final future3 = FirebaseFirestore.instance.collection("post").
    //                       where('tags', arrayContains: searchController.text).limit(7).
    //                       get();

    return isUIdLoading ? 
      Center(
        child: CircularProgressIndicator(),
      )
      : 
      Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.07,
          backgroundColor: Theme.of(context).primaryColor,
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back, color: Colors.white, size: MediaQuery.of(context).size.width * 0.06,),
          //   onPressed: () => Navigator.of(context).pop(),
          // ),
          title: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none
                ),
                hintText: "Search anything",
                hintStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Colors.white
              ),
              onFieldSubmitted: (String _) {
                setState(() {
                  searchController.text = _;
                });
                getPostsLength(_);
                getAccountsLength(_);
                getTagsLength(_);
              },
            ),
            bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(text: "posts",),
                  Tab(text: "account",),
                  Tab(text: "tags",)
                ]
              )
          ),
        body:
        TabBarView(
          controller: _tabController,
          children: [
            searchController.text == "" ? 
            Container() : 
            isWholePostLengthLoading? Container() :
            NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && isLoadingMorePostsPossible && !isMoreLoading1 && wholePostsLength! > posts!.length) {
                  isMoreLoading1 = true;

                  getMorePostsBySearchName(posts![posts!.length - 1]['description'], posts![posts!.length - 1]['postId']);

                }
                return true;
              },
              child: SingleChildScrollView(
                child: 
                
                FutureBuilder(
                future: future1, 
                builder: (context, snapshot) {
                  
                  if (isPostLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else {
                      return Wrap(children: List.generate(posts!.length, (index) { 
                        return PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(uId), likes: posts![index]['likes'].length, uId: uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: posts![index]["bookMarks"].contains(uId), tags: posts![index]["tags"], posted: posts![index]["posted"],);

                    }));
                  // }
                  } 
                },
              ),

              )
            ),
            searchController.text == "" ? 
            Container() :
            isWholeAccountsLengthLoading ? Container() :
             NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && isLoadingMoreUsersPossible && !isMoreLoading2 && wholeAccountsLength! > users!.length) {
                  isMoreLoading2 = true;

                  print("object");

                  getMoreUsersBySearchName(users![users!.length - 1]['name'], users![users!.length - 1]['uid']);

                }
                return true;
              },
            child: SingleChildScrollView(
              child: FutureBuilder(
              future: future2, 
              builder: (context, snapshot) {
                  if (isUserLoading) {
                    return Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                  else {

                    return Wrap(children: List.generate(users!.length, (index) {
                      print(users!.length);
                        if (profileURLs.length != users!.length) {
                          profileURLs.add("");
                          isprofLoadings.add(true);

                          print(profileURLs.length);


                          getProfileURL(users![index]["email"], users![index]["profilePic"], index);
                        }

                        return 
                          isprofLoadings[index] ? Center(
                            child: CircularProgressIndicator(),
                          ) : 
                        InkWell(
                          onTap: () {
                            nextScreen(context, OthersProfilePages(uId: uId!, postOwnerUId: users![index]["uid"]));
                          },
                          child :
                            ListTile(
                              leading: Container(
                                width: MediaQuery.of(context).size.height * 0.05,
                                height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                  color: const Color(0xff7c94b6),
                                  image: DecorationImage(
                                    image: NetworkImage(profileURLs[index]),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height * 0.8)),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: MediaQuery.of(context).size.height * 0.005,
                                  ),
                                ),
                              ),
                              title: Text(
                                users![index]["name"],
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                users![index]["email"]
                              ),
                            )
                         );
                      },
                    ));
                  }
                }
              )
            ),
            ),
            searchController.text == "" ? 
            Container() :
            isWholeTagsLengthLoading ? Container() :
             NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent  && isLoadingMoreTagsPossible && !isMoreLoading3 && wholeTagsLength! > tags!.length) {
                  isMoreLoading3 = true;

                  print("end2");
                }
                return true;
              },
            child: SingleChildScrollView(
              child: FutureBuilder(
              future: future3, 
              builder: (context, snapshot) {
                if (isTagLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else {
                    return Wrap(children: List.generate(tags!.length, (index) {
                        return Column(
                          children: [
                            SizedBox(height: 10,),

                            PostWidget(email: tags![index]["email"], postID: tags![index]["postId"], name: tags![index]["writer"], image: tags![index]["images"], description: tags![index]["description"],isLike: tags![index]["likes"].contains(uId!), likes: tags![index]["likes"].length, uId: uId!, postOwnerUId: tags![index]["uId"], withComment: tags![index]["withComment"], isBookMark: tags![index]["bookMarks"].contains(uId), tags: tags![index]["tags"], posted: tags![index]["posted"],)
                          ],
                        );
                      },
                    ));
                }
              },
            ),
            )
            )
          ]
        )
      );
  }
}