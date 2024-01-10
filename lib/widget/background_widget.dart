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

    return Image(
      image: NetworkImage(background_url),
      fit: BoxFit.contain,
    );
  }

}