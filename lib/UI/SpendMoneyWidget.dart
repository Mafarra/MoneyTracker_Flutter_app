import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:money_tracker/Utilitis/Colors.dart';
import 'package:money_tracker/Utilitis/CurrencyInfo.dart';
import 'package:money_tracker/database_helpers.dart';
import 'package:money_tracker/model/SpendingEntry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SpendMoneyWidget extends StatefulWidget {
  final Map<String, num> numData;
  final Map<String, String> stringData;
  final _myController = TextEditingController();
  SpendMoneyWidget({Key key, this.numData, this.stringData}) : super(key: key);
  @override
  State createState() => _SpendMoneyState();
}

class _SpendMoneyState extends State<SpendMoneyWidget> {
  String amount;
  @override
  void initState() {
    super.initState();
    widget.numData["keypadVisibility"] = 1.0;
    KeyboardVisibility.onChange.listen((bool visible) {
      widget.numData["keypadVisibility"] = 1.0;
      if (visible) {
        widget.numData["keypadVisibility"] = 0.0;
      }
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  String getMoneyText() {
    return CurrencyInfo().getCurrencyText(
        widget.stringData["currency"],
        num.parse(amount) /
            pow(
                10,
                CurrencyInfo()
                    .getCurrencyDecimalPlaces(widget.stringData["currency"])));
  }

  Widget buildButton(String s, [Icon i, Color c, double fontSize]) {
    return Expanded(
        child: MaterialButton(
      child: i == null
          ? Text(
              s,
              style: TextStyle(
                fontSize: fontSize == null ? 20.0 : fontSize,
              ),
            )
          : i,
      color: c,
      padding: EdgeInsets.all(20.0),
      onPressed: () => buttonPressed(s),
    ));
  }

  void buttonPressed(String s) {
    if (s == "erase") {
      if (amount.length > 1) {
        amount = amount.substring(0, amount.length - 1);
      } else {
        amount = "0";
      }
    } else if (s == "Spend" || s == "Save") {
      FocusScope.of(context).unfocus();
      double val = num.parse(amount) /
          pow(
              10,
              CurrencyInfo()
                  .getCurrencyDecimalPlaces(widget.stringData["currency"]));

      if (val > 0) {
        String content = widget._myController.text.isEmpty
            ? ("")
            : widget._myController.text;
        SpendingEntry entry = SpendingEntry();
        if (s == "Spend") {
          val *= -1;
        }
        DateTime dt = DateTime.now().toLocal();
        entry.timestamp = dt.millisecondsSinceEpoch;
        entry.day = DateTime(dt.year, dt.month, dt.day).millisecondsSinceEpoch;
        entry.amount = val;
        entry.content = content;
        // Save new Entry
        _saveDB(entry);
        widget.numData["todaySpent"] += val;
        _saveSP("todaySpent", widget.numData["todaySpent"]);
        // Reset Amount and Content
        amount = "0";
        widget._myController.text = "";
      }
    } else if (s == "C") {
      amount = "0";
    } else {
      amount += s;
    }
    setState(() {
      widget.numData["spendAmount"] = int.parse(amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    amount = widget.numData["spendAmount"].toInt().toString();
    widget._myController.text = widget.stringData["spendContent"];
    widget._myController.selection = TextSelection.fromPosition(
        TextPosition(offset: widget._myController.text.length));
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0, 55, 0, 30),
                  child: Text(
                    getMoneyText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50,
                    ),
                  ),
                ),
                ListTile(
                    title: Row(
                  children: <Widget>[
                    Flexible(
                        child: TextField(
                      controller: widget._myController,
                      onChanged: (text) {
                        widget.stringData["spendContent"] = text;
                      },
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: '(Optional) Enter Description',
                      ),
                      textAlign: TextAlign.start,
                    ))
                  ],
                )),
                // Expanded(child: Container()),
                IntrinsicHeight(
                  child: Row(children: [
                    Visibility(
                      visible: widget.numData["showSave"] == 1,
                      child: buildButton("Save", null, mainGoaldColor),
                    ),
                    Visibility(
                        visible: widget.numData["showSave"] == 1,
                        child: Container(
                          width: 1,
                          color: Colors.black12,
                        )),
                    buildButton("Spend", null, mainGoaldColor),
                  ]),
                ),
                Visibility(
                    visible: widget.numData["keypadVisibility"] == 1.0,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            buildButton("1"),
                            buildButton("2"),
                            buildButton("3"),
                          ],
                        ),
                        Row(
                          children: [
                            buildButton("4"),
                            buildButton("5"),
                            buildButton("6"),
                          ],
                        ),
                        Row(
                          children: [
                            buildButton("7"),
                            buildButton("8"),
                            buildButton("9"),
                          ],
                        ),
                        Row(
                          children: [
                            buildButton("C"),
                            buildButton("0"),
                            buildButton("erase", Icon(Icons.backspace)),
                          ],
                        )
                      ],
                    )),
                SizedBox(
                  height: 50,
                ),
              ],
            )),
          ],
        ));
  }

  _saveDB(SpendingEntry entry) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.insertSpending(entry);
  }

  _saveSP(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      prefs.setString(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else {
      prefs.setStringList(key, value);
    }
  }
}
