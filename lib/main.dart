import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timed Switches',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: TimerSwitch(),
      ),
    );
  }
}

class TimerSwitch extends StatefulWidget {
  const TimerSwitch({Key? key}) : super(key: key);

  @override
  _TimerSwitchState createState() => _TimerSwitchState();
}

Future getTimeOf() async {
  var _timer1 = await http
      .get(Uri.parse('http://192.168.100.100:100/controlAC/getTimer/1'));
  int _timeLeft1 = (int.parse(_timer1.body
      .toString()
      .substring(1, _timer1.body.toString().length - 1)));
  List<int> _time1 = [];
  _time1.add(((int.parse(_timer1.body
              .toString()
              .substring(1, _timer1.body.toString().length - 1))) ~/
          60) ~/
      60);
  _time1.add(((int.parse(_timer1.body
              .toString()
              .substring(1, _timer1.body.toString().length - 1))) ~/
          60) -
      60 * _time1[0]);

  var _timer2 = await http
      .get(Uri.parse('http://192.168.100.100:100/controlAC/getTimer/2'));

  List<int> _time2 = [];
  _time2.add(((int.parse(_timer2.body
              .toString()
              .substring(1, _timer2.body.toString().length - 1))) ~/
          60) ~/
      60);
  _time2.add(((int.parse(_timer2.body
              .toString()
              .substring(1, _timer2.body.toString().length - 1))) ~/
          60) -
      60 * _time2[0]);

  List _returnList = [];
  _returnList.add(_time1);
  _returnList.add(_time2);
  return _time1.first.toString() +
      "," +
      _time1.last.toString() +
      "," +
      _time2.first.toString() +
      "," +
      _time2.last.toString();
}

bool _animating = true;
bool _timer1active = false;
bool _timer2active = false;

class _TimerSwitchState extends State<TimerSwitch> {
  final FixedExtentScrollController scroller1Hr = FixedExtentScrollController();
  final FixedExtentScrollController scroller1Min =
      FixedExtentScrollController();
  final FixedExtentScrollController scroller2Hr = FixedExtentScrollController();
  final FixedExtentScrollController scroller2Min =
      FixedExtentScrollController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final bool mobileDevice = height > width ? true : false;
    return FutureBuilder(
        future: getTimeOf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // print('object');
            List _timeVals = (snapshot.data.toString().split(','));

            print(_timeVals.toString());
            Future.delayed(Duration(milliseconds: 500), () {
              scroller1Hr.animateToItem(int.parse(_timeVals[0]),
                  duration: Duration(seconds: 1), curve: Curves.easeInOut);
              scroller1Min.animateToItem(int.parse(_timeVals[1]),
                  duration: Duration(seconds: 1), curve: Curves.decelerate);
              scroller2Hr.animateToItem(int.parse(_timeVals[2]),
                  duration: Duration(seconds: 1), curve: Curves.easeInOut);
              scroller2Min.animateToItem(int.parse(_timeVals[3]),
                  duration: Duration(seconds: 1), curve: Curves.decelerate);
            });
            Future.delayed(Duration(milliseconds: 1500), () {
              _animating = false;
            });

            return Stack(
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: mobileDevice
                          ? EdgeInsets.all(20.0)
                          : EdgeInsets.all(40.0),
                      child: Text(
                        'Timed Switches',
                        style: TextStyle(fontSize: 36, color: Colors.white),
                      ),
                    )),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TimerBox(
                        height: height,
                        width: width,
                        timerId: 1,
                        scrollerHr: scroller1Hr,
                        scrollerMin: scroller1Min,
                      ),
                      TimerBox(
                        height: height,
                        width: width,
                        timerId: 2,
                        scrollerHr: scroller2Hr,
                        scrollerMin: scroller2Min,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

int timer1HrVal = 0;
int timer1MinVal = 0;
int timer2HrVal = 0;
int timer2MinVal = 0;

class TimerBox extends StatefulWidget {
  TimerBox(
      {required this.height,
      required this.width,
      required this.timerId,
      required this.scrollerHr,
      required this.scrollerMin});
  final double height;
  final double width;
  final int timerId;

  final FixedExtentScrollController scrollerHr;
  final FixedExtentScrollController scrollerMin;

  @override
  _TimerBoxState createState() => _TimerBoxState(
      height: height,
      width: width,
      timerId: timerId,
      scrollerHr: scrollerHr,
      scrollerMin: scrollerMin);
}

class _TimerBoxState extends State<TimerBox> {
  _TimerBoxState(
      {required this.height,
      required this.width,
      required this.timerId,
      required this.scrollerHr,
      required this.scrollerMin});
  final double height;
  final double width;
  final int timerId;

  final FixedExtentScrollController scrollerHr;
  final FixedExtentScrollController scrollerMin;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      height: height * 0.30,
      width: width * 0.7,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: height * 0.40,
              width: width * 0.35,
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Hr',
                          style: TextStyle(
                              color: timerId == 1 && _timer1active ||
                                      timerId == 2 && _timer2active
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 18),
                        ),
                      )),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotatedBox(
                            quarterTurns: 2,
                            child: Image.asset(
                              'assets/arrowDown.png',
                              width: 25,
                              color: timerId == 1 && _timer1active ||
                                      timerId == 2 && _timer2active
                                  ? Color(0xff00E031)
                                  : Colors.white,
                            )),

                        // ),
                        CupertinoPicker(
                          diameterRatio: 1,
                          // useMagnifier: true,
                          // magnification: 3.5,
                          scrollController: scrollerHr,
                          selectionOverlay:
                              CupertinoPickerDefaultSelectionOverlay(
                            background: Colors.transparent,
                          ),
                          itemExtent: 60,
                          looping: false,
                          onSelectedItemChanged: (int value) {
                            value = timerId == 1
                                ? timer1HrVal = value
                                : timer2HrVal = value;
                            int _totalSecs = (timerId == 1
                                ? timer1HrVal * 60 * 60 + timer1MinVal * 60
                                : timer2HrVal * 60 * 60 + timer2MinVal * 60);
                            if (_totalSecs > 0) {
                              if (timerId == 1) {
                                _timer1active = true;
                              } else {
                                _timer2active = true;
                              }
                            } else {
                              if (timerId == 1) {
                                _timer1active = false;
                              } else {
                                _timer2active = false;
                              }
                            }
                            setState(() {
                              _timer1active;
                              _timer2active;
                            });

                            if (_totalSecs == 0) {
                              _totalSecs = 1;
                            }

                            String _url =
                                'http://192.168.100.100:100/controlAC/' +
                                    timerId.toString() +
                                    '/' +
                                    _totalSecs.toString();

                            _animating
                                ? null
                                : http
                                    .get(Uri.parse(_url))
                                    .then((value) => print(value.body));
                          },
                          children: [
                            for (int i = 0; i < 60; i++)
                              Text(
                                i < 10 ? '0' + i.toString() : i.toString(),
                                style: TextStyle(
                                  color: timerId == 1 && _timer1active ||
                                          timerId == 2 && _timer2active
                                      ? Color(0xff646464)
                                      : Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 50,
                                ),
                              ),
                          ],
                        ),
                        Image.asset(
                          'assets/arrowDown.png',
                          width: 25,
                          color: timerId == 1 && _timer1active ||
                                  timerId == 2 && _timer2active
                              ? Color(0xff00E031)
                              : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: timerId == 1 && _timer1active ||
                        timerId == 2 && _timer2active
                    ? Colors.yellow
                    : Color(0xff1F1C22),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: height * 0.40,
              width: width * 0.35,
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Min',
                          style: TextStyle(
                              color: timerId == 1 && _timer1active ||
                                      timerId == 2 && _timer2active
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 18),
                        ),
                      )),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotatedBox(
                            quarterTurns: 2,
                            child: Image.asset(
                              'assets/arrowDown.png',
                              width: 25,
                              color: timerId == 1 && _timer1active ||
                                      timerId == 2 && _timer2active
                                  ? Color(0xff54FF7A)
                                  : Colors.white,
                            )),
                        CupertinoPicker(
                          scrollController: scrollerMin,
                          diameterRatio: 1,
                          // useMagnifier: true,
                          // magnification: 3.5,
                          selectionOverlay:
                              CupertinoPickerDefaultSelectionOverlay(
                            background: Colors.transparent,
                          ),
                          itemExtent: 60,
                          looping: false,
                          onSelectedItemChanged: (int value) {
                            value = timerId == 1
                                ? timer1MinVal = value
                                : timer2MinVal = value;
                            int _totalSecs = (timerId == 1
                                ? timer1HrVal * 60 * 60 + timer1MinVal * 60
                                : timer2HrVal * 60 * 60 + timer2MinVal * 60);
                            if (_totalSecs > 0) {
                              if (timerId == 1) {
                                _timer1active = true;
                              } else {
                                _timer2active = true;
                              }
                            } else {
                              if (timerId == 1) {
                                _timer1active = false;
                              } else {
                                _timer2active = false;
                              }
                            }
                            setState(() {
                              _timer1active;
                              _timer2active;
                            });

                            if (_totalSecs == 0) {
                              _totalSecs = 1;
                            }

                            String _url =
                                'http://192.168.100.100:100/controlAC/' +
                                    timerId.toString() +
                                    '/' +
                                    _totalSecs.toString();

                            _animating
                                ? null
                                : http
                                    .get(Uri.parse(_url))
                                    .then((value) => print(value.body));
                          },
                          children: [
                            for (int i = 0; i < 60; i++)
                              Text(
                                i < 10 ? '0' + i.toString() : i.toString(),
                                style: TextStyle(
                                  color: timerId == 1 && _timer1active ||
                                          timerId == 2 && _timer2active
                                      ? Color(0xff646464)
                                      : Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 50,
                                ),
                              ),
                          ],
                        ),
                        Image.asset(
                          'assets/arrowDown.png',
                          width: 25,
                          color: timerId == 1 && _timer1active ||
                                  timerId == 2 && _timer2active
                              ? Color(0xff54FF7A)
                              : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: timerId == 1 && _timer1active ||
                        timerId == 2 && _timer2active
                    ? Color(0xff00E031)
                    : Color(0xff302D34),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// class timerBox extends StatelessWidget {
//   timerBox({
//     Key? key,
//     required this.height,
//     required this.width,
//     required this.timerId,
//     required this.scrollerHr,
//     required this.scrollerMin,
//   }) : super(key: key);

//   final double height;
//   final double width;
//   final int timerId;

//   final FixedExtentScrollController scrollerHr;
//   final FixedExtentScrollController scrollerMin;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(30),
//       height: height * 0.30,
//       width: width * 0.7,
//       child: Stack(
//         children: [
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Container(
//               height: height * 0.40,
//               width: width * 0.35,
//               child: Stack(
//                 children: [
//                   Align(
//                       alignment: Alignment.topCenter,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Hr',
//                           style: TextStyle(color: Colors.white, fontSize: 18),
//                         ),
//                       )),
//                   Align(
//                     alignment: Alignment.center,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         RotatedBox(
//                             quarterTurns: 2,
//                             child: Image.asset(
//                               'assets/arrowDown.png',
//                               width: 25,
//                               color: Colors.white,
//                             )),

//                         // ),
//                         CupertinoPicker(
//                           diameterRatio: 1,
//                           // useMagnifier: true,
//                           // magnification: 3.5,
//                           scrollController: scrollerHr,
//                           selectionOverlay:
//                               CupertinoPickerDefaultSelectionOverlay(
//                             background: Colors.transparent,
//                           ),
//                           itemExtent: 60,
//                           looping: false,
//                           onSelectedItemChanged: (int value) {
//                             if (value > 0) {
//                               if (timerId == 1) {
//                                 _timer1active = true;
//                               } else {
//                                 _timer2active = true;
//                               }
//                             } else {
//                               if (timerId == 1) {
//                                 _timer1active = false;
//                               } else {
//                                 _timer2active = false;
//                               }
//                             }

//                             value = timerId == 1
//                                 ? timer1HrVal = value
//                                 : timer2HrVal = value;
//                             int _totalSecs = (timerId == 1
//                                 ? timer1HrVal * 60 * 60 + timer1MinVal * 60
//                                 : timer2HrVal * 60 * 60 + timer2MinVal * 60);
//                             if (_totalSecs == 0) {
//                               _totalSecs = 1;
//                             }
//                             String _url =
//                                 'http://192.168.100.100:100/controlAC/' +
//                                     timerId.toString() +
//                                     '/' +
//                                     _totalSecs.toString();

//                             _animating
//                                 ? null
//                                 : http
//                                     .get(Uri.parse(_url))
//                                     .then((value) => print(value.body));
//                           },
//                           children: [
//                             for (int i = 0; i < 60; i++)
//                               Text(
//                                 i < 10 ? '0' + i.toString() : i.toString(),
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w300,
//                                   fontSize: 50,
//                                 ),
//                               ),
//                           ],
//                         ),
//                         Image.asset(
//                           'assets/arrowDown.png',
//                           width: 25,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               decoration: BoxDecoration(
//                 color: Color(0xff1F1C22),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   bottomLeft: Radius.circular(30),
//                 ),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.centerRight,
//             child: Container(
//               height: height * 0.40,
//               width: width * 0.35,
//               child: Stack(
//                 children: [
//                   Align(
//                       alignment: Alignment.topCenter,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Min',
//                           style: TextStyle(color: Colors.white, fontSize: 18),
//                         ),
//                       )),
//                   Align(
//                     alignment: Alignment.center,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         RotatedBox(
//                             quarterTurns: 2,
//                             child: Image.asset(
//                               'assets/arrowDown.png',
//                               width: 25,
//                               color: Colors.white,
//                             )),
//                         CupertinoPicker(
//                           scrollController: scrollerMin,
//                           diameterRatio: 1,
//                           // useMagnifier: true,
//                           // magnification: 3.5,
//                           selectionOverlay:
//                               CupertinoPickerDefaultSelectionOverlay(
//                             background: Colors.transparent,
//                           ),
//                           itemExtent: 60,
//                           looping: false,
//                           onSelectedItemChanged: (int value) {
//                             value = timerId == 1
//                                 ? timer1MinVal = value
//                                 : timer2MinVal = value;
//                             int _totalSecs = (timerId == 1
//                                 ? timer1HrVal * 60 * 60 + timer1MinVal * 60
//                                 : timer2HrVal * 60 * 60 + timer2MinVal * 60);
//                             if (_totalSecs == 0) {
//                               _totalSecs = 1;
//                             }
//                             String _url =
//                                 'http://192.168.100.100:100/controlAC/' +
//                                     timerId.toString() +
//                                     '/' +
//                                     _totalSecs.toString();

//                             _animating
//                                 ? null
//                                 : http
//                                     .get(Uri.parse(_url))
//                                     .then((value) => print(value.body));
//                           },
//                           children: [
//                             for (int i = 0; i < 60; i++)
//                               Text(
//                                 i < 10 ? '0' + i.toString() : i.toString(),
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w300,
//                                   fontSize: 50,
//                                 ),
//                               ),
//                           ],
//                         ),
//                         Image.asset(
//                           'assets/arrowDown.png',
//                           width: 25,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               decoration: BoxDecoration(
//                 color: Color(0xff302D34),
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(30),
//                   bottomRight: Radius.circular(30),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
