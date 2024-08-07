import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=23b822af";


void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
    ) ,
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();


  late double dolar;
  late double euro;

  void _realChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text =(real/euro).toStringAsFixed(2);
  }
  void _dolarChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar*this.dolar).toStringAsFixed(2);
    euroController.text =(dolar * this.dolar/euro).toStringAsFixed(2);

  }
  void _euroChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text =(euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro/dolar).toStringAsFixed(2);

  }

  final FocusNode realFocusNode = FocusNode();
  final FocusNode dolarFocusNode = FocusNode();
  final FocusNode euroFocusNode = FocusNode();

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }
  void _resetFields() {
    realController.clear();
    dolarController.clear();
    euroController.clear();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            "\$Conversor de Moedas\$",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.amber,
          actions: [
            IconButton(
              onPressed: _resetFields,
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
          ],
        ),

        body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
    },
    child: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao Carregar Dados:(",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar =
                snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro =
                snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                return  SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.monetization_on, size: 150,
                          color: Colors.amber),
                      buildTextFiel("Reais", "R\$", realController,_realChanged,realFocusNode),
                      const Divider(),
                      buildTextFiel("Dólares", "U\$",dolarController,_dolarChanged,dolarFocusNode),
                      const Divider(),
                      buildTextFiel("Euros", "€",euroController,_euroChanged,euroFocusNode),
                    ],
                  ),
                );
              }
          }
        })),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

Widget buildTextFiel(String label, String prefix, TextEditingController c, void Function(String) f, FocusNode focusNode){
  return TextField(
    controller: c,
    focusNode: focusNode,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.amber,
              width: 2.0,
            )
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.amber,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.red,
                width: 2.0
            )
        ),
        prefixText: prefix,
    ),
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}