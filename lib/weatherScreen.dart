// ignore_for_file: camel_case_types, file_names

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_ui.dart';
import 'package:weather_app/hourly_forcast.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class weatherScreen extends StatefulWidget {
  const weatherScreen({super.key});

  @override
  State<weatherScreen> createState() => _weatherScreenState();
}

class _weatherScreenState extends State<weatherScreen> {
  late Future<Map<String, dynamic>> weather;
  late TextEditingController _searchController;
  String cityname = 'Ahmedabad, Gujarat';
  Future<Map<String, dynamic>> getWeatherData() async {
    try {
      final responce = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityname&APPID=$openWeatherApiKey&units=metric'),
      );

      final weatherdata = jsonDecode(responce.body);

      if (weatherdata['cod'] != '200') {
        throw 'An unexpected errror occured';
      }
      return weatherdata;
    } catch (e) {
      throw 'An unexpected errror occured';
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getWeatherData();
    _searchController = TextEditingController();
  }

  void _searchWeather() {
    setState(() {
      cityname = _searchController.text;
      weather = getWeatherData();
      _searchController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color.fromARGB(
              255, 201, 212, 228) // Set to black for light theme
          : null,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? const Color.fromARGB(255, 201, 212, 228)
            : null, // Use default color for dark theme
        title: Text(
          cityname,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                cityname = 'Ahmedabad, Gujarat';
                weather = getWeatherData();
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final weatherdata = snapshot.data!;
          final currentWeatherData = weatherdata['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentsky = currentWeatherData['weather'][0]['main'];
          final pressure = currentWeatherData['main']['pressure'];
          final humidity = '${currentWeatherData['main']['humidity']} %';
          final windSpeed = currentWeatherData['wind']['speed'];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Enter city name',
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(100),
                          splashColor: Colors.black12,
                          radius: 12,
                          onTap: () {
                            if (_searchController.text.isNotEmpty) {
                              _searchWeather();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? const Color.fromARGB(
                                        94, 0, 0, 0) // Light theme color
                                    : const Color.fromARGB(
                                        123, 255, 255, 255), // Dark theme color
                                width: 1.1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black54 // Light theme color
                                    : Colors.white54,
                              ),
                              onPressed: _searchController.text.isNotEmpty
                                  ? _searchWeather
                                  : null, // Disable onPressed when text is empty
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  //main cart
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                                Text(
                                  '$currentTemp °C',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Icon(
                                  currentsky == 'Clouds' || currentsky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  currentsky,
                                  style: const TextStyle(
                                    fontSize: 20,
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

                  // weather forcast card
                  const Text(
                    'Hourly Forecast',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final hourlyforcastdata =
                            weatherdata['list'][index + 2];
                        final hourlySky =
                            hourlyforcastdata['weather'][0]['main'];
                        final hourlyTemp =
                            hourlyforcastdata['main']['humidity'].toString();
                        final time =
                            DateTime.parse(hourlyforcastdata['dt_txt']);
                        return Hourlyforcastui(
                          time: DateFormat.j().format(time),
                          temp: '$hourlyTemp %',
                          icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  //addisnal info
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      additionalInfoItems(
                        icon: Icons.water_drop,
                        lable: 'Humidity',
                        value: humidity.toString(),
                      ),
                      additionalInfoItems(
                        icon: Icons.air,
                        lable: 'Wind Speed',
                        value: windSpeed.toString(),
                      ),
                      additionalInfoItems(
                        icon: Icons.speed,
                        lable: 'Pressure',
                        value: pressure.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
