import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/widget/post_widget.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchName extends StatefulWidget {

  final String searchedName;
  final String uId;

  const SearchName({super.key, required this.searchedName, required this.uId});

  @override
  State<SearchName> createState() => _SearchNameState();
}


class _SearchNameState extends State<SearchName> {

  Map<dynamic, dynamic>? posts;

  bool isPostLoading = true;
  bool isMoreLoading = false;
  bool isLoadingMorePostsPossible = true;
  bool isSortItemsLoading = true;
  bool isCategoryItemsLoading = true;

  bool isErrorOccurred = false;
  var logger = Logger();
  PostService postService = PostService.instance;

  List<String>? categoryItems = [
    '',
    'News',
    'Entertainment',
    'Sports',
    'Food',
    'Economy',
    'Stock',
    'Shopping',
    'Science',
    'Etc.'
  ];

  List<String>? sortedBy = [
    'related',
    'not related',
  ];

  String category = "";
  String sort = "related";

  String? preferredLanguage;
  bool isPreferredLanguageLoading = true;

  @override
  void initState() {

    Future.delayed(Duration(seconds: 0)).then((value) async {
      await getPostsBySearchName(widget.searchedName);
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setSortContents();
    setCategoryContents();
    setPreferredLanguageLoading();
  }

  void setPreferredLanguageLoading() {
    HelperFunctions.getUserLanguageFromSF().then((value) {
      preferredLanguage = value;
      setState(() {
        if (this.mounted) {
          isPreferredLanguageLoading = false;
        }
      });
    }); 
  }

  void setSortContents() {
    setState(() {
      if (this.mounted) {
        sortedBy = [
          AppLocalizations.of(context)!.rel,
          AppLocalizations.of(context)!.notRel,
        ];
        sort = AppLocalizations.of(context)!.rel;
        isSortItemsLoading = false;
      }
    });
  }

  void setCategoryContents() {
    setState(() {
      if (this.mounted) {
        categoryItems = [
          '',
          AppLocalizations.of(context)!.news,
          AppLocalizations.of(context)!.entertainment,
          AppLocalizations.of(context)!.sports,
          AppLocalizations.of(context)!.food,
          AppLocalizations.of(context)!.economy,
          AppLocalizations.of(context)!.stock,
          AppLocalizations.of(context)!.shopping,
          AppLocalizations.of(context)!.science,
          AppLocalizations.of(context)!.etc
        ];
        isCategoryItemsLoading = false;
      }
    });
  }

  Future getPostsBySearchName(String searchedName) async {
    try {
      await postService.getPostsBySearchName(searchedName).then((value) => {
        posts = value,
        if (this.mounted) {
            setState(() {
              isPostLoading = false;
            })
        }
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.log(Level.error, "error occurred while getting posts by name\nerror: " + e.toString());
    }
  } 


  Future getMorePostsBySearchName(String searchedName, String postId, String searchedTxt) async {
    try {
      await postService.loadMorePostsPostsBySearchName(searchedName, postId, searchedTxt).then((value) => {
        if (value.length == 0) {
          if (this.mounted) {
            setState(() {
              isLoadingMorePostsPossible = false;
            })
          }
        }
        else {
          if (this.mounted){
            for (int i = 0; i < value.length; i++) {
              setState(() {
                posts![posts!.length] = value[i];
              })
            },
          }
        },
        if (this.mounted) {
          setState(() {
            isMoreLoading = false;
          })
        }
      });

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.log(Level.error, "error occurred while getting more posts by name\nerror: " + e.toString());
    }
    
  }

  @override
  Widget build(BuildContext context) {
    try {
      return isErrorOccurred ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                      isErrorOccurred = false;
                      isPostLoading = true;
                      isLoadingMorePostsPossible = true;
                      isPreferredLanguageLoading = true;
                    }
                  );
                }
                Future.delayed(Duration(seconds: 0)).then((value) async {
                  await getPostsBySearchName(widget.searchedName);
                  setPreferredLanguageLoading();
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : (isPostLoading || isSortItemsLoading || isCategoryItemsLoading || isPreferredLanguageLoading) ? Center(child: CircularProgressIndicator()) : NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && isLoadingMorePostsPossible && !isMoreLoading) {

            isMoreLoading = true;
            getMorePostsBySearchName(posts![posts!.length - 1]['description'], posts![posts!.length - 1]['postId'], widget.searchedName);

          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              if (this.mounted) {
                setState(() {
                  isPostLoading = true;
                  isLoadingMorePostsPossible = true;
                });
              }
              await getPostsBySearchName(widget.searchedName);

            } catch(e) {
              if (this.mounted) {
                setState(() {
                  isErrorOccurred = true;
                });
              }
              logger.log(Level.error, "error occurred while refreshing\nerror: " + e.toString());
            }
            
          },
          child: SingleChildScrollView(
            child: Column(children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    width: MediaQuery.of(context).size.width * 0.43,
                    height: MediaQuery.of(context).size.height * 0.04,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(width: MediaQuery.of(context).size.height * 0.002)
                    ),
                    child: DropdownButton<String>(
                      value: category,
                      isExpanded: true,
                      items: categoryItems!.map(buildMenuItem).toList(),
                      onChanged: (value) {
                        if (this.mounted) {
                          setState(() {
                            category = value!;
                          });
                        }
                      } 
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    width: MediaQuery.of(context).size.width * 0.43,
                    height: MediaQuery.of(context).size.height * 0.04,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(width: MediaQuery.of(context).size.height * 0.002)
                    ),
                    child: DropdownButton<String>(
                      value: sort,
                      isExpanded: true,
                      items: sortedBy!.map(buildMenuItem).toList(),
                      onChanged: (value) async {
                        try {
                          if (this.mounted) {
                            setState(() {
                              sort = value!;
                              isPostLoading = true;
                              isLoadingMorePostsPossible = true;
                            });
                          }
                          await getPostsBySearchName(widget.searchedName);

                        } catch(e) {
                          if (this.mounted) {
                            setState(() {
                              isErrorOccurred = true;
                            });
                          }
                          logger.log(Level.error, "error occurred while refreshing\nerror: " + e.toString());
                        }
                      }
                    ),
                  )
                ],
              ),
              Wrap(children: List.generate(posts!.length, (index) {
                try {

                  if (sort == "related" || sort == "verwandt" || sort == "relacionada" || sort == "en rapport" || sort == "संबंधित" || sort == "関連順" || sort == "관련") {

                    if (category == "") {
                      return PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(widget.uId), likes: posts![index]['likes'].length, uId: widget.uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: posts![index]["bookMarks"].contains(widget.uId), tags: posts![index]["tags"], posted: posts![index]["posted"],isProfileClickable: true, preferredLanguage: preferredLanguage!,);
                    } 
                    else if (posts![index]['category'] == HelperFunctions().changeCategoryToEnglish(category)) {
                      return PostWidget(email: posts![index]['email'], postID: posts![index]['postId'], name: posts![index]['writer'], image: posts![index]['images'], description: posts![index]['description'],isLike: posts![index]['likes'].contains(widget.uId), likes: posts![index]['likes'].length, uId: widget.uId, postOwnerUId: posts![index]['uId'], withComment: posts![index]["withComment"], isBookMark: posts![index]["bookMarks"].contains(widget.uId), tags: posts![index]["tags"], posted: posts![index]["posted"],isProfileClickable: true, preferredLanguage: preferredLanguage!,);
                    }
                    else {
                      return Container();
                    }
                  } else {
                    if (category == "") {
                      return PostWidget(email: posts![posts!.length - 1 - index]['email'], postID: posts![posts!.length - 1 - index]['postId'], name: posts![posts!.length - 1 - index]['writer'], image: posts![posts!.length - 1 - index]['images'], description: posts![posts!.length - 1 - index]['description'],isLike: posts![posts!.length - 1 - index]['likes'].contains(widget.uId), likes: posts![posts!.length - 1 - index]['likes'].length, uId: widget.uId, postOwnerUId: posts![posts!.length - 1 - index]['uId'], withComment: posts![posts!.length - 1 - index]["withComment"], isBookMark: posts![posts!.length - 1 - index]["bookMarks"].contains(widget.uId), tags: posts![posts!.length - 1 - index]["tags"], posted: posts![posts!.length - 1 - index]["posted"],isProfileClickable: true, preferredLanguage: preferredLanguage!);
                    } 
                    else if (posts![posts!.length - 1 - index]['category'] == HelperFunctions().changeCategoryToEnglish(category)) {
                      return PostWidget(email: posts![posts!.length - 1 - index]['email'], postID: posts![posts!.length - 1 - index]['postId'], name: posts![posts!.length - 1 - index]['writer'], image: posts![posts!.length - 1 - index]['images'], description: posts![posts!.length - 1 - index]['description'],isLike: posts![posts!.length - 1 - index]['likes'].contains(widget.uId), likes: posts![posts!.length - 1 - index]['likes'].length, uId: widget.uId, postOwnerUId: posts![posts!.length - 1 - index]['uId'], withComment: posts![posts!.length - 1 - index]["withComment"], isBookMark: posts![posts!.length - 1 - index]["bookMarks"].contains(widget.uId), tags: posts![posts!.length - 1 - index]["tags"], posted: posts![posts!.length - 1 - index]["posted"],isProfileClickable: true, preferredLanguage: preferredLanguage!);
                    }
                    else {
                      return Container();
                    }

                  }
                  
                } catch(e) {
                  return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(onPressed: () {
                              if (this.mounted) {
                                setState(() {
                                    isErrorOccurred = false;
                                    isPostLoading = true;
                                    isLoadingMorePostsPossible = true;
                                    isPreferredLanguageLoading = true;
                                  }
                                );
                              }
                              Future.delayed(Duration(seconds: 0)).then((value) async {
                                await getPostsBySearchName(widget.searchedName);
                                setPreferredLanguageLoading();
                              });
                            }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
                            Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
                          ],
                        )
                    );
                }
            }))
            ],)
          )
        ));

    } catch(e) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                      isErrorOccurred = false;
                      isPostLoading = true;
                      isLoadingMorePostsPossible = true;
                      isPreferredLanguageLoading = true;
                    }
                  );
                }
                Future.delayed(Duration(seconds: 0)).then((value) async {
                  await getPostsBySearchName(widget.searchedName);
                  setPreferredLanguageLoading();
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );
    }
  }    

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
    )
  );
}