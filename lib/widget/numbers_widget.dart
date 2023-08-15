import 'package:flutter/material.dart';
import 'package:like_app/datas/users.dart';

class NumbersWidget extends StatelessWidget {
  LikeUser likeUser;

  NumbersWidget(this.likeUser);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, likeUser.ranking.toString(), 'Ranking'),
          buildDivider(context),
          buildButton(context, likeUser.likes.toString(), 'Likes'),
          buildDivider(context),
          buildButton(context, likeUser.posts!.length.toString(), 'Posts'),
        ],
      );
  Widget buildDivider(BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.024,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.028),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.004),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}