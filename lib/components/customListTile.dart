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
              borderRadius: BorderRadius.circular(8),
              color: Color(0xffF6F6F6),
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
