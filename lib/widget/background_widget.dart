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

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: const Color(0xff7c94b6),
        image: DecorationImage(
          image: ResizeImage(image, width: MediaQuery.of(context).size.width.toInt(), height: (MediaQuery.of(context).size.height * 0.3).toInt()),
          fit: BoxFit.fitWidth,
        ),
        // borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height * 0.8)),
        // border: Border.all(
        //   color: Colors.white,
        //   width: MediaQuery.of(context).size.height * 0.005,
        // ),
      ),
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