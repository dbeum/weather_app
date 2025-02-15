import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:weather_web/humidity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:vitality/vitality.dart';
import 'package:weather_animation/weather_animation.dart';


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
    return  DraggableHome(
  title: Text("Today\'s Weather",style:TextStyle(fontWeight: FontWeight.bold)),
  headerWidget: _buildHeaderWidget(),
  body: [
    
    AnimateGradient(
       primaryColors:  [
         isDarkMode ? Color.fromARGB(255, 30, 58, 72)  : Color.fromARGB(255, 135, 206, 235), 
isDarkMode ? Color.fromARGB(255, 52, 73, 94) : Color.fromARGB(255, 255, 167, 38), 
isDarkMode  ? Color.fromARGB(255, 0, 0, 0) : Color.fromARGB(255, 255, 255, 255), 

        ],
        secondaryColors:  [
       isDarkMode ? Color.fromARGB(255, 16, 32, 39)  : Color.fromARGB(255, 55, 71, 79), 
isDarkMode   ? Color.fromARGB(255, 27, 73, 101) : Color.fromARGB(255, 41, 182, 246), 
isDarkMode  ? Color.fromARGB(255, 18, 18, 18): Color.fromARGB(255, 245, 245, 245), 

          
        ],
        child:  Stack(
      children: [
        
      
        Column(
      children: [
        SizedBox(height: 80,),
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
           
              child: Image.asset(  weatherConditionToIcon[currently] ?? 'assets/images/cloud.gif',height:200, fit:BoxFit.cover,)
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
                  width: 130,
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
                  width: 130,
                  decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(children: [
                    SizedBox(height: 10,),
                    Text('Wind Speed',style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                         Text('${windSpeed.round()}km/h',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                  ],)
                ),
               ],),
                SizedBox(height: 10,),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                HumidityWidget(humidity: humidity),
                   Container(
                  height: 100,
                  width: 130,
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
                  width: 130,
                  decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.all(Radius.circular(15))),
                  child:  Column(
                    children: [
                      SizedBox(height: 10,),
                          Text('Visibility: ',style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 2,),
                          Text('${visibility}km',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
                        
                    ],
                  )
                ),
                   Container(
                  height: 100,
                  width: 130,
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

      ),

   
    

    
  ],
   backgroundColor:    isDarkMode ?  Color.fromARGB(255, 42,39,48)  : Colors.grey[200],
);
  }

Widget DeskTopNavBar() {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
 return  DraggableHome(
  title: Text("Today\'s Weather",style:TextStyle(fontWeight: FontWeight.bold)),
  headerWidget: _buildHeaderWidget(),
  body: [
    
    AnimateGradient(
         primaryColors:  [
         isDarkMode ? Color.fromARGB(255, 30, 58, 72)  : Color.fromARGB(255, 135, 206, 235), 
isDarkMode ? Color.fromARGB(255, 52, 73, 94) : Color.fromARGB(255, 255, 167, 38), 
isDarkMode  ? Color.fromARGB(255, 0, 0, 0) : Color.fromARGB(255, 255, 255, 255), 

        ],
        secondaryColors:  [
       isDarkMode ? Color.fromARGB(255, 16, 32, 39)  : Color.fromARGB(255, 55, 71, 79), 
isDarkMode   ? Color.fromARGB(255, 27, 73, 101) : Color.fromARGB(255, 41, 182, 246), 
isDarkMode  ? Color.fromARGB(255, 18, 18, 18): Color.fromARGB(255, 245, 245, 245), 

          
        ],
        child:  Stack(
      children: [
        
      
        Column(
      children: [
        SizedBox(height: 80,),
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
           
              child: Image.asset(  weatherConditionToIcon[currently] ?? 'assets/images/cloud.gif',height:200, fit:BoxFit.cover,)
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
                  width: 130,
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
                  width: 130,
                  decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(children: [
                    SizedBox(height: 10,),
                    Text('Wind Speed',style: TextStyle(fontWeight: FontWeight.bold,),),
                    SizedBox(height: 10,),
                         Text('${windSpeed.round()}km/h',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                  ],)
                ),
               ],),
                SizedBox(height: 10,),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                HumidityWidget(humidity: humidity),
                   Container(
                  height: 100,
                  width: 130,
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
                  width: 130,
                  decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.all(Radius.circular(15))),
                  child:  Column(
                    children: [
                      SizedBox(height: 10,),
                          Text('Visibility: ',style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 2,),
                          Text('${visibility}km',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
                        
                    ],
                  )
                ),
                   Container(
                  height: 100,
                  width: 130,
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

      ),

   
    

    
  ],
   backgroundColor:    isDarkMode ?  Color.fromARGB(255, 42,39,48)  : Colors.grey[200],
);
}

Widget _buildHeaderWidget() {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Stack(children: [
 Container(
      color: Colors.grey[200],
      child: Vitality.randomly(
  background: isDarkMode?  Color.fromARGB(255, 42,39,48) :  Colors.grey[200],
  maxOpacity: 0.8,
  minOpacity: 0.3,
  itemsCount: 80,
  enableXMovements: false,
  whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
  maxSpeed: 1.5,
  maxSize: 30,
  minSpeed: 0.5,
  randomItemsColors: [Colors.yellowAccent, Colors.white],
  randomItemsBehaviours: [
    ItemBehaviour(shape: ShapeType.Icon, icon: Icons.nightlight),
    ItemBehaviour(shape: ShapeType.Icon, icon: Icons.sunny),
    ItemBehaviour(shape: ShapeType.Icon,icon:Icons.cloud),
  ],
)
        
      
    ),
    Center(child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Farehnheit',style: TextStyle(fontWeight: FontWeight.bold),),
              
                     Switch(
                value: isFahrenheit,
                onChanged: toggleSwitch,
                activeTrackColor: Colors.lightGreenAccent,      
                activeColor: Colors.green,
              ),

                      ],
                    ),)
    ],);
    
   
  }
}




class OnboardingOverlay extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNext;

  OnboardingOverlay({required this.currentStep, required this.onNext});

  @override
  Widget build(BuildContext context) {
    String description = '';
    IconData icon = Icons.circle;
    String title = '';
    
    // Determine the current onboarding step
    switch (currentStep) {
      case 0:
        title = 'Weather Overview';
        description = 'See the current weather right here.';
        icon = Icons.sunny;
        break;
      case 1:
        title = 'Swipe Down';
        description = 'Switch between °F and °C';
        icon = Icons.arrow_downward;
        break;
      case 2:
        title = 'Swipe Right';
        description = 'Discover detailed weather info for your city';
        icon = Icons.arrow_right;
        break;
    }

    return GestureDetector(
      onTap: onNext,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 50),
              SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: onNext,
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}















/*
Drizzle
Thunderstorm




Dust


Ash
Squall
Tornado
Hurricane
Cold
Hot
Windy
Breezy
Freezing Rain
Sleet
Blowing Snow
Heavy Rain
Light Rain
Heavy Snow
Light Snow
Ice Pellets (or Hail)
Freezing Fog
*/

//location checking

/*Future getWeather() async {
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
    ); */