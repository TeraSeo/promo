import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_app/services/storage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostWidget extends StatefulWidget {
  final String? email;
  final String? postID;
  final String? name;
  final List<dynamic>? image;
  final String? description;
  const PostWidget({super.key, required this.email, required this.postID, required this.name, required this.image, required this.description});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {

  List<String>? images;

  bool isLoading = true;

  final pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.8,
  );

  @override
  void initState() {
    super.initState();
    getImages();
  }

  void getImages() async {
    Storage storage = new Storage();
    await storage.loadPostImages(widget.email!, widget.postID!, widget.image!).then((value) => {
      images = value,
      setState(() {
        isLoading = false;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : Column(
    children: [
      SizedBox(height: 20,),
      Row(
        children: [
          SizedBox(
            width: 20,
          ),
          Container(
            width: MediaQuery.of(context).size.height * 0.04,
            height: MediaQuery.of(context).size.height * 0.04,
            decoration: BoxDecoration(
              color: const Color(0xff7c94b6),
              image: DecorationImage(
                image: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height * 0.8)),
              border: Border.all(
                color: Colors.white,
                width: MediaQuery.of(context).size.height * 0.005,
              ),
            ),
          ),
          SizedBox(width: 10,),
          Text(widget.name.toString()),
          SizedBox(width: 220,),
          Icon(Icons.more_vert_rounded)
        ],
      ),
      SizedBox(
        height: 25
      ),
      images!.length == 0 ? Column(
        children: [
          SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                Text(widget.description.toString())
              ],
            ),
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                
                Icon(Icons.favorite_outline),
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.comment_outlined),
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.send_outlined)

              ],
            ),
        ],
      ) :
      Column(
        children: [
          Container(
              height: 260,
              child: PageView.builder(
                controller: pageController,
                itemBuilder: (_, index) {
                  return AnimatedBuilder(
                    animation: pageController, 
                    builder: (ctx, child) {
                      return
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: DecorationImage(
                              image: ResizeImage(NetworkImage(images![index]), width: MediaQuery.of(context).size.width.toInt(), height: (MediaQuery.of(context).size.height * 0.35).toInt()),
                              fit: BoxFit.fill,
                            ),
                          )
                      );
                    },  
                    child: GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: 4,left: 4, top: 24, bottom: 6
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          color: Colors.grey
                        ),
                      ),
                    ),
                  );
                },
                itemCount: images!.length,
              ) 
            ),
            SizedBox(height: 20,),
            // SmoothPageIndicator(
            //   controller: pageController, count: images!.length,
            //   effect: SwapEffect(
            //     activeDotColor: Colors.black,
            //     dotHeight: 7.5,
            //     dotWidth: 7.5,
            //     spacing: 4,
            //   ),
            // ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                
                Icon(Icons.favorite_outline),
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.comment_outlined),
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.send_outlined)

              ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                Text(widget.description.toString())
              ],
            ),
            SizedBox(height: 30,),
        ],
      )

    ],
  );
  }
}