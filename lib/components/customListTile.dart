import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  final IconData icon;
  final String text;
  final String discription;

  const CustomListTile(this.icon, this.text, this.discription);

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
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        widget.icon,
                        color: Color(0xff505050),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.text,
                          style: TextStyle(
                              color: Color(0xff505050),  fontSize: widget.text.length < 30? 16.0 : 13.0),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  child: Text(
                    widget.discription,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  top: 7,
                  right: 10,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
