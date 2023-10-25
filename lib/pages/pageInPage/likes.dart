import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/pageInPage/profilePage/othersProfilePage.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/widgets/widgets.dart';

class LikesRanking extends StatefulWidget {
  const LikesRanking({super.key});

  @override
  State<LikesRanking> createState() => _LikesRankingState();

}

class _LikesRankingState extends State<LikesRanking> {

  String? uId = "";

  List<bool> isprofLoadings = [];
  List<String> profileURLs = [];

  final future = FirebaseFirestore.instance.collection("user").
                      orderBy("commentLikes", descending: true)
                      .limit(50).get();

  bool isUIdLoading = true;

  @override
  void initState() {
    getUId();
    super.initState();
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
    
    return isUIdLoading? Center(
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
              Text("Ranking", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23))
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
          // SingleChildScrollView(child: 
            FutureBuilder(
            future: future,
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

              //     for (int i = 0; i < (snapshot.data! as dynamic).docs.length; i++) {
              //       profileURLs.add("");
              //       isprofLoadings.add(true);
              //       getProfileURL(snapshot.data!.docs[i]["email"], snapshot.data!.docs[i]["profilePic"], i);
              //       // if (i == (snapshot.data! as dynamic).docs.length - 1){
              //       //   setState(() {
              //       //     isProfileLoading = false;
              //       //   });
              //       // }
              //     }



              //     return Column(
              //       children: List.generate((snapshot.data! as dynamic).docs.length, 
              //         (index) {
              //           return isprofLoadings[index]?  Center(
              //       child: CircularProgressIndicator(),
              //     ) : Card(
              //           child: InkWell(
              //             onTap: () {
              //               nextScreen(context, OthersProfilePages(uId: uId!, postOwnerUId: snapshot.data!.docs[index]["uid"]));
              //             },
              //             child: ListTile(
              //               leading: Container(
              //                 width: MediaQuery.of(context).size.height * 0.05,
              //                 height: MediaQuery.of(context).size.height * 0.05,
              //                 decoration: BoxDecoration(
              //                   color: const Color(0xff7c94b6),
              //                   image: DecorationImage(
              //                     image: NetworkImage(profileURLs[index]),
              //                     fit: BoxFit.cover,
              //                   ),
              //                   borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height * 0.8)),
              //                   border: Border.all(
              //                     color: Colors.white,
              //                     width: MediaQuery.of(context).size.height * 0.005,
              //                   ),
              //                 ),
              //               ),
              //               title: Text(
              //                 "#" + (index + 1).toString() + "  " + snapshot.data!.docs[index]["name"],
              //                 style: TextStyle(fontWeight: FontWeight.w600),
              //               ),
              //               subtitle: Text(
              //                 snapshot.data!.docs[index]["email"]
              //               ),
              //             ),
              //           )
              //         );
              //         }),
              //     );

              //   }
                
              // }

              return ListView.builder(
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
                              subtitle: Text(
                                snapshot.data!.docs[index]["email"]
                              ),
                            ),
                          )
                        );
                      }
                );
              }
              }
            }
            // )
          )
          ,
        
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
      await Future.delayed(Duration(seconds: 1)).then((value) => {
        setState(() {
        })
      });
    },
  );
  }
}