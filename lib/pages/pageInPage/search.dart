import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/widget/searchName.dart';
import 'package:like_app/widget/searchTag.dart';
import 'package:like_app/widget/searchUser.dart';

class Search extends StatefulWidget {

  final String searchName;

  const Search({super.key, required this.searchName});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  TextEditingController? searchController;

  String? uId = "";

  bool isUIdLoading = true;

  int _currentIndex = 0;

  @override
  void initState() {
    searchController = new TextEditingController(text: widget.searchName);
    _tabController = TabController(
      length: 3,
      vsync: this, 
    );
    getUId();

    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
      print("Selected Index: " + _tabController.index.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    searchController!.dispose();
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

  @override
  Widget build(BuildContext context) {

    final _tabContent = <Widget>[
      searchController!.text == "" ? 
            Container() : 
            searchName(searchedName: searchController!.text, uId: uId!),
      searchController!.text == "" ? 
            Container() :
            SearchUser(searchedName: searchController!.text, uId: uId!),
      searchController!.text == "" ? 
            Container() :
            SearchTag(searchedName: searchController!.text, uId: uId!)
    ];

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
                  searchController!.text = _;
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
                ],
              )
          ),
        body:

        IndexedStack(
          index: _currentIndex,
          children: _tabContent,
        ),

        // TabBarView(
        //   controller: _tabController,
        //   children: [
        //     searchController!.text == "" ? 
        //     Container() : 
        //     isWholePostLengthLoading? Container() :
        //     NotificationListener<ScrollNotification>(
        //       onNotification: (scrollNotification) {
        //         if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && isLoadingMorePostsPossible && !isMoreLoading1 && wholePostsLength! > posts!.length) {
        //           isMoreLoading1 = true;

        //           getMorePostsBySearchName(posts![posts!.length - 1]['description'], posts![posts!.length - 1]['postId']);

        //         }
        //         return true;
        //       },
        //       child: SingleChildScrollView(
        //         child: 
                
        //         FutureBuilder(
        //         future: getPostsBySearchName(searchController!.text), 
        //         builder: (context, snapshot) {

        //           // print("object");
                  
        //           if (isPostLoading) {
        //             return Center(
        //               child: CircularProgressIndicator(),
        //             );
        //           }
        //           else {
        //               return Wrap(children: List.generate(posts!.length, (index) { 
        //                 return PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(uId), likes: posts![index]['likes'].length, uId: uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: posts![index]["bookMarks"].contains(uId), tags: posts![index]["tags"], posted: posts![index]["posted"],);

        //             }));
        //           // }
        //           } 
        //         },
        //       ),

        //       )
        //     ),
        //     searchController!.text == "" ? 
        //     Container() :
        //     isWholeAccountsLengthLoading ? Container() :
        //      NotificationListener<ScrollNotification>(
        //       onNotification: (scrollNotification) {
        //         if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && isLoadingMoreUsersPossible && !isMoreLoading2 && wholeAccountsLength! > users!.length) {
        //           isMoreLoading2 = true;

        //           getMoreUsersBySearchName(users![users!.length - 1]['name'], users![users!.length - 1]['uid']);

        //         }
        //         return true;
        //       },
        //     child: SingleChildScrollView(
        //       child: FutureBuilder(
        //       future: future2, 
        //       builder: (context, snapshot) {
        //           if (isUserLoading) {
        //             return Center(
        //                 child: CircularProgressIndicator(),
        //               );
        //           }
        //           else {

        //             return Wrap(children: List.generate(users!.length, (index) {
        //               print(users!.length);
        //                 if (profileURLs.length != users!.length) {
        //                   profileURLs.add("");
        //                   isprofLoadings.add(true);

        //                   getProfileURL(users![index]["email"], users![index]["profilePic"], index);
        //                 }

        //                 return 
        //                   isprofLoadings[index] ? Center(
        //                     child: CircularProgressIndicator(),
        //                   ) : 
        //                 InkWell(
        //                   onTap: () {
        //                     nextScreen(context, OthersProfilePages(uId: uId!, postOwnerUId: users![index]["uid"]));
        //                   },
        //                   child :
        //                     ListTile(
        //                       leading: Container(
        //                         width: MediaQuery.of(context).size.height * 0.05,
        //                         height: MediaQuery.of(context).size.height * 0.05,
        //                         decoration: BoxDecoration(
        //                           color: const Color(0xff7c94b6),
        //                           image: DecorationImage(
        //                             image: NetworkImage(profileURLs[index]),
        //                             fit: BoxFit.cover,
        //                           ),
        //                           borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height * 0.8)),
        //                           border: Border.all(
        //                             color: Colors.white,
        //                             width: MediaQuery.of(context).size.height * 0.005,
        //                           ),
        //                         ),
        //                       ),
        //                       title: Text(
        //                         users![index]["name"],
        //                         style: TextStyle(fontWeight: FontWeight.w600),
        //                       ),
        //                       subtitle: Text(
        //                         users![index]["email"]
        //                       ),
        //                     )
        //                  );
        //               },
        //             ));
        //           }
        //         }
        //       )
        //     ),
        //     ),
        //     searchController!.text == "" ? 
        //     Container() :
        //     isWholeTagsLengthLoading ? Container() :
        //      NotificationListener<ScrollNotification>(
        //       onNotification: (scrollNotification) {
        //         if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent  && isLoadingMoreTagsPossible && !isMoreLoading3 && wholeTagsLength! > tags!.length) {
        //           isMoreLoading3 = true;
        //         }
        //         return true;
        //       },
        //     child: SingleChildScrollView(
        //       child: FutureBuilder(
        //       future: future3, 
        //       builder: (context, snapshot) {
        //         if (isTagLoading) {
        //           return Center(
        //             child: CircularProgressIndicator(),
        //           );
        //         }
        //         else {
        //             return Wrap(children: List.generate(tags!.length, (index) {
        //                 return Column(
        //                   children: [
        //                     SizedBox(height: 10,),

        //                     PostWidget(email: tags![index]["email"], postID: tags![index]["postId"], name: tags![index]["writer"], image: tags![index]["images"], description: tags![index]["description"],isLike: tags![index]["likes"].contains(uId!), likes: tags![index]["likes"].length, uId: uId!, postOwnerUId: tags![index]["uId"], withComment: tags![index]["withComment"], isBookMark: tags![index]["bookMarks"].contains(uId), tags: tags![index]["tags"], posted: tags![index]["posted"],)
        //                   ],
        //                 );
        //               },
        //             ));
        //         }
        //       },
        //     ),
        //     )
        //     )
        //   ]
        // )
      );
  }
}