import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:just_audio_background/just_audio_background.dart';

import 'src/router.dart';
import 'src/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await SeamlessJustAudioBackground.init(
    androidNotificationChannelId: 'com.ezer.railgun.channel.audio',
    androidNotificationChannelName: 'Railgun-',
    androidNotificationOngoing: true,
  );
  await AudioPlayApi.init();
  await SettingApi.init();
  await RemoteApi.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(
          primary: Colors.indigoAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
      darkTheme: ThemeData.from(
        colorScheme: const ColorScheme.dark(
          primary: Colors.indigoAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
    );
  }
}
