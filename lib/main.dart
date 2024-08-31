import 'package:flutter/material.dart';
import 'package:interpret/translations.dart';
import 'package:interpret/video.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'INTERPRET'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void onClick(String text, context) {
    setState(() {
      videoGifs = theTranslator(text, allowedTranslate);
    });
    Navigator.pop(context);
  }

  void saveTranslation() {
    setState(() {
      String writtenText = _textController.text;
      videoGifs = theTranslator(translation, allowedTranslate);
      translateList.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Container(
              height: MediaQuery.of(context).size.height / 10,
              width: MediaQuery.of(context).size.width - 10,
              color: Colors.blueAccent,
              alignment: Alignment.center,
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  onClick(writtenText, context);
                },
                child: Text(translation),
              ))));
      _textController.clear();
    });
  }

  List<Padding> theTranslator(String theTranslation, bool allowedTranslate) {
    List<String> wordlist = theTranslation.split(" ");
    List<Padding> textList = <Padding>[];
    if (!allowedTranslate) {
      return const <Padding>[
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Text("Loading"))
      ];
    }
    for (String word in wordlist) {
      textList.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: FutureBuilder(
          future: returnSearch(word),
          builder: (context, worddata) {
            if (worddata.data != null) {
              VideoPlayerController _controller = VideoPlayerController.network(
                  worddata.data!,
                  videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
              controllerList.add(_controller);
              Future<void> _initializeVideoPlayerFuture =
                  _controller.initialize();
              _controller.setLooping(true);
              return FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    _controller.play();
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      // Use the VideoPlayer widget to display the video.
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    // If the VideoPlayerController is still initializing, show a
                    // loading spinner.
                    return Container(
                        height: 60,
                        child: Center(child: CircularProgressIndicator()));
                  }
                },
              );
            } else {
              return Container(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()));
            }
          },
        ),
      ));
    }
    return textList;
  }

  void killVideos() {
    videoGifs = [];
    for (VideoPlayerController controller in controllerList) {
      controller.dispose();
    }
  }

  final _textController = TextEditingController();
  String translation = "";
  bool allowedTranslate = false;
  List<Padding> videoGifs = <Padding>[];
  List<VideoPlayerController> controllerList = <VideoPlayerController>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("INTERPRET"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            tooltip: 'SAVED TRANSLATIONS',
            onPressed: () {
              killVideos();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SavedTranslationScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: 'Video Translation',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VideoScreen()));
            },
          ),
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: Container(
                color: const Color.fromARGB(255, 127, 134, 123),
                child: Center(
                  child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Material(
                            color: Color.fromARGB(255, 127, 134, 123),
                            child: Text(
                              "Enter your text below:",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 25),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            child: Material(
                              child: TextFormField(
                                controller: _textController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Click Here!',
                                ),
                                validator: ((value) {
                                  if (value!.isEmpty) {
                                    return "Enter correct name";
                                  } else {
                                    return null;
                                  }
                                }),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.language),
                            tooltip: 'Translate!',
                            iconSize: 50,
                            onPressed: () {
                              translation = _textController.text;
                              allowedTranslate = true;
                              saveTranslation();
                            },
                          ),
                        ],
                      )),
                ))),
        Expanded(
            child: Container(
          color: const Color.fromARGB(255, 175, 159, 140),
          child: Center(
            child: ListView(children: videoGifs),
          ),
        )),
      ]),
    );
  }
}

Future<String> returnSearch(String word) async {
  final response = await http.Client()
      .get(Uri.parse('https://www.signasl.org/sign/' + word));
  String videourl = "";
  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    var videolink =
        document.getElementsByClassName('col-md-12')[0].children[2].outerHtml;
    videourl = getMp4Link(videolink);
  }
  return videourl;
}

String getMp4Link(String html) {
  // Use a regular expression to search for a link that ends with ".mp4"
  final mp4Regex = RegExp(r'https?://\S*\.mp4');
  final match = mp4Regex.firstMatch(html);

  // Return the match if found, otherwise return an empty string
  return match != null ? match.group(0)! : '';
}
