import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/storage.dart';
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

  @override
  Widget build(BuildContext context) {

    final future1 = FirebaseFirestore.instance.collection("post").
                          where('description', isGreaterThanOrEqualTo: searchController.text).
                          get();

    final future2 = FirebaseFirestore.instance.collection("user").
                          where('name', isGreaterThanOrEqualTo: searchController.text).
                          get();

    final future3 = FirebaseFirestore.instance.collection("post").
                          where('tags', arrayContains: searchController.text).
                          get();

    return isUIdLoading? 
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
            SingleChildScrollView(
              child: FutureBuilder(
              future: future1, 
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else {
                    return Wrap(children: List.generate((snapshot.data! as dynamic).docs.length, (index) { 
                    
                      return PostWidget(email: snapshot.data!.docs[index]["email"], postID: snapshot.data!.docs[index]["postId"], name: snapshot.data!.docs[index]["writer"], image: snapshot.data!.docs[index]["images"], description: snapshot.data!.docs[index]["description"],isLike: snapshot.data!.docs[index]["likes"].contains(uId!), likes: snapshot.data!.docs[index]["likes"].length, uId: uId!, postOwnerUId: snapshot.data!.docs[index]["uId"], withComment: snapshot.data!.docs[index]["withComment"], isBookMark: snapshot.data!.docs[index]["bookMarks"].contains(uId), tags: snapshot.data!.docs[index]["tags"], posted: snapshot.data!.docs[index]["posted"],);

                  }));
                }
                } 
              },
            ),
            ),
            searchController.text == "" ? 
            Container() :
            SingleChildScrollView(
              child: FutureBuilder(
              future: future2, 
              builder: (context, snapshot) {
                
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else {

                    return Wrap(children: List.generate((snapshot.data! as dynamic).docs.length, (index) {
                        if (profileURLs.length != (snapshot.data! as dynamic).docs.length) {
                          profileURLs.add("");
                          isprofLoadings.add(true);

                          getProfileURL(snapshot.data!.docs[index]["email"], snapshot.data!.docs[index]["profilePic"], index);
                        }

                        return 
                          isprofLoadings[index] ? Center(
                            child: CircularProgressIndicator(),
                          ) : 
                          InkWell(
                          onTap: () {
                            nextScreen(context, OthersProfilePages(uId: uId!, postOwnerUId: snapshot.data!.docs[index]["uid"]));
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
                                snapshot.data!.docs[index]["name"],
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                snapshot.data!.docs[index]["email"]
                              ),
                            )
                          );
                      },
                    ));

                  }
                }
                
              },
            ),
            ),
            searchController.text == "" ? 
            Container() :
            SingleChildScrollView(
              child: FutureBuilder(
              future: future3, 
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else {

                    return Wrap(children: List.generate((snapshot.data! as dynamic).docs.length, (index) {
                        return Column(
                          children: [
                            SizedBox(height: 10,),

                            PostWidget(email: snapshot.data!.docs[index]["email"], postID: snapshot.data!.docs[index]["postId"], name: snapshot.data!.docs[index]["writer"], image: snapshot.data!.docs[index]["images"], description: snapshot.data!.docs[index]["description"],isLike: snapshot.data!.docs[index]["likes"].contains(uId!), likes: snapshot.data!.docs[index]["likes"].length, uId: uId!, postOwnerUId: snapshot.data!.docs[index]["uId"], withComment: snapshot.data!.docs[index]["withComment"], isBookMark: snapshot.data!.docs[index]["bookMarks"].contains(uId), tags: snapshot.data!.docs[index]["tags"], posted: snapshot.data!.docs[index]["posted"],)
                          ],
                        );
                      },
                    ));

                  }
                }
                
              },
            ),
            )
          ]
        )
      );
  }
}