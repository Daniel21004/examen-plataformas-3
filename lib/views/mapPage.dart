import 'package:exam/models/Response.dart';
import 'package:exam/services/httpServices.dart';
import 'package:exam/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    Key? key,
  }) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Future<Response>? futureSitios;

  dynamic sitios = [];

  @override
  void initState() {
    super.initState();

    iniciarCargaDatos();
  }

  void iniciarCargaDatos() async {
    var sitiosFuture = obtener('api/listado/nro_guia', false);

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
    return FutureBuilder<dynamic>(
      future: futureSitios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.sitios == null) {
          return Text('No hay datos disponibles.');
        }

        // var listNoticias = snapshot.data!.sitios;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: GestureDetector(
              onTap: () {
                // Aquí puedes mostrar el menú cuando se hace clic en el texto
                showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                        0, AppBar().preferredSize.height, 0, 0),
                    items: [
                      const PopupMenuItem(
                          value: 'cerrar_sesion', child: Text('Cerrar sesion')),
                    ]).then((value) {
                  if (value == 'cerrar_sesion') {
                    Navigator.pushNamed(context, '/login');
                  }
                });
              },
              child: Text('Mapa',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          body: FlutterMap(
            options: MapOptions(
              center:
                  LatLng(-3.994659, -79.208287), // Ubicación inicial del mapa
              zoom: 13.0, // Nivel de zoom inicial
            ),
            nonRotatedChildren: [
              AttributionWidget.defaultWidget(
                  source: 'OpenStreetMap contributers', onSourceTapped: null)
            ],
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                // markers: widget.sitios.map<Marker>((sitio) {
                markers: sitios.map<Marker>((sitio) {
                  print('comentarioooooo $sitio');
                  return Marker(
                    point: new LatLng(double.parse(sitio['latitud']),
                        double.parse(sitio['longitud'])),
                    width: 100.0,
                    height: 80.0,
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                        showDialog(
                          context: ctx,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Información del comentario'),
                              content: Text(
                                  'Tema ${sitio['tema']}\nAutor: ${sitio['autor']}'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cerrar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        );
      },
    );
  }
}
