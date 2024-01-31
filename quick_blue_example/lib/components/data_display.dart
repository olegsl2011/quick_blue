import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';

class TimedData<T> {
  DateTime time;
  T data;

  TimedData(this.data, [DateTime? time]) : time = time ?? DateTime.now();
}

class DataDisplay extends StatefulWidget {
  final String deviceId;

  const DataDisplay(this.deviceId);

  @override
  State<DataDisplay> createState() => _DataDisplayState();
}

class _DataDisplayState extends State<DataDisplay> {
  Queue<TimedData<Uint8List>> _dataBuffer = Queue();

  @override
  void initState() {
    QuickBlue.setValueHandler((deviceId, characteristicId, value) {
      setState(() {
        _dataBuffer.add(TimedData(value));
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    QuickBlue.setValueHandler(null);
    super.dispose();
  }

  double _calcBufferFrequency(
      [Duration duration = const Duration(seconds: 1)]) {
    final now = DateTime.now();
    return _dataBuffer.where((e) => now.difference(e.time) < duration).length /
        duration.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text("hz: ${_calcBufferFrequency().toStringAsFixed(2)}"),
          Text(
              "hz: ${_calcBufferFrequency(Duration(seconds: 5)).toStringAsFixed(2)}"),
          Text(
              "hz: ${_calcBufferFrequency(Duration(seconds: 10)).toStringAsFixed(2)}"),
        ]),
        ...[
          for (var e in _dataBuffer.takeLast(5))
            Text(e.data.take(16).toString())
        ]
      ],
    );
  }
}

extension TakeLast<T> on Iterable<T> {
  Iterable<T> takeLast(int n) {
    final skipCount = length - n;
    return skipCount < 0 ? [] : skip(skipCount);
  }
}
