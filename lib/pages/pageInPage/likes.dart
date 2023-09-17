import 'package:flutter/material.dart';

class Likes extends StatefulWidget {
  const Likes({super.key});

  @override
  State<Likes> createState() => _LikesState();
}

class _LikesState extends State<Likes> {
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
        
        Container(
          child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(6),
          itemCount: 100,
          itemBuilder: (BuildContext context, int index) {
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
          },
        ),
        ),
      ],
    ),

  );
    
    
  }
}