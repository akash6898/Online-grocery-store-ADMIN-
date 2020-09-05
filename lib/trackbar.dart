import 'package:flutter/material.dart';

class TrackBar extends StatelessWidget {
  final String _postion;
  TrackBar(this._postion);
  int a = 0;
  @override
  Widget build(BuildContext context) {
    switch (_postion) {
      case 'Placed':
        a = 0;
        break;
      case 'Packed':
        a = 1;
        break;
      case 'On The Way':
        a = 2;
        break;
      case 'Delivered':
        a = 3;
    }
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.black,
              radius: 10.1,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: a >= 0 ? Colors.green : Colors.white,
              ),
            ),
            Expanded(
                child: Divider(
              thickness: 0.5,
              color: a >= 1 ? Colors.green : Colors.black,
            )),
            CircleAvatar(
              backgroundColor: Colors.black,
              radius: 10.1,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: a >= 1 ? Colors.green : Colors.white,
              ),
            ),
            Expanded(
                child: Divider(
              thickness: 0.5,
              color: a >= 2 ? Colors.green : Colors.black,
            )),
            CircleAvatar(
              backgroundColor: Colors.black,
              radius: 10.1,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: a >= 2 ? Colors.green : Colors.white,
              ),
            ),
            Expanded(
                child: Divider(
              thickness: 0.5,
              color: a >= 2 ? Colors.green : Colors.black,
            )),
            CircleAvatar(
              backgroundColor: Colors.black,
              radius: 10.1,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: a == 3 ? Colors.green : Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Placed"),
            Text("Packed"),
            Text("On the way"),
            Text("Delivered"),
          ],
        )
      ],
    );
  }
}
