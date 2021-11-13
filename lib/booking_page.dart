import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _date = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    DateTime _datePicker = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: _date,
        lastDate: DateTime(2022));

    if (_datePicker != null && _datePicker != _date) {
      setState(() {
        _date = _datePicker;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.arrow_back,
          size: 20,
        ),
      ),
      body: Container(
        child: CalendarDatePicker(
          initialDate: _date,
          firstDate: _date,
          lastDate: DateTime(2022),
          onDateChanged: (newDate) {
            print("Nuova data $newDate");
          },
        ),
      ),
    );
  }
}
