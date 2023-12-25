import 'package:flutter/material.dart';
import 'package:like_app/pages/pageInPage/ImagePicker/InstaPickerInterface.dart';

class SinglePicker extends StatelessWidget with InstaPickerInterface {
  final String usage;
  final String uID;
  final String email;
  const SinglePicker({super.key, required this.usage, required this.uID, required this.email});

  @override
  PickerDescription get description => const PickerDescription(
        icon: '☝️',
        label: 'Single Mode Picker',
        description: 'Picker to select a single image. '
            'Selecting a new image will replace the old one.',
      );

  @override
  Widget build(BuildContext context) => buildLayout(
        context,
        onPressed: () => pickAssets(context, maxAssets: 1, usage: usage, uID: uID, email: email),
      );

}

// class SinglePicker extends StatelessWidget {
//   const SinglePicker({Key? key}) : super(key: key);

//   ThemeData getPickerTheme(BuildContext context) {
//     return InstaAssetPicker.themeData(Colors.black).copyWith(
//       appBarTheme: const AppBarTheme(titleTextStyle: TextStyle(fontSize: 16)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<AssetEntity>?>(
//       future: InstaAssetPicker.pickAssets(
//         context,
//         title: "Pick Image",
//         closeOnComplete: true,
//         maxAssets: 1,
//         pickerTheme: getPickerTheme(context),
//         onCompleted: (Stream<InstaAssetsExportDetails> cropStream) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) =>
//                   PickerCropResultScreen(cropStream: cropStream),
//             ),
//           );
//         },
//       ),
//       builder: (context, snapshot) {
//         return Container();
//       },
//       // builder: (context, snapshot) {
//       //   if (snapshot.connectionState == ConnectionState.done) {
//       //     if (snapshot.hasError) {
//       //       // Handle error case
//       //       return ErrorWidget(snapshot.error.toString());
//       //     } else if (snapshot.hasData && snapshot.data != null) {
//       //       // Handle success case, for example, navigate to a result screen
//       //       return PickerCropResultScreen(assetList: snapshot.data!);
//       //     } else {
//       //       // Handle the case where the user canceled the picker
//       //       return Container(); // You might want to return some placeholder widget
//       //     }
//       //   } else {
//       //     // While the future is still in progress, you can show a loading indicator
//       //     return Center(child: CircularProgressIndicator());
//       //   }
//       // },
//     );
//   }
// }


// // const _kMultiplePickerMax = 4;

// // class MultiplePicker extends StatelessWidget with InstaPickerInterface {
// //   const MultiplePicker({super.key});

// //   @override
// //   PickerDescription get description => const PickerDescription(
// //         icon: '🖼️',
// //         label: 'Multiple Mode Picker',
// //         description:
// //             'Picker for selecting multiple images (max $_kMultiplePickerMax).',
// //       );

// //   @override
// //   Widget build(BuildContext context) => buildLayout(
// //         context,
// //         onPressed: () => pickAssets(context, maxAssets: 4, usage: "Post",),
// //       );
// }