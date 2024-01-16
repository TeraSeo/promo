import 'dart:io';
import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:like_app/pages/home_page.dart';
import 'package:like_app/services/storage.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/widgets/widgets.dart';

class PickerCropResultScreen extends StatelessWidget {
  const PickerCropResultScreen({super.key, required this.cropStream, required this.usage, required this.uID, required this.email});

  final Stream<InstaAssetsExportDetails> cropStream;
  final String usage;
  final String email;
  final String uID;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height - kToolbarHeight;

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: StreamBuilder<InstaAssetsExportDetails>(
        stream: cropStream,
        builder: (context, snapshot) {
          return CropResultView(
            selectedAssets: snapshot.data?.selectedAssets ?? [],
            croppedFiles: snapshot.data?.croppedFiles ?? [],
            progress: snapshot.data?.progress,
            heightFiles: height / 2,
            heightAssets: height / 4,
            usage: usage,
            uID: uID,
            email: email,
          );
        }
      
      ),
    );
  }
}

class CropResultView extends StatefulWidget {
  const CropResultView({
    Key? key,
    required this.selectedAssets,
    required this.croppedFiles,
    this.progress,
    this.heightFiles = 300.0,
    this.heightAssets = 120.0,
    required this.usage,
    required this.uID,
    required this.email,
  }) : super(key: key);

  final List<AssetEntity> selectedAssets;
  final List<File> croppedFiles;
  final double? progress;
  final double heightFiles;
  final double heightAssets;
  final String usage;
  final String uID;
  final String email;

  @override
  _CropResultViewState createState() => _CropResultViewState();
}

class _CropResultViewState extends State<CropResultView> {
  bool isProfileChanging = false;
  Storage storage = Storage();
  DatabaseService databaseService = DatabaseService();

  Widget _buildTitle(String title, int length) {
    return SizedBox(
      height: 20.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurpleAccent,
            ),
            child: Text(
              length.toString(),
              style: const TextStyle(
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCroppedImagesListView(BuildContext context) {
    if (widget.progress == null) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            itemCount: widget.croppedFiles.length,
            itemBuilder: (BuildContext _, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16.0,
                ),
                child: ClipOval(
                
                  child: Image.file(widget.croppedFiles[index]),
                ),
              );
            },
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AnimatedContainer(
          duration: kThemeChangeDuration,
          curve: Curves.easeInOut,
          height: widget.croppedFiles.isNotEmpty ? widget.heightFiles : 40.0,
          child: Column(
            children: <Widget>[
              _buildTitle('Cropped Images', widget.croppedFiles.length),
              _buildCroppedImagesListView(context),
            ],
          ),
        ),
        !isProfileChanging
            ? OutlinedButton(
                onPressed: () {
                  try {
                    if (!isProfileChanging) {
                      setState(() {
                        isProfileChanging = true;
                      });

                      Future.delayed(Duration(seconds: 0), () async {
                        if (widget.usage == "profile") {
                          await databaseService.setUserProfile(
                            widget.uID,
                            widget.croppedFiles[0].path,
                            widget.croppedFiles[0].path.split('/').last,
                            widget.email,
                          );
                        } else if (widget.usage == "background") {
                          await databaseService.setUserBackground(
                            widget.uID,
                            widget.croppedFiles[0].path,
                            widget.croppedFiles[0].path.split('/').last,
                            widget.email,
                          );
                        }
                        nextScreenReplace(context, HomePage(pageIndex: 3));
                      });

                    }
                  } catch (e) {}
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black, // Border color
                  padding: EdgeInsets.all(16.0), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // Button border radius
                  ),
                ),
                child: Text('Change Profile'),
              )
            : CircularProgressIndicator()
      ],
    );
  }
}
