// import 'dart:js_util';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC',
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'NFC Tools'),
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
  ValueNotifier<dynamic> result = ValueNotifier(null);
  readingFun() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reading Tag'),
        content: const Text('Read function'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      print('NFC data result $tag.data');
      NfcManager.instance.stopSession();
    });
  }
  void _ndefWrite() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText('Hello World!'),
        NdefRecord.createUri(Uri.parse('https://flutter.dev')),
        NdefRecord.createMime(
            'text/plain', Uint8List.fromList('Hello'.codeUnits)),
        NdefRecord.createExternal(
            'com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
      ]);

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }
  Future<void> checkNFC() async {
    // Check availability
    bool isAvailable = await NfcManager.instance.isAvailable();
    print('Is NFC available = $isAvailable');

    if(isAvailable) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // Do something with an NfcTag instance.
          print('Is NFC disovered');
          _tagRead();
        },
      );
    }else{
      print('Is NFC not available');
    }
  }

  // This method is rerun every time setState is called, for instance as done
  // by the _incrementCounter method above.

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        leading: const Icon(Icons.settings),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(60.20),
              child: Text(
                'Welcome to NFC Tools',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Container(
              width: 250.0,
              height: 250.0,
              padding: const EdgeInsets.all(60.20),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/nfc.png'),
                    fit: BoxFit.fill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.10),
              child: SizedBox(
                height: 50, //height of button
                width: 300, //width of button
                // padding: const EdgeInsets.all(60.20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    checkNFC();
                  },
                  icon: const Icon(
                    // <-- Icon
                    Icons.search,
                    size: 30.0,
                  ),
                  label: const Text('Read'), // <-- Text
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.10),
              child: SizedBox(
                height: 50, //height of button
                width: 300, //width of button
                // padding: const EdgeInsets.all(60.20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _ndefWrite();
                  },
                  icon: const Icon(
                    // <-- Icon
                    Icons.save_as,
                    size: 30.0,
                  ),
                  label: const Text('Write'), // <-- Text
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.10),
              child: SizedBox(
                height: 50, //height of button
                width: 300, //width of button
                // padding: const EdgeInsets.all(60.20),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    // <-- Icon
                    Icons.more,
                    size: 30.0,
                  ),
                  label: const Text('Others'), // <-- Text
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.10),
              child: SizedBox(
                height: 50, //height of button
                width: 300, //width of button
                // padding: const EdgeInsets.all(60.20),
                child: ElevatedButton.icon(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('AlertDialog Title'),
                      content: const Text('AlertDialog description'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(
                    // <-- Icon
                    Icons.save,
                    size: 30.0,
                  ),
                  label: const Text('My saved tags'), // <-- Text
                ),
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
