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
          // Positioned(
          //   bottom: 0,
          //   right: sizedBox / 7,
          //   child: buildEditIcon(color, context),
          // ),
        ],
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    final image = NetworkImage(background_url);

    return Image(
      image: NetworkImage(background_url),
      fit: BoxFit.contain, // use this
    );
  }

  // @override
  // Widget build(BuildContext context) {

  //   final background = NetworkImage(background_url);

  //   return Image(image: ResizeImage(
  //     background, width: MediaQuery.of(context).size.width.toInt(), 
  //     height: (MediaQuery.of(context).size.height * 0.3).toInt()));
  // }
}