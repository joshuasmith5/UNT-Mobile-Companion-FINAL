import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:unt_app/calendar/view_event.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';
import '../map/map.dart' as navigation; // alias added due to naming conflict with Map class
import 'package:url_launcher/url_launcher.dart';
import '../login.dart';
import 'package:unt_app/calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as authentication; // alias added due to naming conflict with User class
import 'package:table_calendar/table_calendar.dart';
import 'package:unt_app/calendar/event.dart';
import '../home/settings.dart';
import '../home/notifications.dart';
import '../forum/views/search_page.dart';
import '../forum/forumStart.dart';

void main() {
  User enteredUser = User(name:'temp',password: 'pass', username:'user');
  runApp(MaterialApp(
    home: HomeScreen(currUser: enteredUser),
  ));
}

class HomeScreen extends StatefulWidget {
  final User currUser;
  HomeScreen({required this.currUser});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _city = '';
  String _state = '';
  WeatherFactory wf = new WeatherFactory("676fe152d1c58fa81a4dc61a3ab17a2d");
  double? tempFahrenheit;
  String? weatherDesc;
  List<String> temps = [];
  List<String> descs = [];
  List<String> dates = [];
  String? currentDate;
  List<Weather> forecast = [];
  User currUser = User(username:'temp', password: 'temp', name: 'temp');

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  late Map<DateTime, List<Event> > _events;

  final user = authentication.FirebaseAuth.instance.currentUser?.uid;

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
    currUser = widget.currUser;

    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));

    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    _loadFirestoreEvents();
  }

  // load events from firestore
  _loadFirestoreEvents() async {
    // used to only load events from current month viewed
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    _events = {}; // clear out _events so that duplicates do not load

    final snap = await FirebaseFirestore.instance.collection('events').where('from', isGreaterThanOrEqualTo: firstDay).where('from', isLessThanOrEqualTo: lastDay).where('user_id', isEqualTo: user).withConverter(fromFirestore: Event.fromFirestore, toFirestore: (event, options) => event.toFirestore()).get();
    for (var doc in snap.docs) {
      final event = doc.data();
      final day = DateTime.utc(event.from.year, event.from.month, event.from.day);
      if (_events[day] == null) {
        _events[day] = [];
      }
      _events[day]!.add(event);
    }
    setState(() {});
  }

  // display event markers
  List _getEventForTheDay(DateTime day) {
    return _events[day] ?? [];
  }

  //Future<List<Weather>> _getForecast() async {
  //  return await wf.fiveDayForecastByCityName(_city);
  //}

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _city = jsonData['address']['city'] ?? '';
        _state = jsonData['address']['state'] ?? '';
      });
      Weather w = await wf.currentWeatherByCityName(_city);
      forecast = await wf.fiveDayForecastByCityName(_city);
      DateTime curr = DateTime.now();


      for (int i = 1; i <= 4; i++) {
        DateTime forecastDate = curr.add(Duration(days: i));
        String formattedDate = DateFormat('MM-dd').format(forecastDate);
        for (Weather weather in forecast) {
          if (weather.date != null && DateFormat('MM-dd').format(weather.date!) == formattedDate) {
            String temperature = weather.temperature?.fahrenheit?.toStringAsFixed(0) ?? "n/a";
            String description = weather.weatherDescription ?? "n/a";
            String date = weather.date?.toString() ?? "n/a";
            temps.add(temperature);
            descs.add(description);
            dates.add(date);
            break;
          }
        }
      }
      setState(() {
        tempFahrenheit = w.temperature?.fahrenheit;
        weatherDesc = w.weatherDescription;
      });
    } else {
      throw Exception('Failed to get current location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container( // Wrap Scaffold with Container
      decoration: const BoxDecoration(
        color: Color(0xFF00853E), // Set the background color to green
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('$_city, $_state'),
          elevation: 0,
          backgroundColor: const Color(0xFF00853E),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.white,
            child: ListView(

              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF00853E),
                  ),
                  child: Center(
                    child: Text(
                      'Welcome ${widget.currUser.name}!',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    'Forum',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  ForumStart(currUser: currUser)),
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    'Calendar',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Calendar()),
                    ).then((value) => _loadFirestoreEvents());
                  },
                ),
                ListTile(
                  title: const Text(
                    'Map',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const navigation.UNTMap()),
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    'Police Report',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    _launchURL('https://police.unt.edu/reportcrime');
                  },
                ),
                ListTile(
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () async {
                    await authentication.FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FractionallySizedBox(
                  widthFactor: 1,
                  heightFactor: 0.95,
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:16.0),
                          child: Column(

                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tempFahrenheit != null)
                              Text(
                                '\n${tempFahrenheit?.toStringAsFixed(0)} °F',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40.0,
                                ),
                              ),
                              if (weatherDesc != null)
                                Text('$weatherDesc',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25.0,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        if(weatherDesc?.toLowerCase().contains('scattered clouds') ?? false)
                          Image.asset(
                            'assets/images/scattered_clouds.jpg',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        if(weatherDesc?.toLowerCase().contains('few clouds') ?? false)
                          Image.asset(
                            'assets/images/scattered_clouds.jpg',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        if(weatherDesc?.toLowerCase().contains('broken clouds') ?? false)
                          Image.asset(
                            'assets/images/scattered_clouds.jpg',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        if(weatherDesc?.toLowerCase().contains('overcast clouds') ?? false)
                          Image.asset(
                            'assets/images/overcast_clouds.jpg',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        if(weatherDesc?.toLowerCase().contains('clear sky') ?? false)
                          Image.asset(
                            'assets/images/clear_sky.png',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        if(weatherDesc?.toLowerCase().contains('snow') ?? false)
                          Image.asset(
                            'assets/images/snow.png',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        if(weatherDesc?.toLowerCase().contains('drizzle') ?? false)
                          Image.asset(
                            'assets/images/rain.jpg',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        if(weatherDesc?.toLowerCase().contains('rain') ?? false)
                          Image.asset(
                            'assets/images/rain.jpg',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        if(weatherDesc?.toLowerCase().contains('thunderstorm') ?? false)
                          Image.asset(
                            'assets/images/thunderstorm.jpg',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                      ],
                    ),
                  ),
                ),
              ),  //weather widget
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0), // adjust this value as per your needs
                    color: Colors.grey.shade400, // set the background color of the container
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                bottomLeft: Radius.circular(16.0),
                              ),
                              color: Colors.transparent, // set the background color of the container
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  Text(
                                    dates[0].substring(5,10),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  Text(
                                    temps[0] + " °F",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24.0,
                                    ),
                                  ),
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  SizedBox(
                                    height: 40, // set a fixed height for the description
                                    child: Text(
                                      descs[0],
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                              ],

                            ),
                          ),
                        ), //forecast day 1
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.transparent, // set the background color of the container
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  Text(
                                    dates[1].substring(5,10),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  Text(
                                    temps[1] + " °F",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24.0,
                                    ),
                                  ),
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  SizedBox(
                                    height: 40, // set a fixed height for the description
                                    child: Text(
                                      descs[1],
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ), //forecast day 2
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.transparent, // set the background color of the container
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  Text(
                                    dates[2].substring(5,10),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  Text(
                                    temps[2] + " °F",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24.0,
                                    ),
                                  ),
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  SizedBox(
                                    height: 40,
                                    child: Text(
                                      descs[2],
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ), //forecast day 3
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.transparent, // set the background color of the container
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  Text(
                                    dates[3].substring(5,10),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  Text(
                                    temps[3] + " °F",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24.0,
                                    ),
                                  ),
                                if (temps.isNotEmpty && descs.isNotEmpty && dates.isNotEmpty)
                                  SizedBox(
                                    height: 40,
                                    child: Text(
                                      descs[3],
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ), //forecast day 4

                      ],
                    ),
                  ),
                ),
              ),  //4 day forecast
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0), // adjust this value as per your needs
                    color: Colors.transparent, // set the background color of the container
                  ),
                  padding: const EdgeInsets.only(top:10),
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: 0.9,
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      // padding: const EdgeInsets.only(top:10),
                      child: TableCalendar(
                        onHeaderTapped: (_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Calendar()
                            )
                          ).then((value) => _loadFirestoreEvents());
                        },
                        focusedDay: _focusedDay,
                        firstDay: _firstDay,
                        lastDay: _lastDay,
                        calendarFormat: CalendarFormat.week,
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                        onDaySelected: (selectedDay, focusedDay) async {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          if (_events[selectedDay] != null) {
                            final result = await showDialog(
                              context: context, 
                              builder: (_) => AlertDialog(
                                title: const Text('Events for today'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ..._getEventForTheDay(selectedDay).map(
                                      (event) => ListTile(
                                        shape: const Border(
                                          left: BorderSide(
                                            color: Colors.green, 
                                            width: 5.0,
                                          ), 
                                          bottom: BorderSide(
                                            color: Colors.white,
                                            width: 5.0
                                          ),
                                          top: BorderSide(
                                            color: Colors.white,
                                            width: 5.0
                                          ),
                                        ),
                                        title: Text(event.title),
                                        subtitle: Text("${DateFormat.jm().format(event.from)}  -  ${DateFormat.jm().format(event.to)}"),
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context, 
                                            MaterialPageRoute(
                                              builder: (_) => ViewEvent(
                                                event: event
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
                                            // if(context.mounted) {
                                            //   Navigator.of(context).pop();
                                            // }
                                          }
                                          else if (result == false) {
                                            var snapshot = await FirebaseFirestore.instance.collection('events').where('recurrence_id', isEqualTo: event.recurrenceId).get(); //return list of docs matching condition
                                            for (var doc in snapshot.docs) { // get each document in list and delete from database
                                              await doc.reference.delete();
                                            }
                                          }
                                          if(context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                          _loadFirestoreEvents();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('View Calendar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('Close'),
                                  ),
                                ],
                              )
                            );
                            if (result ?? false) {
                              if(context.mounted){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Calendar()
                                  )
                                ).then((value) => _loadFirestoreEvents()); // load events after returning from Calendar page
                              }
                            }
                          }
                        },
                        calendarStyle: const CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF00853E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true
                        ),
                        // rowHeight: 150,
                        eventLoader: _getEventForTheDay,
                      ),
                     ),
                  ),
                ),
              ),  //filler for spacing (maybe class preview)
              Expanded(
                child: FractionallySizedBox(
                  widthFactor: 1,
                  heightFactor: 0.95,
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
              ),  //filler for spacing (maybe map preview)
            ],

          ),
        ),
      ),
    );
  }
}

Future<void> _launchURL(String url) async {
  if(await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Unable to launch $url';
  }
}
