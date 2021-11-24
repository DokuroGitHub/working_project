import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:working_project/services/database_service.dart';
import 'constants/ui.dart';
import 'models/my_user.dart';
import 'theme_service.dart';
import 'themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:universal_io/io.dart';

import 'locale_service.dart';

const BoldStyle = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

class MyAppUnused extends StatelessWidget {
  // This widget is the root of your application.
  final bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeService().theme,
      //home: MyHomePage(title: 'Flutter Demo Home Page By DoKuRo'),

      initialRoute: '/',
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        switch (settings.name){
          case '/cloud_firestore':
            final mapArgs = args as Map<String, dynamic>;
            final title = mapArgs['title'] as String;
            return MaterialPageRoute<dynamic>(
              builder: (_) => CloudFireStoreScreen(title: title),
              settings: settings,
              fullscreenDialog: true,
            );
          default:
            return null;
        }
      },
      routes: {
        // When navigating to the "/" route, build the HomeScreen widget.
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page By DoKuRo'),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second_shjt': (context) =>
            const MyHomePage(title: 'Flutter Demo Home Page By DoKuRo 2nd'),
        '/google_map': (context) =>
            const GoogleMapDesu(title: 'FlutterExE: Google Map Page By DoKuRo'),
        '/rest_api': (context) =>
            MyRESTAPIScreen(title: 'FlutterExE: REST API Page By DoKuRo'),
        '/cloud_firestore': (context) =>
            const CloudFireStoreScreen(title: 'Product Navigation demo home page'),
        '/new_product': (context) =>
            const NewProductScreen(title: 'New product screen page'),
      },
    );
  }
}

var galleryItems = [
  'https://media.discordapp.net/attachments/781870218192355329/797082695678296114/ErCXxLbUUAEaJBN.png',
  'https://media.discordapp.net/attachments/781870218192355329/797804709850513418/137006842_5536314243060621_2134716370160209055_n.png',
  'https://media.discordapp.net/attachments/781870218192355329/798891179881529374/ErmFwCPXAAIHofL.png',
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _counter = 0;
  bool isSwitched = false;
  bool isSwitched2 = false;
  var textValue = 'Switch is OFF';
  late Animation<double> animation;
  late AnimationController animationController;
  static const platform = MethodChannel('samples.flutter.dev/battery');

  // Get battery level.
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int? result = await platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _openBrowser() async {
    if (Platform.isWindows | Platform.isLinux | Platform.isMacOS) {
      //import 'dart:js' as js;
      //js.context.callMethod('open', ['https://9gag.com']);
      return;
    }
    try {
      final int? result = await platform.invokeMethod<int>(
          'openBrowser', <String, String>{'url': "https://www.9gag.com"});
      print(result);
    } on PlatformException catch (e) {
      // Unable to open the browser
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _initAnimationShjt();
  }

  void _initAnimationShjt() {
    setState(() {
      animationController = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 5000));
      //animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
      animation =
          CurvedAnimation(parent: animationController, curve: Curves.bounceOut);
      animation.addListener(() {});
      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });
      animationController.stop();
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      //TODO: chi chay o page 3
      if (index != 2) {
        animationController.stop();
      } else {
        animationController.forward();
      }
      _selectedIndex = index;
    });
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Switch Button is ON';
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Switch Button is OFF';
      });
      print('Switch Button is OFF');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      //page 1
      SingleChildScrollView(child: Column(
        children: <Widget>[
          ConstrainedBox(constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width*0.8,
              maxHeight: MediaQuery.of(context).size.width*0.8
          ),
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(galleryItems[index]),
                  initialScale: PhotoViewComputedScale.contained * 0.8,
                );
              },
              itemCount: galleryItems.length,
              loadingBuilder: (context, event) => Center(
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: (event == null || event.expectedTotalBytes == null)
                        ? 0
                        : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(120.0),
              border: TableBorder.all(
                  color: Colors.black, style: BorderStyle.solid, width: 2),
              children: [
                TableRow(children: [
                  Column(children: const [
                    Text('Website', style: TextStyle(fontSize: 20.0))
                  ]),
                  Column(children: const [
                    Text('Tutorial', style: TextStyle(fontSize: 20.0))
                  ]),
                  Column(children: const [
                    Text('Review', style: TextStyle(fontSize: 20.0))
                  ]),
                ]),
                TableRow(children: [
                  Column(children: const [Text('Javatpoint')]),
                  Column(children: const [Text('Flutter')]),
                  Column(children: const [Text('4*')]),
                ]),
                TableRow(children: [
                  Column(children: const [Text('Javatpoint2')]),
                  Column(children: const [Text('MySQL')]),
                  Column(children: const [Text('3*')]),
                ]),
                TableRow(children: [
                  Column(children: const [Text('Javatpoint3')]),
                  Column(children: const [Text('ReactJS')]),
                  Column(children: const [Text('5*')]),
                ]),
              ],
            ),
          ),
          const Center(
              child: Text('People-Chart',
                  style:
                  TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
          DataTable(
            columns: const [
              DataColumn(
                  label: Text('ID',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Name',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Profession',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('1')),
                DataCell(Text('Stephen')),
                DataCell(Text('Actor')),
              ]),
              DataRow(cells: [
                DataCell(Text('5')),
                DataCell(Text('John')),
                DataCell(Text('Student')),
              ]),
              DataRow(cells: [
                DataCell(Text('10')),
                DataCell(Text('Harry')),
                DataCell(Text('Leader')),
              ]),
              DataRow(cells: [
                DataCell(Text('15')),
                DataCell(Text('Peter')),
                DataCell(Text('Scientist')),
              ]),
            ],
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                  child: const Text("GoogleMapScreen"),
                  onPressed: () => {
                    Navigator.pushNamed(context, "/google_map"),
                    print("went go GoogleMapScreen"),
                  },
                )),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                child: const Text('Open Browser'),
                onPressed: _openBrowser,
              ),
            ),
          ]),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    child: const Text("MyRESTAPIScreen"),
                    onPressed: () => {
                      Navigator.pushNamed(context, "/rest_api"),
                      print("went go MyRESTAPIScreen"),
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    child: const Text("CloudFireStoreScreen"),
                    onPressed: () => {
                      Navigator.pushNamed(context, "/cloud_firestore", arguments: {
                        'title': 'title ne'
                      }),
                      print("went to CloudFireStoreScreen"),
                    },
                  )),
            ],
          ),
        ],
      )),

      //page 2
      const CloudFireStoreScreen(title: 'cloud desuu'),
      //page 3
      SingleChildScrollView(child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: const EdgeInsets.all(5.0),
              child: const Text('Search Page',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
          AnimatedLogo(animation: animation),
          Container(margin: const EdgeInsets.all(5.0), child: const HeroAnimation()),
          Text('$_counter'),
          Transform.scale(
              scale: 2,
              child: Switch(
                onChanged: toggleSwitch,
                value: isSwitched,
                activeColor: Colors.blue,
                activeTrackColor: Colors.yellow,
                inactiveThumbColor: Colors.redAccent,
                inactiveTrackColor: Colors.orange,
              )),
          Text(textValue, style: const TextStyle(fontSize: 20)),
          Text(
            '$isSwitched2',
            style: const TextStyle(color: Colors.red, fontSize: 25.0),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              child: const Text('show dialog'),
              onPressed: () {
                showDialog<void>(context: context, builder: (_) => Tooltip(
                  message: 'Just a random image',
                  child: Image.network(
                    'https://media.discordapp.net/attachments/781870218192355329/799261615929032764/137587423_859626638205726_809530280543916073_n.png',
                    fit: BoxFit.fitWidth,
                  ),
                ));
                print("opened a dialog");
              },
            ),
          ]),
          ElevatedButton(
            child: const Text('Get Battery Level'),
            onPressed: _getBatteryLevel,
          ),
          Text(_batteryLevel),
        ],
      ),),

    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: ThemeService().switchTheme,
          ),
          PopupMenuButton<String>(
            onSelected: LocaleService().changeLocale,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'vi',
                  child: Text('Tiếng Việt',
                      style: TextStyle(
                          color: LocaleService().languageCode == 'vi'
                              ? Colors.red
                              : Colors.blue)),
                ),
                PopupMenuItem<String>(
                  value: 'en',
                  child: Text('English',
                      style: TextStyle(
                          color: LocaleService().languageCode == 'en'
                              ? Colors.red
                              : Colors.blue)),
                ),
                PopupMenuItem<String>(
                  value: 'es',
                  child: Text('Espanol',
                      style: TextStyle(
                          color: LocaleService().languageCode == 'es'
                              ? Colors.red
                              : Colors.blue)),
                ),
              ];
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              tooltip: "Home desu",
              label: 'Home',
              backgroundColor: Colors.green),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              tooltip: "Search desu",
              label: 'Search',
              backgroundColor: Colors.yellow),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            tooltip: "Profile desu",
            label: 'Profile',
            backgroundColor: Colors.blue,
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        backgroundColor: Colors.blue,
        iconSize: 30,
        onTap: _onItemTapped,
        elevation: 5,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class AnimatedLogo extends AnimatedWidget {
  final Tween<double> _sizeAnimation = Tween<double>(begin: 0.0, end: 5.0);

  AnimatedLogo({Key? key, required Animation animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    return Transform.scale(
      scale: _sizeAnimation.evaluate(animation),
      child: const FlutterLogo(),
    );
  }
}

class HeroAnimation extends StatefulWidget {

  const HeroAnimation({Key? key}) : super(key: key);

  @override
  _HeroAnimationState createState() => _HeroAnimationState();
}

class _HeroAnimationState extends State<HeroAnimation> {

  Widget _thumbnail() {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height* .2,
          maxWidth: MediaQuery.of(context).size.width * .2),
      child: Image.network(galleryItems[0]),
    );
  }

  Widget _detail() {
    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height*.8,
            maxWidth: MediaQuery.of(context).size.width),
        child: PhotoView(
          imageProvider: NetworkImage(galleryItems[0]),
        )
    );
  }

  void _gotoDetailsPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (ctx) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: GestureDetector(
                  child: Hero(
                    tag: 'hero-rectangle',
                    child: _detail(),
                  ),
                  onTap: () => {
                    print("backed to previous page"),
                    Navigator.pop(context),
                    //Navigator.pushNamed(context, "/second"),
                  },
                ),
              ),
              const Text(
                  'This is a place where you can see details about the icon tapped at previous page.'),
              Text(AppLocalizations.of(context)!.helloWorld),
            ],
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 30.0,
          ),
          ListTile(
            leading: GestureDetector(
              child: Hero(
                tag: 'hero-rectangle',
                child: _thumbnail(),
              ),
              onTap: () => {
                print("went to hero view"),
                _gotoDetailsPage(context),
              },
            ),
            title: const Text(
                'Tap on the green icon rectangle to analyse hero animation transition.'),
          ),
        ],
      ),
    );
  }

}

//GoogleMapDesu
class GoogleMapDesu extends StatefulWidget {
  const GoogleMapDesu({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _GoogleMapState createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMapDesu> {
  late GoogleMapController myController;
  static const LatLng _center =
  LatLng(12.999031583529439, 109.24286840051656);
  LatLng _currentMapPosition = _center;
  final Set<Marker> _markers = {};
  MapType _currentMapType = MapType.satellite;

  void _onMapCreated(GoogleMapController controller) {
    myController = controller;
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onCameraMove(CameraPosition position) {
    _currentMapPosition = position.target;
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(_currentMapPosition.toString()),
        position: _currentMapPosition,
        infoWindow:
        const InfoWindow(title: 'Nice Place', snippet: 'Welcome to Đông Lào'),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.green,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: _center,
                  zoom: 18.0,
                ),
                mapType: _currentMapType,
                markers: _markers,
                onCameraMove: _onCameraMove),
            //getting back button
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: FloatingActionButton(
                  onPressed: () {
                    print('getting back from GoogleMapScreen');
                    Navigator.pop(context);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.arrow_back, size: 30.0),
                ),
              ),
            ),
            //change map type button
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  onPressed: () {
                    _onMapTypeButtonPressed();
                    print('change to: $_currentMapType');
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.map, size: 30.0),
                ),
              ),
            ),
            //add markers button
            Padding(
              padding: const EdgeInsets.only(top: 80.0, right: 14.0),
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  onPressed: _onAddMarkerButtonPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.location_pin, size: 30.0),
                ),
              ),
            ),
            //hello world
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(AppLocalizations.of(context)?.helloWorld??''),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///MyRESTAPIScreen
class MyRESTAPIScreen extends StatefulWidget {
  const MyRESTAPIScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyRESTAPIState createState() => _MyRESTAPIState();
}

class _MyRESTAPIState extends State<MyRESTAPIScreen> {
  late Future<Post> post;

  @override
  void initState() {
    super.initState();
    post = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter REST API Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: FutureBuilder<Post>(
            future: post,
            builder: (_context, _builder) {
              if (_builder.hasData) {
                return Center(
                  child: Column(
                    children: <Widget>[
                      const Center(
                          child: Text(
                              'https://jsonplaceholder.typicode.com/posts/1',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold))),
                      DataTable(
                        columnSpacing: 5.0,
                        dataRowHeight: 100.0,
                        columns: const [
                          DataColumn(
                              label: Text('userId',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('id',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('title',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('body',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold))),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text(_builder.data!.userId.toString())),
                            DataCell(Text(_builder.data!.id.toString())),
                            DataCell(
                                SizedBox(
                                    width: 120.0,
                                    child: Text(_builder.data!.title)),
                                onTap: () {
                                  print(_builder.data!.title + '\n........');
                                }),
                            DataCell(Text(_builder.data!.body),
                                onTap: () {
                                  print(_builder.data!.body + '\n........');
                                }),
                          ]),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child:
                            Text(AppLocalizations.of(context)!.helloWorld),
                          )),
                    ],
                  ),
                );
              } else if (_builder.hasError) {
                return Text("${_builder.error}");
              }

              // By default, it show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("backed to previous page");
            Navigator.pop(context);
          },
          tooltip: 'Back',
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}

Future<Post> fetchPost() async {
  var url = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
  final response = await http.get(url);

  print("response.statusCode: " + response.statusCode.toString());
  if (response.statusCode == 200) {
    // If the call to the server was successful (returns OK), parse the JSON.
    print("response.body: " + response.body);
    return Post.fromJson(json.decode(response.body) as Map<String, dynamic>);
  } else {
    // If that call was not successful (response was unexpected), it throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({required this.userId, required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

///end of MyRESTAPIScreen

//TODO: MyRESTAPIScreen
class CloudFireStoreScreen extends StatefulWidget {
  const CloudFireStoreScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _CloudFireStoreScreenState createState() => _CloudFireStoreScreenState();
}

class _CloudFireStoreScreenState extends State<CloudFireStoreScreen> {

  @override
  Widget build(BuildContext context) {
    return _buildHome(context);
  }

  //TODO: _buildHome
  Widget _buildHome(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MyUsers")),
      body: Column(children: [
        StreamBuilder(
            stream: DatabaseService().getStreamListMyUser(),
            builder:
                (BuildContext context, AsyncSnapshot<List<MyUser>> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }
              if (!snapshot.hasData) return const LinearProgressIndicator();

              //TODO: _buildList
              return _buildList(context, snapshot.data!);
            }),
        const Text("xD"),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addProduct();
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //TODO: _addProduct
  void _addProduct() {
    AddProductAlertDialogWidget dialogWidget = AddProductAlertDialogWidget();
    showDialog<void>(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
              title: const Text("Add"),
              content: dialogWidget,
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(_context).pop();
                    },
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                    },
                    child: const Text("Add")),
              ]);
        });
  }

  //TODO: _deleteProduct
  void _deleteProduct(String id) {
    showDialog<void>(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
              title: const Text("Delete"),
              content: const Text("Ask again... Delete this?"),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(_context).pop();
                    },
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(_context).pop();
                    },
                    child: const Text("Yes")),
              ]);
        });
  }

  //TODO: _buildList
  Widget _buildList(BuildContext context, List<MyUser> snapshot) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 20.0),
      //TODO: lặp _buildListItem
      children: snapshot.map((myUser) => _buildListItem(context, myUser)).toList(),
    );
  }

  //TODO: _buildListItem
  Widget _buildListItem(BuildContext context, MyUser myUser) {
    return GestureDetector(child: ListTile(
    leading: Image.network(
    myUser.photoURL?? '',
    fit: BoxFit.fitHeight,
    ),
    title: Text(myUser.name ?? "null"),
    subtitle: Text(myUser.selfIntroduction ?? "null"),
    trailing: Text(myUser.phoneNumber??'',
    //TODO: onTap, view productDetails
    ),
      onTap: () {
        //TODO: cần sửa Navigation.pushName
        _navigate(BuildContext _context) {
          Navigator.push(
              _context,
              MaterialPageRoute<void>(
                builder: (_context) => ProductDetails(myUser),
              ));
        }

        _navigate(context);
      },

      //TODO: onLongPress, showDialog, delete item
      onLongPress: () {
        showDialog<void>(
            context: context,
            builder: (_context) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //TODO: Are you sure deleting this item?
                    const Text("Are you sure deleting this item?"),
                    Row(children: [
                      MaterialButton(
                        color: Colors.white70,
                        child: const Text('Yes'),
                        onPressed: () {
                          //TODO: deleteProduct
                          Navigator.of(_context).pop();
                          print("closed AlertDialog, open another dialog");
                        },
                      ),
                      MaterialButton(
                        color: Colors.white70,
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(_context).pop();
                          _deleteProduct('nope');
                          print("Canceled and closed AlertDialog");
                        },
                      ),
                    ]),
                  ],
                ),
                elevation: 12,
              );
            });
        print("opened a dialog");
      },
    ));
  }
}

typedef DialogCallback = void Function();

class ProductDetails extends StatelessWidget {
  final MyUser product;

  const ProductDetails(this.product);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.name??''),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                //TODO: get back
                Navigator.pop(context);
              }),
        ),
        body: MyUserDetailForm(product),
      ),
    );
  }
}

class MyUserDetailForm extends StatefulWidget {
  final MyUser myUser;

  const MyUserDetailForm(this.myUser);

  @override
  _MyUserDetailFormState createState() => _MyUserDetailFormState();
}

class _MyUserDetailFormState extends State<MyUserDetailForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final dateFormat = DateFormat('yyyy-MM-dd');
  late String? name;
  late String? description;
  late String? price;
  late String? image;

  @override
  void initState() {
    name = widget.myUser.name;
    description= widget.myUser.selfIntroduction;
    price = widget.myUser.phoneNumber;
    image = widget.myUser.photoURL;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20.0),

            //TODO: FormBuilderTextField, name
            FormBuilderTextField(
              name: "name",
              initialValue: name??"",
              decoration: textInputDecoration.copyWith(
                  hintText: 'Name hint', labelText: "Name"),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.minLength(context, 1),
                FormBuilderValidators.required(context)
              ]),
              onChanged: (val) {
                setState(() => name = val!);
              },
            ),

            //TODO: FormBuilderTextField, description
            FormBuilderTextField(
              name: "description",
              initialValue: description??"",
              decoration: textInputDecoration.copyWith(
                  hintText: 'description hint', labelText: "description label"),
              onChanged: (val) {
                setState(() {
                  description = val!;
                });
              },
            ),

            //TODO: FormBuilderTextField, price
            FormBuilderTextField(
              name: "price",
              initialValue: price==null?"":price.toString(),
              decoration: textInputDecoration.copyWith(
                  hintText: 'price hint', labelText: "price label"),
              onChanged: (val) {
                setState(() {
                  if(int.tryParse(val!) != null) {
                    price = val;
                  }
                });
              },
            ),

            //TODO: FormBuilderRadioGroup, image
            FormBuilderRadioGroup(
              decoration: const InputDecoration(labelText: 'Pick image'),
              name: "image",
              initialValue: image.toString(),
              //leadingInput: true,
              options: const [
                FormBuilderFieldOption(
                    value: "floppydisk.jpg",
                    child: Text(
                      "floppydisk.jpg",
                      style: TextStyle(fontSize: 16.0),
                    )),
                FormBuilderFieldOption(
                    value: "iphone.jpg",
                    child: Text(
                      "iphone.jpg",
                      style: TextStyle(fontSize: 16.0),
                    )),
                FormBuilderFieldOption(
                    value: "laptop.jpg",
                    child: Text(
                      "laptop.jpg",
                      style: TextStyle(fontSize: 16.0),
                    )),
                FormBuilderFieldOption(
                    value: "pendrive.jpg",
                    child: Text(
                      "pendrive.jpg",
                      style: TextStyle(fontSize: 16.0),
                    )),
                FormBuilderFieldOption(
                    value: "pixel.jpg",
                    child: Text(
                      "pixel.jpg",
                      style: TextStyle(fontSize: 16.0),
                    )),
                FormBuilderFieldOption(
                    value: "tablet.jpg",
                    child: Text(
                      "tablet.jpg",
                      style: TextStyle(fontSize: 16.0),
                    )),
              ],
              onChanged: (newValue){
                setState(() {
                  image = newValue.toString();
                });
              },
            ),

            const SizedBox(height: 20.0),

            //TODO: Row, Cancel/Update
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                    color: Colors.blue.shade600,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    )),
                MaterialButton(
                    color: Colors.blue.shade600,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                          //TODO: cap nhat lai info cua product
                          widget.myUser.name = name;
                          widget.myUser.selfIntroduction = description;
                          widget.myUser.phoneNumber = price;
                          widget.myUser.photoURL = image;

                        }
                      }
                    },
                    child: const Text(
                      "Update",
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

}


class NewProductScreen extends StatefulWidget {
  const NewProductScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  late TextEditingController _controller4;
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late TextEditingController _controller3;
  late String name = '';
  late String image = '';
  late String description = '';
  late String price = '';

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();
    _controller3 = TextEditingController();
    _controller4 = TextEditingController();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference products =
    FirebaseFirestore.instance.collection('product');

    Future<void> addProduct() {
      // Call the user's CollectionReference to add a new user
      print("name:" + name);
      print("description" + description);
      print("price" + price.toString());
      print("image" + image);
      return products.add({
        'name': name,
        'description': description,
        'price': price,
        'image': image
      }).then((value) {
        print("Product Added Successfully");
        final snackBar = SnackBar(
          content: const Text('Product Added Successfully !'),
          action: SnackBarAction(
            label: 'Ok',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((dynamic error) => print("Failed to add user: $error"));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: SizedBox(
          width: 300.0,
          child: Column(children: [
            Row(children: [
              const SizedBox(width: 80.0, child: Text("Name:")),
              SizedBox(
                width: 200.0,
                child: TextField(
                  controller: _controller1,
                  onChanged: (String value) {
                    name = value;
                  },
                ),
              ),
            ]),
            Row(children: [
              const SizedBox(width: 80.0, child: Text("Description:")),
              SizedBox(
                width: 200.0,
                child: TextField(
                  controller: _controller2,
                  onChanged: (String value) {
                    description = value;
                  },
                ),
              ),
            ]),
            Row(children: [
              const SizedBox(width: 80.0, child: Text("Price:")),
              SizedBox(
                width: 200.0,
                child: TextField(
                  controller: _controller3,
                  onChanged: (String value) {
                    price = value;
                  },
                ),
              ),
            ]),
            Row(children: [
              const SizedBox(width: 80.0, child: Text("Image:")),
              SizedBox(
                width: 200.0,
                child: TextField(
                  controller: _controller4,
                  onChanged: (String value) {
                    image = value;
                  },
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.green),
                ),
                onPressed: () {
                  if (name == '' ||
                      description == '' ||
                      image == '' ||
                      price == '') {
                    print("Can not add null value(s)");
                    final snackBar = SnackBar(
                      content: const Text('Can not add null value(s)!'),
                      action: SnackBarAction(
                        label: 'Ok',
                        onPressed: () {
                          // Some code to undo the change.
                        },
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    addProduct();
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Add Product",
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

//TODO: AlertDialogWidget, addProduct
class AddProductAlertDialogWidget extends StatefulWidget {
  late String productName;
  late String image;

  @override
  _AddProductAlertDialogWidgetState createState() =>
      _AddProductAlertDialogWidgetState();
}

class _AddProductAlertDialogWidgetState
    extends State<AddProductAlertDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          //TODO: productName
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: "Enter a product Name"),
            onChanged: (text) => widget.productName = text,
          ),
          //TODO: image
          RadioListTile<String>(
            title: const Text("floppydisk.jpg"),
            value: 'floppydisk.jpg',
            groupValue: widget.image,
            onChanged: (value) {
              setState(() {
                widget.image = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text("iphone.jpg"),
            value: "iphone.jpg",
            groupValue: widget.image,
            onChanged: (value) {
              setState(() {
                widget.image = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text("laptop.jpg"),
            value: "laptop.jpg",
            groupValue: widget.image,
            onChanged: (value) {
              setState(() {
                widget.image = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text("pendrive.jpg"),
            value: "pendrive.jpg",
            groupValue: widget.image,
            onChanged: (value) {
              setState(() {
                widget.image = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text("pixel.jpg"),
            value: "pixel.jpg",
            groupValue: widget.image,
            onChanged: (value) {
              setState(() {
                widget.image = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text("tablet.jpg"),
            value: "tablet.jpg",
            groupValue: widget.image,
            onChanged: (value) {
              setState(() {
                widget.image = value!;
              });
            },
          )
        ],
      ),
    );
  }
}
