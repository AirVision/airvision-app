import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  final IconData icon;
  final String text;

  const CustomListTile(this.icon, this.text);

  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xffE9E9E9),
                  blurRadius: 5.0, // has the effect of softening the shadow
                  spreadRadius: 0.0, // has the effect of extending the shadow
                )
              ],
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ListTile(
              leading: Icon(
                widget.icon,
                color: Color(0xff505050),
              ),
              title: Text(
                widget.text,
                style: TextStyle(
                  color: Color(0xff505050),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
