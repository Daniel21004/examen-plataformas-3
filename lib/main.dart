import 'package:exam/loginPage.dart';
import 'package:exam/models/Response.dart';
import 'package:exam/services/httpServices.dart';
import 'package:exam/utils/secureStorage.dart';
import 'package:exam/utils/toast.dart';
import 'package:exam/views/registerPage.dart';
import 'package:flutter/material.dart';
import 'package:exam/views/mapPage.dart';
import 'package:exam/views/page404.dart';

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
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const LoginPage(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => MyHomePage(title: 'Flutter Demo Home Page'),
        // '/map': (context) {
        //   final Map<String, dynamic>? args = ModalRoute.of(context)
        //       ?.settings
        //       .arguments as Map<String, dynamic>?;
        //   return MapPage(
        //     sitios: args?['sitios'] ?? [],
        //   );
        // },
         '/map': (context) => MapPage(),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => Page404());
      },
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
  Future<Response>? futureSitios;

  // ! Caparazon para el response
  Response res = Response(msg: '', code: 100);

  String rol = '';
  int _counter = 0;
  dynamic sitios = [];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();

    iniciarCargaDatos();
  }

  void iniciarCargaDatos() async {
    var sitiosFuture = obtener('api/listado/nro_guia', false);
    // var externalUser = await SecureStorage.read('external_user');
    // externalUser = (await SecureStorage.read(
    //     'external_user'))!; //! Asegura que NUNCA se obtendra un null

    // rol = (await SecureStorage.read(
    // 'rol'))!; //! Asegura que NUNCA se obtendra un null
    // print('ext $externalUser');
    // print('rol $rol');

    setState(() {
      futureSitios = sitiosFuture;
    });

    futureSitios?.then((datos) {
      print('Datos del futureSitios: $datos');
      print('sitios: ${datos.sitios}');
      if (datos.code == 200) {
        sitios = datos.sitios;

        ToastUtil.successfullMessage('sitios cargadas correctamente');
      } else {
        ToastUtil.errorMessage(datos.tag);
      }
    }).catchError((error) {
      print('Error al recibir los datos del futureSitios: $error');
      ToastUtil.errorMessage(
          'Ocurrió un error al intentar recuperar los sitos');
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: GestureDetector(
          onTap: () {
            // Aquí puedes mostrar el menú cuando se hace clic en el texto
            showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                    0, AppBar().preferredSize.height, 0, 0),
                items: [
                  // if (rol == Constants.USUARIO_ROL)
                  const PopupMenuItem(value: 'map', child: Text('Ir al mapa')),
                  const PopupMenuItem(
                      value: 'cerrar_sesion', child: Text('Cerrar sesion')),
                ]).then((value) {
              if (value == 'actualizar') {
                // todo xd
              } else if (value == 'cerrar_sesion') {
                SecureStorage.delete('token');
                SecureStorage.delete('external_user');
                Navigator.pushNamed(context, '/login');
              } else if (value == 'map') {
                Navigator.pushNamed(
                  context,
                  '/map',
                  arguments: {
                    'sitios': sitios,
                  },
                );
                print('holaaa');
              }
            });
          },
          child: Text('Bienvenido',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
