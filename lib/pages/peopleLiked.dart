import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';

class PeopleLiked extends StatefulWidget {

  final List<dynamic> likedPeople;
  final String uId;
  const PeopleLiked({super.key, required this.likedPeople, required this.uId});

  @override
  State<PeopleLiked> createState() => _PeopleLikedState();
}

class _PeopleLikedState extends State<PeopleLiked> {

  Map<dynamic, dynamic>? likedPeople;
  bool isLikedPeopleLoading = true;
  bool isMoreLoading = false;
  bool isLoadingMorePostsPossible = true;

  DatabaseService databaseService = DatabaseService.instance;

  List<String>? profileURLs = [];

  int i = 30;

  @override
  void initState() {
    super.initState();
    getLikedPeople().then((value) {
      likedPeople = value;
      for (int i = 0; i < likedPeople!.length; i++) {
        profileURLs!.add(likedPeople![i]["profilePic"]);
      }
      if (this.mounted) {
        setState(() {
          isLikedPeopleLoading = false;
        });
      }
    });
  }

  Future<Map<dynamic, dynamic>> getLikedPeople() async {
    if (widget.likedPeople.length - i >= 0) {
      i = i + 30;
      return databaseService.getLikedUser(widget.likedPeople.getRange(0, 30).toList());
    }
    else {
      setState(() {
        isLoadingMorePostsPossible = false;
      });
      return databaseService.getLikedUser(widget.likedPeople.getRange(0, widget.likedPeople.length).toList());
    }
  }

  // Future getProfileURLs(Map<dynamic, dynamic> likedPeople) async {

  //   Storage storage = Storage.instance;

  //   for (int i = 0; i < likedPeople.length; i++) {
  //     storage.loadProfileFile(likedPeople[i]["email"], likedPeople[i]["profilePic"]).then((value) {
  //       if (this.mounted) {
  //         setState(() {
  //           profileURLs![i] = value;
  //         });
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return (isLikedPeopleLoading) ? Center(child: CircularProgressIndicator(color: Colors.white,),) :
    Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.liked, style: TextStyle(color: Colors.black)),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          try {
            if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && scrollNotification.metrics.atEdge && !isMoreLoading && isLoadingMorePostsPossible) {
              isMoreLoading = true;
              if (widget.likedPeople.length - i >= 30) {
                databaseService.getLikedUser(widget.likedPeople.getRange(i - 30, i).toList()).then((value) => {
                  if (this.mounted) {
                    for (int i = 0; i < value.length; i++) {
                      profileURLs!.add(value[i]["profilePic"]),
                      setState(() {
                        likedPeople![likedPeople!.length] = value[i];
                      })
                    }
                  },
                });
                i = i + 30;
              }
              else {
                setState(() {
                  isLoadingMorePostsPossible = false;
                });
                databaseService.getLikedUser(widget.likedPeople.getRange(i - 10, widget.likedPeople.length).toList()).then((value) => {
                if (this.mounted) {
                  for (int i = 0; i < value.length; i++) {
                    profileURLs!.add(value[i]["profilePic"]),
                    setState(() {
                      likedPeople![likedPeople!.length] = value[i];
                    })
                  },
                },
              });
              }
              setState(() {
                isMoreLoading = false;
              });
            }
            return true;
          } catch(e) {
            if (this.mounted) {
              setState(() {
              });
            }
          }
          return true;
        },
        child: SingleChildScrollView(
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: likedPeople!.length,
            itemBuilder: (context, index) {
            return Card(
                child: InkWell(
                  onTap: () {
                    nextScreen(context, OthersProfilePages(uId: widget.uId, postOwnerUId: likedPeople![index]["uid"]));
                  },
                  child: ListTile(
                    leading: Container(
                      width: MediaQuery.of(context).size.height * 0.05,
                      height: MediaQuery.of(context).size.height * 0.05,
                      decoration: 
                        BoxDecoration(
                        color: const Color(0xff7c94b6),
                        image: profileURLs![index] == "" ?  DecorationImage(
                          image: NetworkImage("assets/blank.avif"),
                          fit: BoxFit.cover,
                        ) : DecorationImage(
                          image: NetworkImage(profileURLs![index]),
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
                      "#" + (index + 1).toString() + "  " + likedPeople![index]["name"],
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              ); 
          }))
        ),
      );
  }
}