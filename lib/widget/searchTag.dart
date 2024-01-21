import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/post_service.dart';
import 'package:like_app/widget/post_widget.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchTag extends StatefulWidget {

  final String searchedName;
  final String uId;

  const SearchTag({super.key, required this.searchedName, required this.uId});

  @override
  State<SearchTag> createState() => _SearchTagState();
}

class _SearchTagState extends State<SearchTag> {

  Map<dynamic, dynamic>? tags;
  bool isTagLoading = true;
  bool isLoadingMoreTagsPossible = true;
  bool isMoreLoading = false;
  bool isSortItemsLoading = true;
  bool isCategoryItemsLoading = true;

  bool isErrorOccurred = false;
  var logger = Logger();

  String? userName;

  bool isUserNameLoading = false;

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
    'Latest',
    'Oldest',
  ];

  String category = "";
  String sort = "Latest";

  @override
  void initState() {

    Future.delayed(Duration(seconds: 0)).then((value) async {
      await getTagsBySearchName(widget.searchedName);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setSortContents();
    setCategoryContents();
  }

  void setSortContents() {
    setState(() {
      if (this.mounted) {
        sortedBy = [
          AppLocalizations.of(context)!.latest,
          AppLocalizations.of(context)!.oldest,
        ];
        sort = AppLocalizations.of(context)!.latest;
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


  Future getTagsBySearchName(String searchedName) async {
    try {
      PostService postService = new PostService();
      await postService.getTagsBySearchName(searchedName).then((value) => {
        tags = value,
        if (this.mounted) {
            setState(() {
              isTagLoading = false;
            })
        }
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.log(Level.error, "error occurred while getting posts by tags\nerror: " + e.toString());
    }
    
  }

  Future getMoreTagsBySearchName(String searchedName, String postNumber) async {
    try {

      PostService postService = new PostService();
      await postService.loadMoreTagsBySearchName(searchedName, postNumber).then((value) => {
        if (value.length == 0) {
          if (this.mounted) {
            setState(() {
              isLoadingMoreTagsPossible = false;
            })
          }
        }
        else {
          if (this.mounted) {
            for (int i = 0; i < value.length; i++) {
              setState(() {
                tags![tags!.length] = value[i];
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
      logger.log(Level.error, "error occurred while getting more posts by tags\nerror: " + e.toString());
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
                      isTagLoading = true;
                      isLoadingMoreTagsPossible = true;
                    }
                  );
                }
                Future.delayed(Duration(seconds: 0)).then((value) async {
                  await getTagsBySearchName(widget.searchedName);
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : (isTagLoading || isSortItemsLoading || isCategoryItemsLoading) ? Center(child: CircularProgressIndicator()) :
       NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent  && isLoadingMoreTagsPossible && !isMoreLoading) {
                  isMoreLoading = true;

                  getMoreTagsBySearchName(widget.searchedName, tags![tags!.length - 1]['postNumber'].toString());
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  if (this.mounted) {
                    setState(() {
                      isTagLoading = true;
                      isLoadingMoreTagsPossible = true;
                    });
                  }
                  await getTagsBySearchName(widget.searchedName);
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
                        if (this.mounted) {
                          setState(() {
                            sort = value!;
                            isTagLoading = true;
                            isLoadingMoreTagsPossible = true;
                          });
                        }
                        await getTagsBySearchName(widget.searchedName);
                      } 
                    ),
                  )
                ],
              ),
              Wrap(children: List.generate(tags!.length, (index) { 
                try {

                  if (sort == "Latest" || sort == "Neueste" || sort == "El último" || sort == "Dernière" || sort == "नवीनतम" || sort == "最新" || sort == "최신순") {
                    if (category == "") {
                      return PostWidget(email: tags![index]["email"], postID: tags![index]["postId"], name: tags![index]["writer"], image: tags![index]["images"], description: tags![index]["description"],isLike: tags![index]["likes"].contains(widget.uId), likes: tags![index]["likes"].length, uId: widget.uId, postOwnerUId: tags![index]["uId"], withComment: tags![index]["withComment"], isBookMark: tags![index]["bookMarks"].contains(widget.uId), tags: tags![index]["tags"], posted: tags![index]["posted"], isProfileClickable: true,);
                    } 
                    else {
                      if (tags![index]['category'] == HelperFunctions().changeCategoryToEnglish(category)) {
                        return PostWidget(email: tags![index]["email"], postID: tags![index]["postId"], name: tags![index]["writer"], image: tags![index]["images"], description: tags![index]["description"],isLike: tags![index]["likes"].contains(widget.uId), likes: tags![index]["likes"].length, uId: widget.uId, postOwnerUId: tags![index]["uId"], withComment: tags![index]["withComment"], isBookMark: tags![index]["bookMarks"].contains(widget.uId), tags: tags![index]["tags"], posted: tags![index]["posted"], isProfileClickable: true,);
                      }
                      else {
                        return Container();
                      }
                    }
                  } 
                  else if (sort == "Oldest" || sort == "Alter Schuss" || sort == "Más antiguo" || sort == "Le plus ancien" || sort == "सबसे पुराने" || sort == "最古の" || sort == "오래된순") {
                    if (category == "") {
                      return PostWidget(email: tags![tags!.length - 1 - index]['email'], postID: tags![tags!.length - 1 - index]['postId'], name: tags![tags!.length - 1 - index]['writer'], image: tags![tags!.length - 1 - index]['images'], description: tags![tags!.length - 1 - index]['description'],isLike: tags![tags!.length - 1 - index]['likes'].contains(widget.uId), likes: tags![tags!.length - 1 - index]['likes'].length, uId: widget.uId, postOwnerUId: tags![tags!.length - 1 - index]['uId'], withComment: tags![tags!.length - 1 - index]["withComment"], isBookMark: tags![tags!.length - 1 - index]["bookMarks"].contains(widget.uId), tags: tags![tags!.length - 1 - index]["tags"], posted: tags![tags!.length - 1 - index]["posted"],isProfileClickable: true,);
                    } 
                    else {
                      if (tags![tags!.length - 1 - index]['category'] == HelperFunctions().changeCategoryToEnglish(category)) {
                        return PostWidget(email: tags![tags!.length - 1 - index]['email'], postID: tags![tags!.length - 1 - index]['postId'], name: tags![tags!.length - 1 - index]['writer'], image: tags![tags!.length - 1 - index]['images'], description: tags![tags!.length - 1 - index]['description'],isLike: tags![tags!.length - 1 - index]['likes'].contains(widget.uId), likes: tags![tags!.length - 1 - index]['likes'].length, uId: widget.uId, postOwnerUId: tags![tags!.length - 1 - index]['uId'], withComment: tags![tags!.length - 1 - index]["withComment"], isBookMark: tags![tags!.length - 1 - index]["bookMarks"].contains(widget.uId), tags: tags![tags!.length - 1 - index]["tags"], posted: tags![tags!.length - 1 - index]["posted"],isProfileClickable: true,);
                      }
                      else {
                        return Container();
                      }
                    }
                  }
                  else {
                    return Container();
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
                                  isTagLoading = true;
                                  isLoadingMoreTagsPossible = true;
                                }
                              );
                            }
                            Future.delayed(Duration(seconds: 0)).then((value) async {
                              await getTagsBySearchName(widget.searchedName);
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
                      isTagLoading = true;
                      isLoadingMoreTagsPossible = true;
                    }
                  );
                }
                Future.delayed(Duration(seconds: 0)).then((value) async {
                  await getTagsBySearchName(widget.searchedName);
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