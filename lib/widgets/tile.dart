import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/**
 *  @author Pradeep CH
 * 
 */

class TBTile extends StatelessWidget {
  final IconData icon;
  final double tileSize;
  final Color color;
  final Color iconColor;
  final Function ontap;
  final double iconSize;
  final String text;

  TBTile(this.text, this.tileSize, this.icon, this.color, this.iconColor,
      {this.ontap, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FlatButton(
        child: Container(
          child: Icon(
            icon,
            size: iconSize == null ? tileSize * 0.80 : iconSize,
            color: iconColor,
          ),
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: color),
        ),
        onPressed: ontap,
      ),
      Center(
          child: Text(
        text,
      )),
    ]);
  }
}
