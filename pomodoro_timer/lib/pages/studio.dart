import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pomodoro_timer/providers/settings_provider.dart';
import 'package:pomodoro_timer/widgets/pause_button.dart';
import 'package:pomodoro_timer/widgets/resume_button.dart';
import 'package:pomodoro_timer/widgets/session_title_widget.dart';
import 'package:pomodoro_timer/widgets/stop_button.dart';
import 'package:pomodoro_timer/widgets/time_widget.dart';
import 'package:provider/provider.dart';

class Studio extends StatefulWidget {
  const Studio({Key? key}) : super(key: key);

  @override
  State<Studio> createState() => _StudioState();
}

class _StudioState extends State<Studio> {
  late Timer countdownTimer;
  late Duration duration;
  bool buttonStopped = false;
  Duration? durationRimanente;

  @override
  void didChangeDependencies() {
    SettingsProvider settingsprovider = Provider.of<SettingsProvider>(context);
    duration = Duration(
      minutes: settingsprovider.studyMinutes,
    );
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
    setState(() {
      final seconds = duration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer.cancel();
        Navigator.of(context).pushReplacementNamed("break");
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
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
          padding: const EdgeInsets.only(top: 190.0),
          child: Center(
            child: Column(
              children: [
                const SessionTitleWidget(title: "Studio"),
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
