import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_switch/flutter_switch.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
 double tempCelsius = 0.0; // Initialize with a default value
  double tempFahrenheit = 0.0;// Temperature in Fahrenheit
  var description='.';
  var currently='.';
  int humidity=0;
  double windSpeed=0;
  var cityname='.';
  double temp=0;
  double feels_like=0;
  double feels_likef=0;
  double temp_max=0;
  double temp_maxf=0;
  double temp_min=0;
  double temp_minf=0;
  int pressure=0;
  int visibility=0;
  var country;
    bool isFahrenheit = false;
    bool isDarkMode = false;
bool userOverride = false;
 // Define a mapping between weather conditions and image asset paths
  Map<String, String> weatherConditionToIcon = {
    'Clear': 'images/clear.png',
    'Clouds': 'images/clouds.png',
    'Rain': 'images/rain.png',
    
    // Add more weather conditions and image paths
  };
  Future getWeather() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Handle the case when the user denies the permission
      return;
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Fetch weather data based on the current location
    var url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=958a8cc7b5f973c4cc23ef8b1d1a623c',
    );
    http.Response response = await http.get(url);
    var results = jsonDecode(response.body);
    print("Data from API: $results");

    double temperatureKelvin = results['main']['temp'];
    this.tempCelsius = kelvinToCelsius(temperatureKelvin);
    this.tempFahrenheit = kelvinToFahrenheit(temperatureKelvin);
  
  double feelsKelvin = results['main']['feels_like'];
    this.feels_like = kelvinToCelsius(feelsKelvin);
    this.feels_likef = kelvinToFahrenheit(feelsKelvin);
  
   double HKelvin = results['main']['temp_max'];
    this.temp_max = kelvinToCelsius(HKelvin);
    this.temp_maxf= kelvinToFahrenheit(HKelvin);

 double LKelvin = results['main']['temp_min'];
    this.temp_min = kelvinToCelsius(LKelvin);
    this.temp_minf= kelvinToFahrenheit(LKelvin);

double speed=results['wind']['speed'];
this.windSpeed=mstokm(speed);

int visibility=results['visibility'];
this.visibility=mtokm(visibility);

    setState(() {
      this.description = results['weather'][0]['description'];
      this.currently = results['weather'][0]['main'];
      this.humidity = results['main']['humidity'];
    //  this.windSpeed = results['wind']['speed'];
      this.cityname = results['name'];
     //this.visibility=results['visibility'];
     this.pressure = results['main']['pressure'];
     this.country =results['sys']['country'];
    });
  }

  double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  double kelvinToFahrenheit(double kelvin) {
    return (kelvin - 273.15) * 9/5 + 32;
  }
   double mstokm(double ms){
    return ms * 3.6;
   }
   int mtokm (int m){
    return m ~/1000;
   }
  @override
  void initState() {
    super.initState();
    this.getWeather();
   //  isDarkMode = isNightTime();
  }

void toggleDarkMode() {
  setState(() {
    isDarkMode = !isDarkMode;
    userOverride = true;
  });
}
void toggleSwitch(bool value) {
  setState(() {
    isFahrenheit = value;
  });
}


  @override
  Widget build(BuildContext context) { 
      
       return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color:  isDarkMode
          ?  Color.fromARGB(255, 41, 40, 40)
          : const Color.fromARGB(255, 38, 113, 124), // Background color of the popup menu
          textStyle: TextStyle(
            color: Color.fromARGB(255, 233, 241, 242), // Text color in the popup menu
            fontWeight: FontWeight.bold, // Bold text
            fontSize: 16, // Text size
          ),
        ),
      ),
       child:  ScreenTypeLayout.builder(
      mobile: (BuildContext context) => MobileNavBar(),
      desktop: (BuildContext context) => DeskTopNavBar(),
       ));
  }


  Widget MobileNavBar() {
    return   Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : const Color.fromARGB(255, 38, 113, 124),
   body:  Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

       Container(
        height: 40,
        width: 40,
        margin: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(360)),color: Color.fromARGB(0, 61, 127, 137) ),
       child:    IconButton(
  icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
  onPressed: toggleDarkMode,)
       ),
        PopupMenuButton<String>(       
                   onSelected: (String result) {
                //  ScaffoldMessenger.of(context).showSnackBar(
                  //  SnackBar(content: Text('You selected: $result')),
                  //);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                   PopupMenuItem<String>(
                    value: 'settings',
                  
                  child:   Column(
                      children: [
                         Row(
                      children: [
                        Text('Farehnheit',style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255,233,241,242)),),
                 Spacer(),
                     Switch(
                value: isFahrenheit,
                onChanged: toggleSwitch,
                activeTrackColor: Colors.lightGreenAccent,      
                activeColor: Colors.green,
              ),

                      ],
                    ),
                   // Row(
                      // children: [
                //  IconButton(
  // icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
  // onPressed: toggleDarkMode,
// )
                 //        Text('Farehnheit',style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255,233,241,242)),),
                      // ],
                    // )
                      ],
                    )
                  
                   )
                ],

         child: Container(
        height: 40,
        width: 40,
        margin: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(360)),color: isDarkMode
          ? Color.fromARGB(255, 41, 40, 40)
          : const Color.fromARGB(255,61,127,137) ),
        child:  Icon(Icons.settings,color: Color.fromARGB(255,233,241,242)),
       ))
        ,]),
        Column(
      children: [
        SizedBox(height: 70,),
        Text( '$cityname',style: TextStyle(fontSize: 20,color: Color.fromARGB(255,233,241,242),fontWeight: FontWeight.w600),),
        SizedBox(height: 10,),
        
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text('H:${isFahrenheit ? temp_maxf.round() : temp_max.round()}\u00B0',style: TextStyle(color: Color.fromARGB(255,233,241,242),),),
        SizedBox(width: 5,),
        Text('L:${isFahrenheit ? temp_minf.round() : temp_min.round()}\u00B0',style: TextStyle(color: Color.fromARGB(255,233,241,242),),),
      ]),
       Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 80.0), // Adjust top padding as needed
             child: CarouselSlider(
                    options: CarouselOptions(
                      height: 400.0,
                      autoPlay: false,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      viewportFraction: 0.8,
                    ),
            items:[
              Column(children: [
              Stack(children: [ Text(
              '${isFahrenheit ? tempFahrenheit.round() :tempCelsius.round()}\u00B0', // Use Unicode for the degree symbol
              style: TextStyle(
                fontSize: 150,
                color: Color.fromARGB(255, 233, 241, 242),
              ),
            ), Positioned(
              top: 20,
              child:
            Opacity(
            opacity: 0.5,
           
              child: Image.asset(  weatherConditionToIcon[currently] ?? 'assets/images/default.png',height:200, fit:BoxFit.cover,)
              )
              ),
             
           
       ]
              
        ),Text('${description}',style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255, 233, 241, 242),fontSize: 15),),]),
    
       Container(
        child: Column(
          children: [
            Column(
              children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                 Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.all(Radius.circular(15))),
                  child:  
                  Column(children: [
                    SizedBox(height: 10,),
                   Text('Feels Like',style:TextStyle(fontWeight: FontWeight.bold)) ,
                   SizedBox(height: 10,),
                   Text('  ${isFahrenheit ? feels_likef.round() : feels_like.round()}${isFahrenheit ? '°F' : '°C'}',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25),)
                ])),
                   Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(children: [
                    SizedBox(height: 10,),
                    Text('Wind Speed',style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                         Text('${windSpeed.round()}km/h',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                  ],)
                )
               ],),
                SizedBox(height: 10,),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(children: [
                    SizedBox(height: 10,),
                     Text('Humidity',style: TextStyle(fontWeight: FontWeight.bold),),
                     SizedBox(height: 10,),
                  Text(' ${humidity}%',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25))
                  ],)
                ),
                   Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
                      Text('Pressure:',style: TextStyle(fontWeight: FontWeight.bold)),
                     SizedBox(height: 10,),
                      Text(' ${pressure}hpa',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25))
                    ],
                  )
                )
                ],
               ),
               SizedBox(height: 10,),
                Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                 Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.all(Radius.circular(15))),
                  child:  Column(
                    children: [
                      SizedBox(height: 10,),
                          Text('Visibility: ',style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10,),
                          Text('${visibility}km',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25))
                    ],
                  )
                ),
                   Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.all(Radius.circular(15))),
                  child:     Column(children: [
                    SizedBox(height: 10,),                
                       Text('Country: ',style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 10,),
                       Text('${country}',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25))
                  ],)
                )
               ],),
              ],
            ),
             
              
           
                          
               
            
          ],
        ),
       )
       ],
        ),


)
       ),
       
      ],
    ),
          
     
      ],
    ),

      
    );
  }

Widget DeskTopNavBar() {
  return Container(
   
  
  
  );
}
}












//dynamic weather

