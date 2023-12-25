// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:like_app/pages/pageInPage/ImagePicker/CameraPicker.dart';
// import 'package:like_app/pages/pageInPage/ImagePicker/InstaPickerInterface.dart';
// import 'package:like_app/pages/pageInPage/ImagePicker/RestorablePicker.dart';
// import 'package:like_app/pages/pageInPage/ImagePicker/StatelessPicker.dart';
// import 'package:like_app/pages/pageInPage/ImagePicker/WeChatCameraPicker.dart';

// const kDefaultColor = Colors.deepPurple;

// class InstagramMediaPicker extends StatefulWidget {
//   const InstagramMediaPicker({super.key});

//   @override
//   State<InstagramMediaPicker> createState() => _InstagramMediaPickerState();
// }

// class _InstagramMediaPickerState extends State<InstagramMediaPicker> {

//   List<CameraDescription>? _cameras;

//   bool isCameraLoading = true;
  
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration(seconds: 0)).then((value) async {
//       WidgetsFlutterBinding.ensureInitialized();
//       try {
//         await availableCameras().then((value) {
//           _cameras = value;
//           setState(() {
//             isCameraLoading = false;
//           });
//         });

//       } on CameraException catch (e) {
//         print(e);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isCameraLoading? Center(child: CircularProgressIndicator()) : MaterialApp(
//       title: 'Insta Assets Picker Demo',
//       // update to change the main theme of app + picker
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: kDefaultColor,
//           brightness: Brightness.dark,
//         ),
//         cardTheme: const CardTheme(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//           ),
//         ),
//         listTileTheme: const ListTileThemeData(
//           enableFeedback: true,
//           contentPadding: EdgeInsets.all(16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//           ),
//           titleTextStyle: TextStyle(fontWeight: FontWeight.w600),
//           leadingAndTrailingTextStyle: TextStyle(fontSize: 24),
//         ),
//       ),
//       home: PickersScreen(cameras: _cameras),
//       localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
//         GlobalWidgetsLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//     );
//   }

// }

// class PickersScreen extends StatelessWidget {
  
//   final List<CameraDescription>? cameras;

//   const PickersScreen({Key? key, this.cameras}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final List<InstaPickerInterface> pickers = [
//       const SinglePicker(usage: "profile",),
//       const MultiplePicker(),
//       const RestorablePicker(),
//     ];

//     return Scaffold(
//       appBar: AppBar(title: const Text('Insta pickers')),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(16),
//         itemBuilder: (BuildContext context, int index) {
//           final PickerDescription description = pickers[index].description;

//           return Card(
//             child: ListTile(
//               leading: Text(description.icon),
//               title: Text(description.label),
//               subtitle: description.description != null
//                   ? Text(description.description!)
//                   : null,
//               trailing: const Icon(Icons.chevron_right_rounded),
//               onTap: () => Navigator.of(context).push(
//                 MaterialPageRoute(builder: (context) => pickers[index]),
//               ),
//             ),
//           );
//         },
//         separatorBuilder: (_, __) => const SizedBox(height: 4),
//         itemCount: pickers.length,
//       ),
//     );
//   }
// }