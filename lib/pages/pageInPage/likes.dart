import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:logger/logger.dart';

class LikesRanking extends StatefulWidget {
  const LikesRanking({super.key});

  @override
  State<LikesRanking> createState() => _LikesRankingState();

}

class _LikesRankingState extends State<LikesRanking> {

  String? uId = "";

  List<bool> isprofLoadings = [];
  List<String> profileURLs = [];

  bool isErrorOccurred = false;

  // final future = FirebaseFirestore.instance.collection("user").
  //                     orderBy("commentLikes", descending: true)
  //                     .limit(50).get();

  bool isUIdLoading = true;

  var logger = Logger();

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
        }
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
            children: [
              IconButton(onPressed: () {
                setState(() {
                  isErrorOccurred = false;
                  isUIdLoading = false;
                  isprofLoadings = [];
                  profileURLs = [];
                });
                getUId();
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) :
     isUIdLoading? Center(
        child: CircularProgressIndicator(),
      ) : 
      RefreshIndicator(
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
              
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      itemBuilder: (context, index) {

                        if (profileURLs.length < (snapshot.data! as dynamic).docs.length) {
                        profileURLs.add("");
                        isprofLoadings.add(true);
                        getProfileURL(snapshot.data!.docs[index]["email"], snapshot.data!.docs[index]["profilePic"], index);
                        print(snapshot.data!.docs[index]["wholeLikes"]);
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
                                "#" + (index + 1).toString() + "  " + snapshot.data!.docs[index]["name"],
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: 
                              Text(
                                snapshot.data!.docs[index]["email"] + "  / " + snapshot.data!.docs[index]["wholeLikes"].toString() + " likes"
                              ),
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
                      children: [
                        IconButton(onPressed: () {
                          if (this.mounted) {
                          setState(() {
                            isErrorOccurred = false;
                            isUIdLoading = false;
                            isprofLoadings = [];
                            profileURLs = [];
                          });}
                          getUId();
                        }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
                        Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
                      ],
                    )
                );
              }
            }
          ),
          SizedBox(height: 30,),
          Card(
            shadowColor: Colors.grey,
            elevation: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10,),
                Text("#", textAlign: TextAlign.center,style: TextStyle(fontSize: 15, height: 5))
              ],
            )
          )
        ],
      ),
    ), 
    onRefresh: () async {
      try {
        if (this.mounted) {
        setState(() {
          isUIdLoading = true;
          isprofLoadings = [];
          profileURLs = [];

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
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                setState(() {
                  isErrorOccurred = false;
                  isUIdLoading = false;
                  isprofLoadings = [];
                  profileURLs = [];
                });}
                getUId();
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
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