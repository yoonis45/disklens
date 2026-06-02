import 'package:flutter/material.dart';

class StorageOverviewSize extends StatefulWidget {
  final type;
  final size;
  final Color colour;
  const StorageOverviewSize({
    super.key,
    required this.type,
    required this.size,
    required this.colour,
  });

  @override
  State<StorageOverviewSize> createState() => _StorageOverviewSizeState();
}

class _StorageOverviewSizeState extends State<StorageOverviewSize> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 10,
          children: [
            VerticalDivider(
              color: widget.colour,
              thickness: 5,
              width: 20,
              radius: BorderRadius.circular(10),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.type, style: TextStyle(color: Colors.grey)),
                Text(
                  "${widget.size.toString()}GB",
                  style: TextStyle(fontSize: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
