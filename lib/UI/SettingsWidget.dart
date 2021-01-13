import 'package:flutter/material.dart';
import 'package:money_tracker/Utilitis/Colors.dart';
import 'package:money_tracker/Utilitis/CurrencyInfo.dart';
import 'package:money_tracker/UI/SubscriptionListWidget.dart';
import 'package:money_tracker/UI/EditSubscriptionWidget.dart';
import 'package:money_tracker/database_helpers.dart';
import 'package:money_tracker/model/SubscriptionEntry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final List<SubscriptionEntry> subscriptions;
  final Map<String, String> stringData;

  final Map<String, num> numData;
  SettingsWidget({Key key, this.numData, this.subscriptions, this.stringData})
      : super(key: key);

  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<SettingsWidget> {
  String currentDaily, monthlyReset, currency;
  bool showSaveButton, showEntireHistory;

  @override
  void initState() {
    super.initState();
    currency = widget.stringData["currency"];
    currentDaily = widget.numData["dailyLimit"].toString();
    showSaveButton = widget.numData["showSave"] == 1;
    showEntireHistory = widget.numData["historyMode"] == 1;
  }

  bool isDate(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null && int.parse(s) < 32 && int.parse(s) > 0;
  }

  bool isInt(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return num.tryParse(s) != null;
  }

  void _openEditSubscription(BuildContext ctx) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditSubscriptionWidget(
            mode: "",
            item: null,
            ctx: ctx,
            currency: widget.stringData["currency"],
          ),
        ));
    // Save any  Subscriptions
    if (result != null) {
      widget.subscriptions.add(result);
      setState(() {
        _saveSubscription(result);
        FocusScope.of(context).unfocus();
      });
    }
  }

  Future<void> _showMyDialog(String Value, BuildContext ctx) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Changing the currency will clear all data and restart. Please back up your data if you need to.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Confirm'),
              onPressed: () {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text('Data will be cleared on Save'),
                  duration: Duration(seconds: 5),
                ));
                setState(() {
                  currency = Value;
                });
                FocusScope.of(context).unfocus();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openSubscriptionList() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubscriptionListWidget(
            subscriptions: widget.subscriptions,
            currency: widget.stringData["currency"],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, false);
          return true;
        },
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
                appBar: AppBar(
                  title: Text("Settings"),
                ),
                body: Builder(
                    builder: (context) => SingleChildScrollView(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // System Values
                            Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                child: Text(
                                  "System Values",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                )),
                            Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                margin: EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                        title: Row(
                                      children: <Widget>[
                                        Text("Current daily limit"),
                                        Spacer(),
                                        Text("$currentDaily")
                                      ],
                                    )),
                                    ListTile(
                                        title: Row(
                                      children: <Widget>[
                                        Flexible(
                                            child: TextField(
                                          controller: widget.amountController,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Change Daily Limit',
                                          ),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          textAlign: TextAlign.end,
                                        ))
                                      ],
                                    )),
                                    ListTile(
                                        title: Row(
                                      children: <Widget>[
                                        Text("Currency"),
                                        Spacer(),
                                        DropdownButton<String>(
                                          value: currency,
                                          iconSize: 24,
                                          elevation: 16,
                                          underline: Container(
                                            height: 2,
                                          ),
                                          onChanged: (String Value) {
                                            if (Value != currency) {
                                              _showMyDialog(Value, context);
                                            }
                                          },
                                          items: CurrencyInfo()
                                              .currencyList()
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        )
                                      ],
                                    ))
                                  ],
                                )),
                            // System UI
                            Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                child: Text(
                                  "System UI",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                )),
                            Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                margin: EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                        title: Row(
                                      children: <Widget>[
                                        Text("Show Save Button"),
                                        Spacer(),
                                        Switch(
                                          value: showSaveButton,
                                          onChanged: (value) {
                                            setState(() {
                                              showSaveButton = value;
                                            });
                                          },
                                          activeTrackColor: mainGoaldColor,
                                          activeColor: mainGoaldColor,
                                        ),
                                      ],
                                    )),
                                    ListTile(
                                        title: Row(
                                      children: <Widget>[
                                        Text("Show Entire History"),
                                        Spacer(),
                                        Switch(
                                          value: showEntireHistory,
                                          onChanged: (value) {
                                            setState(() {
                                              showEntireHistory = value;
                                            });
                                          },
                                          activeTrackColor: mainGoaldColor,
                                          activeColor: mainGoaldColor,
                                        ),
                                      ],
                                    )),
                                  ],
                                )),
                            /*
                            // Manage Subscriptions
                            Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                child: Text(
                                  "Manage Subscriptions",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                )),
                            Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                margin: EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                        onTap: () {
                                          _openEditSubscription(context);
                                        },
                                        title: Row(
                                          children: <Widget>[
                                            Text("Add  Subscription"),
                                          ],
                                        )),
                                    ListTile(
                                        onTap: () {
                                          _openSubscriptionList();
                                        },
                                        title: Row(
                                          children: <Widget>[
                                            Text("View Subscriptions"),
                                          ],
                                        )),
                                  ],
                                )),
                          */
                            Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                color: mainGoaldColor,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ListTile(
                                          onTap: () {
                                            if (widget.amountController.text
                                                .isNotEmpty) {
                                              if (!isNumeric(widget
                                                      .amountController.text) ||
                                                  (CurrencyInfo().getCurrencyDecimalPlaces(
                                                              widget.stringData[
                                                                  "currency"]) ==
                                                          0 &&
                                                      !isInt(widget
                                                          .amountController
                                                          .text))) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Your Amount is invalid. Please Check again'),
                                                  duration:
                                                      Duration(seconds: 3),
                                                ));
                                                return;
                                              } else {
                                                widget.numData["dailyLimit"] =
                                                    num.parse(widget
                                                        .amountController.text);
                                                _save(
                                                    "dailyLimit",
                                                    widget
                                                        .numData["dailyLimit"]);
                                              }
                                            }

                                            // Checkbox for Disabling Save Button
                                            widget.numData["showSave"] = 0;
                                            if (showSaveButton) {
                                              widget.numData["showSave"] = 1;
                                            }
                                            _save("showSave",
                                                widget.numData["showSave"]);

                                            // Checkbox for Disabling Save Button
                                            widget.numData["historyMode"] = 0;
                                            if (showEntireHistory) {
                                              widget.numData["historyMode"] = 1;
                                            }
                                            _save("historyMode",
                                                widget.numData["historyMode"]);

                                            if (currency !=
                                                widget.stringData["currency"]) {
                                              widget.stringData["currency"] =
                                                  currency;
                                              _save("currency", currency);

                                              _clearDB();
                                              Navigator.pop(context, true);
                                            }
                                            Navigator.pop(context, false);
                                            setState(() {});
                                          },
                                          title: Text(
                                            "Save Setting",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                            textAlign: TextAlign.center,
                                          ))
                                    ])), // Save Button
                          ],
                        ))))));
  }

  _saveSubscription(SubscriptionEntry entry) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.insertSubscription(entry);
  }

  _save(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data is String) {
      prefs.setString(key, data);
    } else if (data is bool) {
      prefs.setBool(key, data);
    } else if (data is int) {
      prefs.setInt(key, data);
    } else if (data is double) {
      prefs.setDouble(key, data);
    } else {
      prefs.setStringList(key, data);
    }
  }

  _clearDB() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.clearSpendingTable();
    helper.clearSubscriptionTable();
  }
}
