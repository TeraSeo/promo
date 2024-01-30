import 'package:flutter/material.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchUser extends StatefulWidget {

  final String searchedName;
  final String uId;

  const SearchUser({super.key, required this.searchedName, required this.uId});

  @override
  State<SearchUser> createState() => _SesarchUserState();
}

class _SesarchUserState extends State<SearchUser> {

  Map<dynamic, dynamic>? users;
  bool isUserLoading = true;
  bool isLoadingMoreUsersPossible = true;
  bool isMoreLoading = false;
  bool isProfileLoading = true;

  bool isErrorOccurred = false;
  Logging logger = Logging();

  List<bool> isprofLoadings = [];
  List<String> profileURLs = [];

  @override
  void initState() {

    Future.delayed(Duration(seconds: 0)).then((value) async {
      await getUsersBySearchName(widget.searchedName);
    });


    super.initState();
  }

  Future getUsersBySearchName(String searchedName) async {
    try {
      DatabaseService databaseService = new DatabaseService();
      databaseService.getUserBySearchedName(searchedName).then((value) => {
        users = value,
        if (this.mounted) {
          setState(() {
            isUserLoading = false;
          })
        },
        setProfileUrls()
      });

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
    
  }

  Future getMoreUsersBySearchName(String searchedName, String uId) async {
    try {
      
      DatabaseService databaseService = new DatabaseService();
      await databaseService.loadMoreUsersBySearchedName(searchedName, uId).then((value) => {
        if (value.length == 0) {
          if (this.mounted) {
            setState(() {
              isLoadingMoreUsersPossible = false;
            })
          }
        }
        else {
          if (this.mounted) {
            for (int i = 0; i < value.length; i++) {
                setState(() {
                  users![users!.length] = value[i];
                })
            }
          },
          setProfileUrls()
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
      logger.message_warning("error occurred while getting more users by name\nerror: " + e.toString());
    }
  }

  setProfileUrls() async {
    try {

      while (profileURLs.length < users!.length) {
        profileURLs.add("");
        isprofLoadings.add(true);
        await getProfileURL(users![profileURLs.length - 1]["email"], users![profileURLs.length - 1]["profilePic"], profileURLs.length - 1);
      }

      if (this.mounted) {
        setState(() {
          isProfileLoading = false;
        });
      }

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
    
  }

  getProfileURL(String email, String profile, int index) async {

    Storage storage = Storage.instance;

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
    try {

      return isErrorOccurred? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                      isErrorOccurred = false;
                      isUserLoading = true;
                      isLoadingMoreUsersPossible = true;
                      isMoreLoading = false;
                      isProfileLoading = true;
                      isprofLoadings = [];
                      profileURLs = [];
                    }
                  );
                }
                Future.delayed(Duration(seconds: 0)).then((value) async {
                  await getUsersBySearchName(widget.searchedName);
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : (isUserLoading || isProfileLoading) ? Center(child:  CircularProgressIndicator(),) :
             NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && isLoadingMoreUsersPossible && !isMoreLoading) {
                  
                  setState(() {
                    isMoreLoading = true;
                    isProfileLoading = true;
                  });

                  getMoreUsersBySearchName(users![users!.length - 1]['name'], users![users!.length - 1]['uid']);

                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  try {
                    if (this.mounted) {
                      setState(() {
                        isUserLoading = true;
                        isProfileLoading = true;
                        isLoadingMoreUsersPossible = true;
                      });
                    }
                    await getUsersBySearchName(widget.searchedName);

                  } catch(e) {
                    if (this.mounted) {
                      setState(() {
                        isErrorOccurred = true;
                      });
                    }
                  }
                  
                },
                child: SingleChildScrollView(
                  child: Wrap(children: List.generate(users!.length, (index) {
                      try {
                        return 
                          isprofLoadings[index] ? Center(
                            child: CircularProgressIndicator(),
                          ) : 
                        InkWell(
                          onTap: () {
                            nextScreen(context, OthersProfilePages(uId: widget.uId, postOwnerUId: users![index]["uid"]));
                          },
                          child :
                            ListTile(
                              leading: Container(
                                width: MediaQuery.of(context).size.height * 0.05,
                                height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                  color: const Color(0xff7c94b6),
                                  image: profileURLs[index] == "" ? DecorationImage(
                                    image:  AssetImage("assets/blank.avif"),
                                    fit: BoxFit.cover,
                                  ) : 
                                  DecorationImage(
                                    image:  NetworkImage(profileURLs[index]),
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

                      } catch(e) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(onPressed: () {
                                if (this.mounted) {
                                  setState(() {
                                      isErrorOccurred = false;
                                      isUserLoading = true;
                                      isLoadingMoreUsersPossible = true;
                                      isMoreLoading = false;
                                      isProfileLoading = true;
                                      isprofLoadings = [];
                                      profileURLs = [];
                                    }
                                  );
                                }
                                Future.delayed(Duration(seconds: 0)).then((value) async {
                                  await getUsersBySearchName(widget.searchedName);
                                });
                              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
                              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
                            ],
                          )
                      );
                      }
                        
                      },
                    )),
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
                      isUserLoading = true;
                      isLoadingMoreUsersPossible = true;
                      isMoreLoading = false;
                      isProfileLoading = true;
                      isprofLoadings = [];
                      profileURLs = [];
                    }
                  );
                }
                Future.delayed(Duration(seconds: 0)).then((value) async {
                  await getUsersBySearchName(widget.searchedName);
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );
    }
    
  }
}