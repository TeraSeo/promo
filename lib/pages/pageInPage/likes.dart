import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LikesRanking extends StatefulWidget {

  final ScrollController scrollController;
  const LikesRanking({super.key, required this.scrollController});

  @override
  State<LikesRanking> createState() => _LikesRankingState();

}

class _LikesRankingState extends State<LikesRanking> {

  String? uId = "";

  List<bool> isprofLoadings = [];
  List<String> profileURLs = [];

  String profileURL = "";
  bool isProfileLoading = true;

  bool isErrorOccurred = false;

  bool isUIdLoading = true;

  var logger = Logger();

  int myRank = 0;
  String myUName = "";
  String myEmail = "";
  int myLikes = 0;
  bool? isMyEmailVisible;
  bool isMyLoading = true;
  var image;

  @override
  void initState() {
    getUId();
    super.initState();
  }

  void getUId() async{
    try {
      await HelperFunctions.getUserUIdFromSF().then((value) => {
        uId = value,
        if (this.mounted) {
          setState(() {
            isUIdLoading = false;
          })
        },
        getMyRank(uId!)
      });

    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.log(Level.error, "Error occurred while getting uId\nerror: " + e.toString());


    }
  }

  getMyProfile(String email, String profile) async {
    Storage storage = Storage.instance;

    try {
      await storage.loadProfileFile(email, profile).then((value) => {
        profileURL = value,
        if (this.mounted) {
          setState(() {
            isProfileLoading = false;
          })
        }
      });
    } catch(e) {
      profileURL = 'assets/blank.avif';
      if (this.mounted) {
        setState(() {
          isProfileLoading = false;
        });
      }
      logger.log(Level.error, "Error occurred while getting profile");
    }
  }

  getMyRank(String uId) async {

    final myUser = FirebaseFirestore.instance.collection("user").doc(uId);

    final user = FirebaseFirestore.instance.collection("user").orderBy("wholeLikes", descending: true);

    int i = 1;

    await myUser.get().then((value) => {

      myUName = value["name"],
      myLikes = value["wholeLikes"],
      myEmail = value["email"],
      isMyEmailVisible = value["isEmailVisible"],

      getMyProfile(value["email"], value["profilePic"]),

      user.get().then((value) => {
      value.docs.forEach((element) {
        if (element["name"] != myUName) {
          i++;
        }
        else {
          myRank = i;
          if (this.mounted){
            setState(() {
              isMyLoading = false;
            });
          }
        }
      }),
    })

    });
   
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
      logger.log(Level.error, "Error occurred while getting profile");
    }
  }

  @override
  Widget build(BuildContext context) {

    var future = FirebaseFirestore.instance.collection("user").
                      orderBy("wholeLikes", descending: true)
                      .limit(50).get();

    try {   
    return 
      isErrorOccurred? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () {
                setState(() {
                  isErrorOccurred = false;
                  isUIdLoading = true;
                  isprofLoadings = [];
                  profileURLs = [];
                  isMyLoading = true;
                  isProfileLoading = true;
                });
                getUId();
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) :
     (isUIdLoading || isMyLoading) ? Center(
        child: CircularProgressIndicator(),
      ) : 
      RefreshIndicator(
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10,),
              Text("Ranking", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23)),
              SizedBox(width: 20,),
              IconButton(onPressed: () async {
                try {
                  if (this.mounted) {
                  setState(() {
                    isUIdLoading = true;
                    isMyLoading = true;
                    isprofLoadings = [];
                    profileURLs = [];
                    isProfileLoading = true;

                  });
                  getUId();
                }} catch(e) {
                  logger.log(Level.error, "Error occurred while refreshing\nerror: " + e.toString());
                } 
              }, icon: Icon(Icons.replay))
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
          // SingleChildScrollView(child: 
            FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              try {
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

              return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      itemBuilder: (context, index) {

                        if (profileURLs.length < (snapshot.data! as dynamic).docs.length) {
                        profileURLs.add("");
                        isprofLoadings.add(true);
                        getProfileURL(snapshot.data!.docs[index]["email"], snapshot.data!.docs[index]["profilePic"], index);
                        }
                        return Card(
                          child: InkWell(
                            onTap: () {
                              nextScreen(context, OthersProfilePages(uId: uId!, postOwnerUId: snapshot.data!.docs[index]["uid"]));
                            },
                            child: ListTile(
                              leading: Container(
                                width: MediaQuery.of(context).size.height * 0.05,
                                height: MediaQuery.of(context).size.height * 0.05,
                                decoration: 
                                  BoxDecoration(
                                  color: const Color(0xff7c94b6),
                                  image: profileURLs[index] == "" ?  DecorationImage(
                                    image: AssetImage("assets/blank.avif"),
                                    fit: BoxFit.cover,
                                  ) : DecorationImage(
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
                                "#" + (index + 1).toString() + "  " + snapshot.data!.docs[index]["name"],
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: 
                              snapshot.data!.docs[index]["isEmailVisible"] == true ?
                              Text(
                                snapshot.data!.docs[index]["wholeLikes"] > 1 ? 
                                snapshot.data!.docs[index]["email"] + "  / " + snapshot.data!.docs[index]["wholeLikes"].toString() + " " + AppLocalizations.of(context)!.likes
                                : snapshot.data!.docs[index]["email"] + "  / " + snapshot.data!.docs[index]["wholeLikes"].toString() + " " + AppLocalizations.of(context)!.like
                              ) : Text(
                                snapshot.data!.docs[index]["wholeLikes"] > 1 ?
                                snapshot.data!.docs[index]["wholeLikes"].toString() + " " + AppLocalizations.of(context)!.likes :
                                snapshot.data!.docs[index]["wholeLikes"].toString() + " " + AppLocalizations.of(context)!.like
                              )
                            ),
                          )
                        );
                      }
                );
              }
              }
                
              } catch(e) {
                logger.log(Level.error, "Error occurred while getting ranks\nerror: " + e.toString());
                return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(onPressed: () {
                          if (this.mounted) {
                          setState(() {
                            isErrorOccurred = false;
                            isUIdLoading = true;
                            isprofLoadings = [];
                            profileURLs = [];
                            isMyLoading = true;
                            isProfileLoading = true;
                          });}
                          getUId();
                        }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
                        Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
                      ],
                    )
                );
              }
            }
          ),
          SizedBox(height: 30,),
          Card(
            child: InkWell(
              onTap: () {
                nextScreen(context, OthersProfilePages(uId: uId!, postOwnerUId: uId!));
              },
              child: ListTile(
                leading: Container( 
                  width: MediaQuery.of(context).size.height * 0.05,
                  height: MediaQuery.of(context).size.height * 0.05,
                  decoration: BoxDecoration(
                    color: const Color(0xff7c94b6),
                    image: profileURL.contains("assets/") ? DecorationImage(
                      image: AssetImage(profileURL),
                      fit: BoxFit.cover,
                    ) : 
                    DecorationImage(
                      image: NetworkImage(profileURL),
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
                  "#" + (myRank).toString() + "  " + myUName,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: 
                isMyEmailVisible! ? 
                Text(
                  myLikes > 1 ? 
                  myEmail + "  / " + myLikes.toString() + " " + AppLocalizations.of(context)!.likes :
                  myEmail + "  / " + myLikes.toString() + " " + AppLocalizations.of(context)!.like
                ) : Text(
                  myLikes > 1 ?
                  myLikes.toString() + " " + AppLocalizations.of(context)!.likes : 
                  myLikes.toString() + " " + AppLocalizations.of(context)!.like

                )
              ),
            )
          )
        ],
      ),
    ),
        ), 
    onRefresh: () async {
      try {
        if (this.mounted) {
        setState(() {
          isUIdLoading = true;
          isMyLoading = true;
          isprofLoadings = [];
          profileURLs = [];
          isProfileLoading = true;

        });
        getUId();
      }} catch(e) {
        logger.log(Level.error, "Error occurred while refreshing\nerror: " + e.toString());
      } 
    }
  );} 
  catch(e) {
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                setState(() {
                  isErrorOccurred = false;
                  isUIdLoading = true;
                  isprofLoadings = [];
                  profileURLs = [];
                  isMyLoading = true;
                  isProfileLoading = true;
                });}
                getUId();
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