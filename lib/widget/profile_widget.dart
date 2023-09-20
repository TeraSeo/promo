import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
  }) : super(key: key);

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
    final image = NetworkImage(imagePath);

    return Container(
      width: MediaQuery.of(context).size.height * 0.047 * 3.1,
      height: MediaQuery.of(context).size.height * 0.047 * 3.1,
      decoration: BoxDecoration(
        color: const Color(0xff7c94b6),
        image: DecorationImage(
          image: image,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height * 0.8)),
        border: Border.all(
          color: Colors.white,
          width: MediaQuery.of(context).size.height * 0.005,
        ),
      ),
    );
  }
}