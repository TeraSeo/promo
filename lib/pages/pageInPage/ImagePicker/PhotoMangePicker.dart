// import 'package:like_app/pages/pageInPage/ImagePicker/InstaPickerInterface.dart';
// import 'package:flutter/material.dart';

// const _kMultiplePickerMax = 4;

// class PhotoManagerPicker extends StatelessWidget with InstaPickerInterface {
//   const PhotoManagerPicker({super.key});

//   @override
//   PickerDescription get description => const PickerDescription(
//         icon: '🖼️',
//         label: 'Multiple Mode Picker',
//         description:
//             'Picker for selecting multiple images (max $_kMultiplePickerMax).',
//       );

//   @override
//   Widget build(BuildContext context) => buildLayout(
//         context,
//         onPressed: () => pickAssets(context, maxAssets: _kMultiplePickerMax, usage: "Post"),
//       );
// }