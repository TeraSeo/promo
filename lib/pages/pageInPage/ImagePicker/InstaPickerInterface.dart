import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:like_app/pages/pageInPage/ImagePicker/PickerCropResultScreen.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PickerDescription {
  final String icon;
  final String label;
  final String? description;

  const PickerDescription({
    required this.icon,
    required this.label,
    this.description,
  });

  String get fullLabel => '$icon $label';
}

mixin InstaPickerInterface on Widget {
  PickerDescription get description;

  ThemeData getPickerTheme(BuildContext context) {
    return InstaAssetPicker.themeData(Colors.black).copyWith(
      appBarTheme: const AppBarTheme(titleTextStyle: TextStyle(fontSize: 16)),
    );
  }

  AppBar get _appBar => AppBar(title: Text(description.fullLabel));

  Column pickerColumn({
    String? text,
    required VoidCallback onPressed,
    required BuildContext context
  }) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              text ??
                  AppLocalizations.of(context)!.profileChange,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: onPressed,
            child: FittedBox(
              child: Text(
                AppLocalizations.of(context)!.clickToChangeProfile,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      );

  Scaffold buildLayout(
    BuildContext context, {
    required VoidCallback onPressed,
  }) =>
      Scaffold(
        appBar: _appBar,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: pickerColumn(onPressed: onPressed, context: context),
        ),
      );

  Scaffold buildCustomLayout(
    BuildContext context, {
    required Widget child,
  }) =>
      Scaffold(
        appBar: _appBar,
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      );

  void pickAssets(BuildContext context, {required int maxAssets, required String usage, required String uID, required String email}) =>
      InstaAssetPicker.pickAssets(
        context,
        title: description.fullLabel,
        closeOnComplete: true,
        maxAssets: maxAssets,
        pickerTheme: getPickerTheme(context),
        onCompleted: (Stream<InstaAssetsExportDetails> cropStream) {
          nextScreen(context, PickerCropResultScreen(cropStream: cropStream, usage: usage, uID: uID, email: email));
        },
      );
}