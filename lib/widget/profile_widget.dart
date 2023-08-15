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

  // Widget buildEditIcon(Color color, BuildContext context) => buildCircle(
  //       color: Colors.white,
  //       all: MediaQuery.of(context).size.height * 0.002,
  //       child: buildCircle(
  //         color: color,
  //         all: MediaQuery.of(context).size.height * 0.008,
  //         child: Icon(
  //           Icons.edit,
  //           color: Colors.white,
  //           size: MediaQuery.of(context).size.height * 0.022,
  //         ),
  //       ),
  //     );

  // Widget buildCircle({
  //   required Widget child,
  //   required double all,
  //   required Color color,
  // }) =>
  //     ClipOval(
  //       child: Container(
  //         padding: EdgeInsets.all(all),
  //         color: color,
  //         child: child,
  //       ),
  //     );
}