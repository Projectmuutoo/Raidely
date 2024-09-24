import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:raidely/pages/navpages/navbottompages.dart';
import 'package:raidely/shared/appData.dart';

void main() async {
  await GetStorage.init();
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // // Connnect to FireStore
  // FirebaseFirestore.instance.settings = const Settings(
  //   persistenceEnabled: true,
  // );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => Appdata(),
      )
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Raidely',
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'itim',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: NavbottompagesPage(
        selectedPage: 1,
      ),
    );
  }
}
