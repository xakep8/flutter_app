import "dart:async";
import "dart:convert";
import "dart:js_util";
import "package:app/data/Model/search_model.dart";
import "package:intl/intl.dart";
import 'package:intl/intl_browser.dart';
import "package:app/data/Model/data_model.dart";
import "package:flutter/foundation.dart";
import 'package:http/http.dart' as http;
import "package:flutter/material.dart";

class HomeScreen extends StatefulWidget {
  final String cityName;

  const HomeScreen({Key? key, required this.cityName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  var _isCount = 0;
  WeatherData dataFromAPI = new WeatherData();
  SearchData searchModel = new SearchData();

  _getData() async {
    String search_url =
        "https://geocoding-api.open-meteo.com/v1/search?name=${widget.cityName}";
    http.Response search = await http.get(Uri.parse(search_url));
    searchModel = SearchData.fromJson(jsonDecode(search.body));
    double? latitude = searchModel.results![0].latitude!;
    double? longitude = searchModel.results![0].longitude!;
    String url =
        "https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&hourly=temperature_2m";
    http.Response res = await http.get(Uri.parse(url));
    // debugPrint(search.body);
    dataFromAPI = WeatherData.fromJson(json.decode(res.body));
    setState(() {
      _isLoading = false;
    });
    // debugPrint(res.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cityName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (context, index) {
                DateTime temp =
                    DateTime.parse(dataFromAPI.hourly!.time![index]);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd-MM-yyyy HH:MM a')
                          .format(temp)
                          .toString()),
                      Text('${dataFromAPI.hourly!.temperature2m![index]}'),
                    ],
                  ),
                );
              },
              itemCount: dataFromAPI.hourly!.time!.length,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isCount++;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
