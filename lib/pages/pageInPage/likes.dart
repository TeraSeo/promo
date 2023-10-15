import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LikesRanking extends StatefulWidget {
  const LikesRanking({super.key});

  @override
  State<LikesRanking> createState() => _LikesRankingState();

}

class _LikesRankingState extends State<LikesRanking> {

  @override
  Widget build(BuildContext context) {
    return Container(
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

        FutureBuilder(
          future: FirebaseFirestore.instance.collection("user").
                      orderBy("commentLikes", descending: true)
                      .limit(50).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            // return Text((snapshot.data! as dynamic).docs.length.toString());
            return ListView.builder(
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 10,),
                              Text("#" + (index + 1).toString(), textAlign: TextAlign.center,style: TextStyle(fontSize: 15, height: 5))
                            ],
                          )
                        ]
                      )
                    );
                  }
            );
          },
        ),
        
        // Container(
        //   child: ListView.builder(
        //   physics: const NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   padding: const EdgeInsets.all(6),
        //   itemCount: 50,
        //   itemBuilder: (BuildContext context, int index) {
        //     return Card(
        //       child: Column(
        //         children: [
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.start,
        //             children: [
        //               SizedBox(width: 10,),
        //               Text("#" + (index + 1).toString(), textAlign: TextAlign.center,style: TextStyle(fontSize: 15, height: 5))
        //             ],
        //           )
        //         ]
        //       )
        //     );
        //   },
        // ),
        // ),

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

  );
    
    
  }
}