import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/widget/comment_widget.dart';
import 'package:like_app/widgets/widgets.dart';
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
    viewportFraction: 1,
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
    bool isTablet;
    double logoSize; 
    double logoSpaceBetween;
    double descriptionSize;

    if(Device.get().isTablet) {
      isTablet = true;
      logoSpaceBetween = MediaQuery.of(context).size.width * 0.7;
      descriptionSize = MediaQuery.of(context).size.height * 0.02;
      logoSize = MediaQuery.of(context).size.width * 0.053;
    }
    else {
      isTablet = false;
      logoSpaceBetween = MediaQuery.of(context).size.width * 0.62;
      descriptionSize = MediaQuery.of(context).size.height * 0.02;
      logoSize = MediaQuery.of(context).size.width * 0.06;
    }

    return isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : Column(
    children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
      Container(
        // padding: EdgeInsets.all(5),
        // decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            isTablet ? 
            (Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.026,
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
                      width: MediaQuery.of(context).size.height * 0.05,
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.height * 0.013,),
                Text(widget.name.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.026, fontStyle: FontStyle.normal, fontWeight: FontWeight.w400)),
                SizedBox(width: MediaQuery.of(context).size.width * 0.73),
                Icon(Icons.more_vert_rounded, size: MediaQuery.of(context).size.width * 0.045)
              ],
            )) : 
            (Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.016,
                ),
                Container(
                  width: MediaQuery.of(context).size.height * 0.045,
                  height: MediaQuery.of(context).size.height * 0.045,
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
                SizedBox(width: MediaQuery.of(context).size.height * 0.011,),
                Text(widget.name.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035, fontStyle: FontStyle.normal, fontWeight: FontWeight.w500)),
                SizedBox(width: MediaQuery.of(context).size.width * 0.655),
                Icon(Icons.more_vert_rounded, size: logoSize)
              ],
            )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.013
            ),
            images!.length == 0 ? Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.012,),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.height * 0.037,
                      ),
                      Text(widget.description.toString(), style: TextStyle(fontSize: descriptionSize),)
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.04,
                      ),
                      Icon(Icons.favorite_outline, size: logoSize),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.013,
                      ),
                      IconButton(onPressed: () {
                        nextScreen(context, CommentWidget(postId: widget.postID));
                      }, icon: Icon(Icons.comment_outlined, size: logoSize),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.013,
                      ),
                      Icon(Icons.send_outlined, size: logoSize),
                      SizedBox(
                        width: logoSpaceBetween
                      ),
                      Icon(Icons.bookmark_outline, size: logoSize),

                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
              ],
            ) :
            Column(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height * 0.38,
                    child: PageView.builder(
                      controller: pageController,
                      itemBuilder: (_, index) {
                        return AnimatedBuilder(
                          animation: pageController,
                          builder: (ctx, child) {
                            return SizedBox(
                            child: Image(
                              image: NetworkImage(images![index]),fit: BoxFit.fill
                            ));
                          }
                        );
                      },
                      itemCount: images!.length
                    )
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.012,),
                  images!.length == 1 ? Container(height: 0,) :  
                  Column(children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                    SmoothPageIndicator(
                      controller: pageController, 
                      count: images!.length,
                      effect: SwapEffect(
                        activeDotColor: Colors.black,
                        dotHeight: MediaQuery.of(context).size.height * 0.01,
                        dotWidth: MediaQuery.of(context).size.height * 0.01,
                        spacing:  MediaQuery.of(context).size.height * 0.005,
                      ),
                    ),
                  ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.04,
                      ),
                      Icon(Icons.favorite_outline, size: logoSize),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.013,
                      ),
                      IconButton(onPressed: () {
                        nextScreen(context, CommentWidget(postId: widget.postID,));
                      }, icon: Icon(Icons.comment_outlined, size: logoSize),),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.013,
                      ),
                      Icon(Icons.send_outlined, size: logoSize),
                      SizedBox(
                        width: logoSpaceBetween
                      ),
                      Icon(Icons.bookmark_outline, size: logoSize),

                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.019,),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.06,
                      ),
                      Text(widget.description.toString(), style: TextStyle(fontSize: descriptionSize),)
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07,),
              ],
            )
          ],
        ),
      )
    ]
  );
  }
}