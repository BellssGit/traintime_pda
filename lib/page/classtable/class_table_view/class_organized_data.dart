// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

// Copied from https://github.com/SimformSolutionsPvtLtd/flutter_calendar_view/blob/master/lib/src/event_arrangers/event_arrangers.dart.
// Removed left/right, only use stack.

import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';

class ClassOrgainzedData {
  final List<dynamic> data;

  /// The time range of each block is not even in exam
  /// or experiment, so use double...
  late final double start;
  late final double stop;

  final String name;
  final String? place;

  /// Following is the begin/end for each blocks...
  static const _timeInBlock = [
    "08:30",
    "09:20",
    "10:25",
    "11:15",
    "12:00",
    "14:00",
    "14:50",
    "15:55",
    "16:45",
    "17:30",
    "19:00",
    "19:55",
    "20:35",
    "21:25",
  ];

  factory ClassOrgainzedData.fromTimeArrangement(
    TimeArrangement timeArrangement,
    String name,
  ) {
    double transferIndex(int index, {bool isStart = false}) {
      late double toReturn;
      if (index <= 4) {
        toReturn = index * 5;
        if (isStart && index == 4) {
          toReturn += 2;
        }
      } else if (index <= 8) {
        toReturn = index * 5 + 2;
        if (isStart && index == 8) {
          toReturn += 3;
        }
      } else {
        return (index + 1) * 5;
      }
      return toReturn;
    }

    return ClassOrgainzedData(
      data: [timeArrangement],
      start: transferIndex(timeArrangement.start - 1, isStart: true),
      stop: transferIndex(timeArrangement.stop),
      name: name,
      place: timeArrangement.classroom,
    );
  }

  factory ClassOrgainzedData.fromSubject(
    Subject subject,
  ) =>
      ClassOrgainzedData._(
        data: [(subject)],
        start: subject.startTime.dateTime,
        stop: subject.stopTime.dateTime,
        name: subject.subject,
        place: "${subject.place} ${subject.seat}",
      );

  factory ClassOrgainzedData.fromExperiment(
    ExperimentData exp,
  ) =>
      ClassOrgainzedData._(
        data: [exp],
        start: exp.time.first,
        stop: exp.time.last,
        name: exp.name,
        place: exp.classroom,
      );

  ClassOrgainzedData({
    required this.data,
    required this.start,
    required this.stop,
    required this.name,
    this.place,
  });

  ClassOrgainzedData._({
    required this.data,
    required DateTime start,
    required DateTime stop,
    required this.name,
    this.place,
  }) {
    double transferIndex(DateTime time) {
      int timeInMin = time.hour * 60 + time.minute;
      int previous = 0;
      // Start from the second element.
      for (var i in _timeInBlock) {
        int timeChosen =
            int.parse(i.split(":")[0]) * 60 + int.parse(i.split(":")[1]);
        if (previous == 0) {
          previous = timeChosen;
          continue;
        }
        if (timeInMin >= previous && timeInMin <= timeChosen) {
          double basic = 0;
          double blocks = 5;
          double ratio = (timeInMin - previous) * 5 / (timeChosen - previous);
          if (previous < 12 * 60) {
            basic = _timeInBlock.indexOf(i) * 5;
          } else if (previous < 14 * 60) {
            basic = 20;
            blocks = 2;
          } else if (previous < 17.5 * 60) {
            basic = 22 + (_timeInBlock.indexOf(i) - 5) * 5;
          } else if (previous <= 19 * 60) {
            basic = 42;
            blocks = 3;
          } else {
            basic = 45 + (_timeInBlock.indexOf(i) - 10) * 5;
          }
          return basic + blocks * ratio;
        } else {
          previous = timeChosen;
        }
      }

      throw OutOfIndexException();
    }

    this.start = transferIndex(start);
    this.stop = transferIndex(stop);
    print("$start $stop $name");
  }
}

class OutOfIndexException implements Exception {}
