import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/secrets.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  //double temp = 0;
  // bool isLoading = false;
  // @override
  // void initState() {
  //   super.initState();
  //   getCurrentWeather();
  // }

  Future<Map<String, dynamic>> getCurrentWeather() async{
    try{
      // setState(() {
      //   isLoading = true;
      // });
    String cityName = 'London';
    final result = await http.get(
      Uri.parse('http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIkey'),
    );

    final data = jsonDecode(result.body);

   if(int.parse(data['cod']) != 200){
      throw 'An unexpected error occured';
      //throw data['message'];
   }

   
    return data;
   
    // setState(() {
    //   temp = data['list'][0]['main']['temp'];
    //   isLoading = false;
    // });

  }catch(e){
    throw e.toString();
  }
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Weather App',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        ),
        actions: [
          // GestureDetector(
          //   onTap: () {
          //     print('Refresh');
          //   },
          //   child: const Icon(Icons.refresh),
          //   ),
          // InkWell(
          //   onTap: () {
          //     print('Refresh');
          //   },
          //   child: const Icon(Icons.refresh),
          //   ),

          IconButton(onPressed: () {
            setState(() {
              
            });
          },
          icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: //isLoading ? const LinearProgressIndicator() : 
      FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const LinearProgressIndicator();
          }

          if(snapshot.hasError){
            return Center(
              child: Text(snapshot.error.toString()
              ),
            );
          }

          final data = snapshot.data!;
          final currentTemp = data['list'][0]['main']['temp'];
          final currentSky = data['list'][0]['weather'][0]['main'];
          final currentPressure = data['list'][0]['main']['pressure'];
          final currentHumidity = data['list'][0]['main']['humidity'];
          final windSpeed = data['list'][0]['wind']['speed'];

          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10, 
                        sigmaY: 10,
                        ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                          Text('$currentTemp K',
                          style:const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                          ),
                         const SizedBox(height: 16),
                          Icon(
                           currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud : Icons.sunny,
                          size: 65,
                          ),
                          const SizedBox(height: 16,),
                          Text(currentSky,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          
              const SizedBox(
                height: 20,
              ),
          
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Hourly Forecast',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                ),
              ),
          
              const SizedBox(
                height: 15,
              ),
              
              //  SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //    child: Row(
              //     children: [
              //       for(int i=0; i<5; i++)
              //        HourlyForecastItem(
              //         time: data['list'][i+1]['dt'].toString(),
              //         icon: data['list'][i+1]['weather'][0]['main'] == 'Clouds' || data['list'][i+1]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
              //         temperature: data['list'][i+1]['main']['temp'].toString(),
              //        ),
              //     ],
              //     ),
              //  ),

              SizedBox(
                height: 130,
                child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index){
                  final time = DateTime.parse(data['list'][index+1]['dt_txt']);
                  return HourlyForecastItem(
                    time: DateFormat.j().format(time),
                    temperature: data['list'][index+1]['main']['temp'].toString(), 
                    icon: data['list'][index+1]['weather'][0]['main'] == 'Clouds' || data['list'][index+1]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
                    );
                 }
                ),
              ),

              const SizedBox(
                height: 22,
              ),
          
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Additional Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                ),
              ),
              const SizedBox( height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '$currentHumidity',
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: '$windSpeed',
                  ),
                  AdditionalInfoItem(
                    icon: Icons.beach_access,
                    label: 'Pressure',
                    value: currentPressure.toString(),
                  ),
                ],
              )
          ],
          ),
        );
        },
      ),
    );
  }
}