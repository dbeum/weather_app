import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; 
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_builder/responsive_builder.dart';

import 'package:weather_web/humidity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:vitality/vitality.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _showOnboarding = false;
  int _currentStep = 0;

 double tempCelsius = 0.0; // Initialize with a default value
  double tempFahrenheit = 0.0;// Temperature in Fahrenheit
  var description='.';
  var currently='.';
  double humidity=0;
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

  final TextEditingController _searchController = TextEditingController();
 // Define a mapping between weather conditions and image asset paths
  Map<String, String> weatherConditionToIcon = {
    'Clear': 'assets/images/cloud.gif',
    'Rain': 'assets/images/rain.gif',
    'Hot': 'assets/images/sun.gif',
    'Snow': 'assets/images/snow.gif' ,
    'Mist': 'assets/images/fog.gif',
    'Fog': 'assets/images/fog.gif',
    'Smoke': 'assets/images/smoke.gif',
    'Haze': 'assets/images/fog.gif',
    'Thunderstorm': 'assets/images/storm.gif',
    'Hail': 'assets/images/hail.gif',
    'Cold': 'assets/images/cold.gif',
    'Tornado': 'assets/images/tornado.gif',
    'Freezing': 'assets/images/freezing.gif'
    
    // Add more weather conditions and image paths
  };
  
  Future getWeather({String city = ''}) async {
    var url;
    if (city.isEmpty) {
      // Get current location weather
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=958a8cc7b5f973c4cc23ef8b1d1a623c',
      );
    } else {
      // Get weather by city name
      url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=958a8cc7b5f973c4cc23ef8b1d1a623c',
      );
    }
    
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
    _checkIfOnboardingCompleted();
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



  

  Future<void> _checkIfOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    bool completed = prefs.getBool('onboardingCompleted') ?? false;
    
    if (!completed) {
      setState(() {
        _showOnboarding = true;
      });
    }
  }

  void _markOnboardingAsComplete() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('onboardingCompleted', true);

    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) { 
      
      return Scaffold(
      body: Stack(
        children: [ ScreenTypeLayout.builder(
      mobile: (BuildContext context) => MobileNavBar(),
      desktop: (BuildContext context) => DeskTopNavBar(),
       ),
  
  // Onboarding overlay
          if (_showOnboarding)
            Positioned.fill(
              child: GestureDetector(
                onTap: _markOnboardingAsComplete,
                child: OnboardingOverlay(
                  currentStep: _currentStep,
                  onNext: _nextStep,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _markOnboardingAsComplete();
    }
  }

 

    Widget MobileNavBar() {
      bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return   Scaffold(
     
      body: SingleChildScrollView(child: Column(
        
        children: [
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
Row(children: [
  SizedBox(width: 20,),
 Text( '$cityname',style: TextStyle(fontSize: 20,color: Colors.grey,fontWeight: FontWeight.w600),),
],),
Row(children: [
 TextButton(onPressed: (){
   showGeneralDialog(
  context: context,
  barrierDismissible: true,
  barrierLabel: "Menu",
  barrierColor: Colors.black.withOpacity(0.5),
  pageBuilder: (context, anim1, anim2) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder( // 👈 wrap with StatefulBuilder
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Image.asset('assets/images/logo.png'),
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Fahrenheit',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        Switch(
                          value: isFahrenheit,
                          onChanged: (value) {
                            setState(() {
                              isFahrenheit = value;
                            });
                            // Also update your main app state
                            this.setState(() {
                              isFahrenheit = value;
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    SizedBox(height: 100),
                    Text('Powered by Openweather'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  },
  transitionBuilder: (context, anim1, anim2, child) {
    return FadeTransition(opacity: anim1, child: child);
  },
  transitionDuration: const Duration(milliseconds: 200),
);

 }, child: Icon(Icons.settings,size: 30,color: Colors.grey)),
  SizedBox(width: 20,),
],)
          ],),
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Opacity(
            opacity: 0.5,
           
              child: Image.asset(  weatherConditionToIcon[currently] ?? 'assets/images/cloud.gif',height:200, fit:BoxFit.cover,)
              ),
              Text(
              '${isFahrenheit ? tempFahrenheit.round() :tempCelsius.round()}\u00B0', // Use Unicode for the degree symbol
              style: TextStyle(
                fontSize: 100,
                color:   isDarkMode ?   Colors.white : Colors.black,
              ),)
       ],),
       Text('${description}',style: TextStyle(fontWeight: FontWeight.bold,color: isDarkMode ?   Colors.white : Colors.black,fontSize: 15),),
      SizedBox(height: 20,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
           Container(decoration: BoxDecoration(
            color: const Color.fromARGB(80, 158, 158, 158),
            borderRadius: BorderRadius.all(Radius.circular(360))),
           child:  Icon(Icons.arrow_upward,color:   isDarkMode ?   Colors.white : Colors.black),
           ),
 Column(children: [
            Text('Max',style: TextStyle(color: Colors.grey,   fontSize: 17)),
  Text('${isFahrenheit ? temp_maxf.round() : temp_max.round()}\u00B0',style: TextStyle(color:   isDarkMode ?   Colors.white : Colors.black),),
          ],),
          ],),
         
      
        SizedBox(width: 20,),
         Row(children: [
           Container(decoration: BoxDecoration(
            color: const Color.fromARGB(80, 158, 158, 158),
            borderRadius: BorderRadius.all(Radius.circular(360))),
           child:  Icon(Icons.arrow_downward,color:   isDarkMode ?   Colors.white : Colors.black),
           ),
 Column(children: [
            Text('Min',style: TextStyle(color: Colors.grey,fontSize: 17)),
    Text('${isFahrenheit ? temp_minf.round() : temp_min.round()}\u00B0',style: TextStyle(color:   isDarkMode ?   Colors.white : Colors.black),),
          ],),
          ],),
      
      ]),
      SizedBox(height: 50,),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
Row(children: [
  SizedBox(width: 20,),
  Image.asset('assets/images/rain.png',height: 25,),
  SizedBox(width: 5,),
  Text('Feels Like',style: TextStyle(color: Colors.grey),),
],),
Row(children: [
  Text('  ${isFahrenheit ? feels_likef.round() : feels_like.round()}${isFahrenheit ? '°F' : '°C'}',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color:  isDarkMode ?   Colors.white : Colors.black),),
SizedBox(width: 20,),
],),
 
      ],),
      SizedBox(height: 10,),
   Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
Row(children: [
  SizedBox(width: 20,),
   Image.asset('assets/images/wind.png',height: 25,),
  SizedBox(width: 5,),
  Text('Wind Speed',style: TextStyle(color: Colors.grey),),
],),
Row(children: [
  Text('${windSpeed.round()}km/h',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color: isDarkMode ?   Colors.white : Colors.black),),
SizedBox(width: 20,),
],),
 
      ],),
      SizedBox(height: 10,),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
Row(children: [
  SizedBox(width: 20,),
   Image.asset('assets/images/pressure.png',height: 25,),
  SizedBox(width: 5,),
  Text('Pressure',style: TextStyle(color: Colors.grey),),
],),
Row(children: [
    Text(' ${pressure}hpa',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color:  isDarkMode ?   Colors.white : Colors.black)),
SizedBox(width: 20,),
],),
 
      ],),
      SizedBox(height: 10,),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
Row(children: [
  SizedBox(width: 20,),
   Image.asset('assets/images/visibility.png',height: 25,),
  SizedBox(width: 5,),
  Text('Visibility ',style: TextStyle(color: Colors.grey),),
],),
Row(children: [
     Text('${visibility}km',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color: isDarkMode ?   Colors.white : Colors.black)),
SizedBox(width: 20,),
],),
 
      ],),
      SizedBox(height: 10,),
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
Row(children: [
  SizedBox(width: 20,),
   Image.asset('assets/images/humidity.png',height: 25,),
  SizedBox(width: 5,),
  Text('Humidity',style: TextStyle(color: Colors.grey),),
],),
Row(children: [
    Text(
                '${humidity.toInt()}%',
                style: TextStyle(
                  color:  isDarkMode ?   Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
SizedBox(width: 20,),
],),
 
      ],),
      SizedBox(height: 10,),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
Row(children: [
  SizedBox(width: 20,),
  Image.asset('assets/images/map.png',height: 25,),
  SizedBox(width: 5,),
  Text('Country',style: TextStyle(color: Colors.grey),),
],),
Row(children: [
   Text('${country}',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color:   isDarkMode ?   Colors.white : Colors.black,)),
SizedBox(width: 20,),
],),
 
      ],),
     
      ],),),
       backgroundColor:    isDarkMode ?  const Color.fromARGB(255, 21, 68, 150) : Colors.white,
    );
  }

  Widget DeskTopNavBar() {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      
     body:SingleChildScrollView(child: Column(
        
        children: [
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
Row(children: [
  SizedBox(width: 20,),
 Text( '$cityname',style: TextStyle(fontSize: 20,color: Colors.grey,fontWeight: FontWeight.w600),),
],),
Row(children: [
 TextButton(onPressed: (){
   showGeneralDialog(
  context: context,
  barrierDismissible: true,
  barrierLabel: "Menu",
  barrierColor: Colors.black.withOpacity(0.5),
  pageBuilder: (context, anim1, anim2) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder( // 👈 wrap with StatefulBuilder
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png'),
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Fahrenheit',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        Switch(
                          value: isFahrenheit,
                          onChanged: (value) {
                            setState(() {
                              isFahrenheit = value;
                            });
                            // Also update your main app state
                            this.setState(() {
                              isFahrenheit = value;
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    SizedBox(height: 100),
                    Text('Powered by Openweather'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  },
  transitionBuilder: (context, anim1, anim2, child) {
    return FadeTransition(opacity: anim1, child: child);
  },
  transitionDuration: const Duration(milliseconds: 200),
);

 }, child: Icon(Icons.settings,size: 30,color: Colors.grey)),
  SizedBox(width: 20,),
],)
          ],),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
 Column(children: [
  Row(
     
        children: [
      SizedBox(width: 200,),
         Opacity(
            opacity: 0.5,
           
              child: Image.asset(  weatherConditionToIcon[currently] ?? 'assets/images/cloud.gif',height:200, fit:BoxFit.cover,)
              ),
          SizedBox(width: 50,),

              Text(
              '${isFahrenheit ? tempFahrenheit.round() :tempCelsius.round()}\u00B0', // Use Unicode for the degree symbol
              style: TextStyle(
                fontSize: 150,
                color:   isDarkMode ?   Colors.white : Colors.black,
              ),),
          

       ],),
   Text('${description}',style: TextStyle(fontWeight: FontWeight.bold,color: isDarkMode ?   Colors.white : Colors.black,fontSize: 15),),
 ],),

    Column(children: [   Row(

        children: [
          Row(children: [
           Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
            color: const Color.fromARGB(80, 158, 158, 158),
            borderRadius: BorderRadius.all(Radius.circular(360))),
           child:  Icon(Icons.arrow_upward,color:   isDarkMode ?   Colors.white : Colors.black),
           ),
 Column(children: [
            Text('Max',style: TextStyle(color: Colors.grey,   fontSize: 20)),
  Text('${isFahrenheit ? temp_maxf.round() : temp_max.round()}\u00B0',style: TextStyle(color:   isDarkMode ?   Colors.white : Colors.black,fontSize: 20),),
          ],),
          ],),

      SizedBox(width: 50,),
  Row(children: [
           Container(
             height: 40,
            width: 40,
            decoration: BoxDecoration(
            color: const Color.fromARGB(80, 158, 158, 158),
            borderRadius: BorderRadius.all(Radius.circular(360))),
           child:  Icon(Icons.arrow_downward,color:   isDarkMode ?   Colors.white : Colors.black),
           ),
 Column(children: [
            Text('Min',style: TextStyle(color: Colors.grey,fontSize: 20)),
    Text('${isFahrenheit ? temp_minf.round() : temp_min.round()}\u00B0',style: TextStyle(color:   isDarkMode ?   Colors.white : Colors.black,fontSize: 20),),
          ],),

          ],),
     SizedBox(width: 150,),
       ],),
       SizedBox(height: 50,),
         Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
Row(children: [

  Text('Feels Like',style: TextStyle(color: Colors.deepOrange,fontSize: 20),),
 
],),
Row(children: [
  Text('  ${isFahrenheit ? feels_likef.round() : feels_like.round()}${isFahrenheit ? '°F' : '°C'}',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.deepOrange),),

 SizedBox(width: 100,),
],),
 
      ],),
       

       ],)
        
          ],),
       
    
    
      SizedBox(height: 50,),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: 20,),
Row(children: [
  SizedBox(width: 20,),
   Image.asset('assets/images/wind.png',height: 25,),
  SizedBox(width: 20,),
 Column(children: [
 Text('Wind Speed',style: TextStyle(color: Colors.grey),),
  Text('${windSpeed.round()}km/h',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color: isDarkMode ?   Colors.white : Colors.black),),

 ],)
],),

 
     SizedBox(width: 50,),

      
Row(children: [
  SizedBox(width: 20,),
   Image.asset('assets/images/pressure.png',height: 25,),
  SizedBox(width: 20,),
  Column(
    children: [
Text('Pressure',style: TextStyle(color: Colors.grey),),
    Text(' ${pressure}hpa',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color:  isDarkMode ?   Colors.white : Colors.black)),

    ],
  )


 
      ],),
     SizedBox(width: 50,),
      
Row(children: [
  SizedBox(width: 20,),
   Image.asset('assets/images/visibility.png',height: 25,),
  SizedBox(width: 20,),
 Column(children: [
   Text('Visibility ',style: TextStyle(color: Colors.grey),),
     Text('${visibility}km',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color: isDarkMode ?   Colors.white : Colors.black)),

 ],)
],),

 
   
     SizedBox(width: 50,),
  
Row(children: [
  SizedBox(width: 20,),
   Image.asset('assets/images/humidity.png',height: 25,),
  SizedBox(width: 20,),
Column(children: [
   Text('Humidity',style: TextStyle(color: Colors.grey),),
    Text(
                '${humidity.toInt()}%',
                style: TextStyle(
                  color:  isDarkMode ?   Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
],)
],),
  SizedBox(width: 20,),
    ],),
  
  

 

 
 
      SizedBox(height: 50,),
     
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  SizedBox(width: 20,),
  Image.asset('assets/images/map.png',height: 25,),
  SizedBox(width: 20,),
  Column(children: [
    Text('Country',style: TextStyle(color: Colors.grey),),
   Text('${country}',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color:   isDarkMode ?   Colors.white : Colors.black,)),

  ],)
],),


     
      ],),),
            backgroundColor:    isDarkMode ?  const Color.fromARGB(255, 21, 68, 150) : Colors.white,
    );
    
  }
}

class OnboardingOverlay extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNext;

  OnboardingOverlay({required this.currentStep, required this.onNext});

  @override
  Widget build(BuildContext context) {
   

    return GestureDetector(
      onTap: onNext,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_pin, color: Colors.white, size: 50),
              SizedBox(height: 20),
              Text(
                'Location Access',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 10),
              Text(
                'To get accurate weather updates, please enable location access on your device or browser and allow this site to access your location.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: onNext,
                child: Text('Next',style: TextStyle(color: const Color.fromARGB(255, 135, 134, 134)),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}