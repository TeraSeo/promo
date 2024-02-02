import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {

  final String background_url;

  const BackgroundWidget({super.key, required this.background_url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          buildImage(context),
        ],
      ),
    );
  }

  Widget buildImage(BuildContext context) {

    var image;
   
    if (background_url == null || background_url == "") {
      image = AssetImage("assets/backgroundDef.jpeg");
    }
    else {
      image = NetworkImage(background_url);
    }
    
    return Image(
      image: image,
      fit: BoxFit.contain,
    );
  }

}