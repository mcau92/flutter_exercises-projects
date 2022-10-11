import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pomodoro_timer/providers/settings_provider.dart';
import 'package:pomodoro_timer/widgets/pause_button.dart';
import 'package:pomodoro_timer/widgets/resume_button.dart';
import 'package:pomodoro_timer/widgets/session_title_widget.dart';
import 'package:pomodoro_timer/widgets/stop_button.dart';
import 'package:pomodoro_timer/widgets/time_widget.dart';
import 'package:provider/provider.dart';

class Break extends StatefulWidget {
  const Break({Key? key}) : super(key: key);

  @override
  State<Break> createState() => _BreakState();
}

class _BreakState extends State<Break> {
  late Timer countdownTimer;
  late Duration duration;
  bool buttonStopped = false;
  Duration? durationRimanente;
  late SettingsProvider settingsprovider;

  @override
  void didChangeDependencies() {
    settingsprovider = Provider.of<SettingsProvider>(context, listen: false);
    duration = Duration(minutes: settingsprovider.breakMinutes);
    startTimer();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    super.dispose();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopCounter() {
    setState(() {
      countdownTimer.cancel();
    });
    Navigator.of(context).pushReplacementNamed("home");
  }

  void resumeTimer() {
    setState(() {
      buttonStopped = false;
      duration = durationRimanente!;
      startTimer();
    });
  }

  void stopTimer() {
    setState(() {
      buttonStopped = true;
      countdownTimer.cancel();
    });
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    final seconds = duration.inSeconds - reduceSecondsBy;
    if (seconds < 0) {
      setState(() {
        countdownTimer.cancel();
      });

      if (settingsprovider.numRepeatRem == settingsprovider.numRepeat) {
        Navigator.of(context).pushReplacementNamed("home");
      } else {
        settingsprovider.numRepeatRem = settingsprovider.numRepeatRem + 1;
        Navigator.of(context).pushReplacementNamed("studio");
      }
    } else {
      setState(() {
        duration = Duration(seconds: seconds);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 132, 13, 1),
      body: _homeBody(),
    );
  }

  Widget _homeBody() {
    durationRimanente = duration;
    return Stack(
      children: [
        Consumer<SettingsProvider>(
          builder: ((context, value, child) {
            return buttonStopped
                ? ResumeButton(
                    resume: resumeTimer,
                  )
                : PauseButton(
                    pause: stopTimer,
                  );
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 200.0),
          child: Center(
            child: Column(
              children: [
                const SessionTitleWidget(
                  title: "Pausa",
                ),
                const SizedBox(
                  height: 100,
                ),
                TimerWidget(
                  currentMinutes: duration.inMinutes,
                  currentSeconds: duration.inSeconds,
                ),
              ],
            ),
          ),
        ),
        StopButton(resetCounters: stopCounter),
      ],
    );
  }
}
