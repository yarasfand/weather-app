import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:worldtime/worldtime.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/data_loader_bloc.dart';
import '../model/postModels.dart';
import '../model/weatherapi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool locationError = false;
  double? currentLat;
  double? currentLong;

  String currentLocation = "";
  String city = "";
  double? temperatureCelsius = 0.0;
  int offsetSeconds = 0;
  DateTime localTime = DateTime.now();
  String? imagePath = null;

  String refreshLat = '';
  String refreshLong = '';


  Future<void> checkLocationPermission() async {
    Geolocator.getServiceStatusStream().listen((status) {
      if (mounted) {
        setState(() {
          locationError = status != ServiceStatus.enabled;
        });
      }
    });
  }

  Future<void> checkLocationPermissionAndFetchLocation() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        final data = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        if (mounted) {
          currentLat = data.latitude;
          currentLong = data.longitude;
          await getAddress(currentLat!, currentLong!);
          locationError = false;
        }
      } catch (e) {
        print('Error getting location: $e');
      }
    } else {
      if (mounted) {
        locationError = true;
      }
    }
  }

  Future<void> getAddress(double lat, double long) async {
    try {
      List<Placemark> cityName = await GeocodingPlatform.instance
          .placemarkFromCoordinates(lat, long, localeIdentifier: "en");
      if (cityName.isNotEmpty) {
        setState(() {
          if (cityName[4].locality != null) {
            city = cityName[4].locality!;
          }
        });
      }
      print("sfjmsfllllllllll");
        } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> getWeather(String getLat, String getLong) async {
    print('Fetching weather for $getLat');
    try {
      GetWeatherUpdate weatherUpdate = GetWeatherUpdate();
      WeatherModel weatherInfo =
          await weatherUpdate.fetchWeather(getLat, getLong);

      if (weatherInfo.current != null && weatherInfo.hourlyUnits != null) {
        temperatureCelsius = weatherInfo.current?.temperature2m?.toDouble();

        setState(() {
          temperatureCelsius = weatherInfo.current?.temperature2m?.toDouble();
          print("${localTime}");
        });

        if (localTime.hour >= 19 || localTime.hour < 5) {
          imagePath = 'lib/weatherAssets/night.jpg';
        } else {
          imagePath = 'lib/weatherAssets/sunny.jpg';
        }
      } else {
        print('No temperature data available for');
      }
    } catch (e) {
      print('Error getting weather data: $e');
    }
  }

  final Map<String, List<double>> cityCoordinates = {
    'Lahore': [31.5497, 74.3436],
    'Karachi': [24.8607, 67.0011],
    'Islamabad': [33.6844, 73.0479],
    'Rawalpindi': [33.6844, 73.0479],
    'Faisalabad': [31.4504, 73.1340],
    'Multan': [30.1798, 71.4214],
    'Quetta': [30.1798, 66.9750],
    'Peshawar': [33.6844, 73.0479],
    'Sialkot': [32.4945, 74.5229],
    'Gujranwala': [32.1612, 74.1883],
    'Toronto': [43.6532, -79.3832],
    'Vancouver': [49.2827, -123.1207],
    'Montreal': [45.5017, -73.5673],
    'Calgary': [51.0447, -114.0719],
    'Edmonton': [53.5444, -113.4909],
    'Ottawa': [45.4215, -75.6993],
    'Winnipeg': [49.8951, -97.1384],
    'Quebec City': [46.8139, -71.2080],
    'Hamilton': [43.2557, -79.8711],
    'Halifax': [44.6488, -63.5752],
    'London': [51.5099, -0.1180],
    'Manchester': [53.4830, -2.2446],
    'Birmingham': [52.4862, -1.8904],
    'Liverpool': [53.4084, -2.9916],
    'Glasgow': [55.8642, -4.2518],
    'Bristol': [51.4545, -2.5879],
    'Leeds': [53.8008, -1.5491],
    'Newcastle': [54.9783, -1.6174],
    'Sheffield': [53.3811, -1.4701],
    'Nottingham': [52.9550, -1.1492],
    'Riyadh': [24.7136, 46.6753],
    'Jeddah': [21.3891, 39.8579],
    'Mecca': [21.3891, 39.8579],
    'Medina': [24.5247, 39.5692],
    'Dammam': [26.3927, 49.9777],
    'Khobar': [26.3020, 50.1972],
    'Jubail': [27.0337, 49.5922],
    'Tabuk': [28.3835, 36.5556],
    'Hail': [27.5216, 41.6904],
    'Najran': [17.5374, 44.1217],
  };

  void enteredCityName(String cityName) async {
    try {
      if (cityName.isNotEmpty) {
        if (cityCoordinates.containsKey(cityName)) {
          List<double> coordinates = cityCoordinates[cityName]!;
          double latitude = coordinates[0];
          double longitude = coordinates[1];

          refreshLat = latitude.toString();
          refreshLong = longitude.toString();

          await getAddress(latitude, longitude);

          setState(() {
            city = cityName;
          });

          // Dispatch the FetchWeatherEvent to trigger loading state
          BlocProvider.of<WeatherBloc>(context).add(
            FetchWeatherEvent(latitude.toString(), longitude.toString()),
          );

          setState(() {
            temperatureCelsius = null;
          });

          final _worldtimePlugin = Worldtime();

          localTime = await _worldtimePlugin.timeByLocation(
            latitude: latitude,
            longitude: longitude,
          );

          await getWeather(latitude.toString(), longitude.toString());
          print("City: $latitude,$cityName");

          print("Latitude: $latitude");
          print("Longitude: $longitude");
        } else {
          print("No coordinates found for $cityName");
        }
      } else {
        print("Entered city name is empty");
      }
    } catch (e) {
      print("Error in enteredCityName: $e");
    }
  }

  Future<void> _refreshData() async {
    await getWeather(refreshLat, refreshLong);

    // Dispatch the FetchWeatherEvent with updated coordinates
    BlocProvider.of<WeatherBloc>(context).add(
      FetchWeatherEvent(refreshLat, refreshLong),
    );
  }

  @override
  void initState() {
    super.initState();
    initializeLocation();
  }

  Future<void> initializeLocation() async {
    await checkLocationPermission();
    await checkLocationPermissionAndFetchLocation();
    refreshLat = currentLat.toString();
    refreshLong = currentLong.toString();
    await getWeather(currentLat.toString(), currentLong.toString());
    BlocProvider.of<WeatherBloc>(context)
        .add(FetchWeatherEvent(currentLat.toString(), currentLong.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoadingState || temperatureCelsius == null) {
          return Scaffold(
            body: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: buildShimmerContent(context),
            ),
          );
        } else if (state is WeatherLoadedState) {
          final weather = state.weather;
          if (locationError) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Fetching Location..."),
                  ],
                ),
              ),
            );
          } else if (currentLat != null &&
              currentLong != null &&
              imagePath != null) {
            Color textColor = Colors.white;
            String dayWeatherEmoji = '⛅';
            String nightWeatherEmoji = '🌙';

            List<String>? futureTimes = weather.hourly!.time!;
            List<int>? hourlyIndexes = [];
            List<DateTime> futureTimesGreater = [];

            for (int i = 0, count = 0;
                count < 10 && i < futureTimes.length;
                i++) {
              DateTime currentFutureTime = DateTime.parse(futureTimes[i]);
              if (localTime.isBefore(currentFutureTime)) {
                futureTimesGreater.add(currentFutureTime);
                hourlyIndexes.add(i);
                count++;
              }
            }

            return Scaffold(
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      10, MediaQuery.of(context).size.height / 9, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center align vertically
                        children: [
                          Text(
                            city,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                              color: textColor,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(temperatureCelsius?.round())}°',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.height / 11,
                                  fontWeight: FontWeight.w300,
                                  color: textColor,
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(8, -20),
                                // Adjust the vertical offset as needed
                                child: Transform.scale(
                                  scale:
                                      1.5, // Adjust the scale factor as needed
                                  child: Text(
                                    'C',
                                    style: TextStyle(
                                      fontSize:
                                          28, // Adjust the font size as needed
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${weather.daily!.temperature2mMin![0].round()} / ${weather.daily!.temperature2mMax![0].round()} °C",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 12.5),
                      const SizedBox(height: 16),
                      Container(
                        height: MediaQuery.of(context).size.width / 3,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: futureTimesGreater.length,
                          itemBuilder: (context, index) {
                            double cardWidth =
                                MediaQuery.of(context).size.width / 4.5;

                            // Parse time from the futureTimesGreater list
                            DateTime cardTime = futureTimesGreater[index];

                            // Check if the time is less than 6 pm or greater than 6 am
                            bool isNightTime =
                                cardTime.hour >= 18 || cardTime.hour < 6;

                            return Container(
                              width: cardWidth,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              child: Material(
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat.jm().format(cardTime),
                                      style: TextStyle(
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      isNightTime
                                          ? nightWeatherEmoji
                                          : dayWeatherEmoji,
                                      style: const TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      "${weather.hourly!.temperature2m![hourlyIndexes[index]].round()}°C",
                                      style: TextStyle(
                                        color: textColor,
                                      ),
                                    ),
                                    // Add other card contents here
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Divider(
                        color: Colors.white
                            .withOpacity(0.5), // Adjust the opacity as needed
                        height: 10, // Adjust the height as needed
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width / 3,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: weather.daily!.time!.length,
                          itemBuilder: (context, index) {
                            double cardWidth =
                                MediaQuery.of(context).size.width / 4.5;

                            // Parse time from the daily times list
                            DateTime cardTime =
                                DateTime.parse(weather.daily!.time![index]);

                            // Determine the label based on the index
                            String dayLabel = '';
                            if (index == 0) {
                              dayLabel = 'Today';
                            } else if (index == 1) {
                              dayLabel = 'Tomorrow';
                            } else {
                              dayLabel = DateFormat('EEEE').format(cardTime);
                            }

                            // Format month with date (e.g., 02/04)
                            String monthDate =
                                DateFormat('MM/dd').format(cardTime);

                            return Container(
                              width: cardWidth,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              child: Material(
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dayLabel,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      monthDate,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      dayWeatherEmoji,
                                      style: const TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${weather.daily!.temperature2mMin![index].round()} / ${weather.daily!.temperature2mMax![index].round()}°C",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _showTypeAheadField,
                tooltip: 'Show City Selector',
                child: const Icon(Icons.search_outlined),
              ),
            );
          } else {
            checkLocationPermission();
            checkLocationPermissionAndFetchLocation();
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Fetching Location..."),
                  ],
                ),
              ),
            );
          }
        } else {
          return Scaffold(
            body: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: buildShimmerContent(context),
            ),
          );
        }
      },
    );
  }

  void _showTypeAheadField() {
    TextEditingController textEditingController = TextEditingController();
    String enteredText = '';

    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Search City",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TypeAheadField<String>(
                suggestionsCallback: (search) {
                  return cityCoordinates.keys
                      .where((city) =>
                          city.toLowerCase().contains(search.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, String cityName) {
                  return ListTile(
                    title: Text(cityName),
                  );
                },
                onSuggestionSelected: (String cityName) {
                  // Update the text field with the selected city
                  textEditingController.text = cityName;
                },
                textFieldConfiguration: TextFieldConfiguration(
                  controller: textEditingController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter City Name',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                hideSuggestionsOnKeyboardHide: false,
                hideOnLoading: true,
                noItemsFoundBuilder: (context) {
                  return const ListTile(
                    title: Text('No data found'),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  enteredText = textEditingController.text;
                  imagePath = null;
                  enteredCityName(enteredText);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white12,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShimmerContent(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            10, MediaQuery.of(context).size.height / 9, 10, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center align vertically
              children: [
                const Text(
                  'City',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '00',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 11,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(8, -20),
                      // Adjust the vertical offset as needed
                      child: Transform.scale(
                        scale: 1.5, // Adjust the scale factor as needed
                        child: const Text(
                          'C',
                          style: TextStyle(
                            fontSize: 28, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  "00/00 °C",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 12.5),
            const SizedBox(height: 16),
            SizedBox(
              height: MediaQuery.of(context).size.width / 3,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  double cardWidth = MediaQuery.of(context).size.width / 4.5;

                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: const Material(
                      color: Colors.black54,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "***",
                            style: TextStyle(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "⛅",
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "00C",
                          ),
                          // Add other card contents here
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(
              color:
                  Colors.white.withOpacity(0.5), // Adjust the opacity as needed
              height: 10, // Adjust the height as needed
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width / 3,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  double cardWidth = MediaQuery.of(context).size.width / 4.5;

                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: const Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "***",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "***",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '⛅',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "00/00°C",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
