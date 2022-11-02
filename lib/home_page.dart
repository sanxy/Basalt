import 'dart:async';
import 'dart:convert';
import 'package:basalt/model/stock.dart';
import 'package:basalt/service/dio_utils.dart';
import 'package:basalt/utils/general.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController editingController = TextEditingController();
  List<Data> parsedList = [];
  List<Data> _foundUsers = [];
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool active = true;
  bool isLoading = false;
  List<String> list = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    isLoading = true;
    loadApi();
  }

  // initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      jsonPrint('Couldn\'t check connectivity status: ${e.message}');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
      jsonPrint('Connection:: $result');
    });
    if (result == ConnectivityResult.none) {
      setState(() {
        //perform your action
        active = false;
      });
    } else if (result == ConnectivityResult.mobile) {
      setState(() {
        //perform your action
        active = true;
      });
    } else if (result == ConnectivityResult.wifi) {
      setState(() {
        //perform your action
        active = true;
      });
    }
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Data> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = parsedList;
    } else {
      results = parsedList
          .where((user) =>
              user.symbol!.toUpperCase().contains(enteredKeyword.toUpperCase()))
          .toList();
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Container(),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: const Icon(
                Icons.calendar_month,
                size: 40,
              ),
              tooltip: 'Date Range Picker',
              onPressed: () {
                pickDate();
              },
            ),
          ),
        ],
      ),
      body: !isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 30.0,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: EasyAutocomplete(
                      suggestions: list.toSet().toList(),
                      onChanged: (value) => _runFilter(value),
                      onSubmitted: (value) => _runFilter(value)),
                ),
                active == true
                    ? Expanded(
                        child: ListView.builder(
                            itemCount: _foundUsers.length,
                            itemBuilder: (BuildContext context, int index) {
                              var value = _foundUsers[index];
                              // jsonPrint('Value::: ${value.runtimeType}');
                              // jsonPrint('Books::: ${_foundUsers.runtimeType}');

                              return InkWell(
                                onTap: () {
                                  showModel(value, context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(value.exchange!,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900)),
                                          Text(value.symbol!,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(value.volume.toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700)),
                                          Text(value.open.toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      )
                    : const Center(
                        child: Text('No Active Internet',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                      )
              ],
            )
          : Center(child: const CircularProgressIndicator()),
    );
  }

  Future<void> loadApi() async {
    var dio = DioUtil.getInstance();

    final base = '${env('API')}';
    final key = '${env('APP_KEY')}';
    final symbols = '${env('SYMBOL')}';

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['userid'] = '25794905-2dd4-40bd-97b9-9d5d69294b86';
    dio.options.headers['token'] = 'd61036c6-5ffd-4964-b7ff-8d5ba8ca0262';

    //response will be assigned to response variable
    final response = await dio.get('$base$key&symbols=$symbols');

    int? statusCode = response.statusCode;
    print('statusCode: $statusCode');

    setState(() {
      isLoading = false;
    });

    if (statusCode == 200) {
      Map json = jsonDecode(response.toString());

      parsedList.clear();
      list.clear();
      setState(() {
        parsedList =
            (json["data"] as List).map((e) => Data.fromMap(e)).toList();
        _foundUsers = parsedList;
        for (var item in json["data"]) {
          // jsonPrint('item:: ${item['exchange']}');
          list.add(item['symbol']);
        }
      });

      jsonPrint('operator :::::: ${parsedList.runtimeType}');
    } else {
      jsonPrint('Error init::: ${response.toString()}');
    }
  }

  void showModel(Data value, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        var date = DateTime.parse(value.date.toString());
        var formattedDate = "${date.day}-${date.month}-${date.year}";

        return Wrap(
          children: [
            Container(
              height: 30.0,
            ),
            ListTile(
              title: Text('Statistics: ${value.exchange} (${value.symbol})',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ),
            ListTile(
              title: Text('Open'),
              trailing: Text(value.open.toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
            ListTile(
              title: Text('High'),
              trailing: Text(value.high.toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
            ListTile(
              title: Text('Low'),
              trailing: Text(value.low.toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
            ListTile(
              title: Text('Close'),
              trailing: Text(value.close.toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
            ListTile(
              title: Text('Volume'),
              trailing: Text(value.volume.toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
            ListTile(
              title: Text('Date'),
              trailing: Text(formattedDate,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
            Container(
              height: 30.0,
            )
          ],
        );
      },
    );
  }

  // Cancel subscription
  @override
  dispose() {
    super.dispose();

    _connectivitySubscription.cancel();
  }

  void pickDate() {
    showCustomDateRangePicker(
      context,
      dismissible: true,
      minimumDate: DateTime.now().subtract(const Duration(days: 60)),
      maximumDate: DateTime.now().add(const Duration(days: 30)),
      endDate: endDate,
      startDate: startDate,
      onApplyClick: (start, end) {
        setState(() {
          endDate = end;
          startDate = start;
          setState(() {
            isLoading = true;
          });
          dateRangeApiCall();
          // jsonPrint('Start::: ${DateFormat("yyyy-MM-dd").format(startDate!)}');
        });
      },
      onCancelClick: () {
        setState(() {
          endDate = null;
          startDate = null;
        });
      },
    );
  }

  Future<void> dateRangeApiCall() async {
    var dio = DioUtil.getInstance();

    final base = '${env('API')}';
    final key = '${env('APP_KEY')}';
    final symbols = '${env('SYMBOL')}';
    var start = DateFormat("yyyy-MM-dd").format(startDate!);
    var end = DateFormat("yyyy-MM-dd").format(endDate!);

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['userid'] = '25794905-2dd4-40bd-97b9-9d5d69294b86';
    dio.options.headers['token'] = 'd61036c6-5ffd-4964-b7ff-8d5ba8ca0262';

    //response will be assigned to response variable
    final response = await dio
        .get('$base$key&symbols=$symbols&date_from=${start}&date_to=${end}');

    int? statusCode = response.statusCode;
    print('statusCode: $statusCode');

    setState(() {
      isLoading = false;
    });

    if (statusCode == 200) {
      Map json = jsonDecode(response.toString());

      parsedList.clear();
      list.clear();
      setState(() {
        parsedList =
            (json["data"] as List).map((e) => Data.fromMap(e)).toList();
        _foundUsers = parsedList;
        for (var item in json["data"]) {
          // jsonPrint('item:: ${item['exchange']}');
          list.add(item['symbol']);
        }
      });

      jsonPrint('operator :::::: ${parsedList.runtimeType}');
    } else {
      jsonPrint('Error init::: ${response.toString()}');
    }
  }
}
