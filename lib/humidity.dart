import 'package:flutter/material.dart';

class HumidityWidget extends StatefulWidget {
  final double humidity;

  const HumidityWidget({required this.humidity});

  @override
  _HumidityWidgetState createState() => _HumidityWidgetState();
}

class _HumidityWidgetState extends State<HumidityWidget> {
  @override
  Widget build(BuildContext context) {
    double containerHeight = 100; // Adjust height as needed
    double liquidHeight = (widget.humidity / 100) * containerHeight;

    return Container(
      width: 130, // Adjust width as needed
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.white, // Background color for the gauge
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Liquid level
          AnimatedContainer(
            duration: Duration(seconds: 1),
            height: liquidHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.purple.shade300, // Liquid color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
          // Humidity percentage text
          Positioned.fill(
            child: Center(
              child:Column(
                children: [
                  SizedBox(height: 5,),
                  Text('Humidity',style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),
               Text(
                '${widget.humidity.toInt()}%',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),])
            ),
          ),
        ],
      ),
    );
  }
}
