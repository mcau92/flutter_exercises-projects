import 'package:pomodoro_timer/utils/settings_type.dart';

class Decoder {
  static String getLabel(SettingsType type, int value) {
    switch (type) {
      case SettingsType.studio:
      case SettingsType.pausa:
        return "min";
      case SettingsType.ripeti:
        return "rip";
    }
  }
}
