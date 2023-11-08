import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';

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

  List<bool> isprofLoadings = [];
  List<String> profileURLs = [];

  int? wholeAccountsLength = 0;
  bool isWholeAccountsLengthLoading = true;

  @override
  void initState() {

    Future.delayed(Duration(seconds: 0)).then((value) async {
      await getUsersBySearchName(widget.searchedName);
      getAccountsLength(widget.searchedName);
    });


    super.initState();
  }

  Future getUsersBySearchName(String searchedName) async {
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
  }

  Future getMoreUsersBySearchName(String searchedName, String uId) async {
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
  }

  setProfileUrls() async {

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

  void getAccountsLength(String searchedName) async {

    await FirebaseFirestore.instance.collection("user").
      where('name', isGreaterThanOrEqualTo: searchedName).
      get().then((value) => {
        wholeAccountsLength = value.docs.length,
        if (this.mounted) {
          setState(() {
            isWholeAccountsLengthLoading = false;
          }),
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (isWholeAccountsLengthLoading || isUserLoading || isProfileLoading) ? Center(child:  CircularProgressIndicator(),) :
             NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && isLoadingMoreUsersPossible && !isMoreLoading && wholeAccountsLength! > users!.length) {
                  
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
                  if (this.mounted) {
                    setState(() {
                      isWholeAccountsLengthLoading = true;
                      isUserLoading = true;
                      isProfileLoading = true;
                    });
                  }
                  await getUsersBySearchName(widget.searchedName);
                  getAccountsLength(widget.searchedName);
                  
                },
                child: SingleChildScrollView(
                  child: Wrap(children: List.generate(users!.length, (index) {
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
                    )),
                )
              ));
  }
}