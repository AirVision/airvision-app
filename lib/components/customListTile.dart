
import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  
  // final IconData icon;
  // final String icao24;


  // const CustomListTile(this.icon, this.icao24);

  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child: ListTile(
          // leading: Icon(widget.icon),
          title: Text("Airbus A220"),
        ),
      ),
    );
  }
}
