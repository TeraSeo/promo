import 'package:flutter/material.dart';
// import 'package:insta_assets_picker/insta_assets_picker.dart';

class ImagePickPage extends StatefulWidget {
  const ImagePickPage({super.key});

  @override
  State<ImagePickPage> createState() => _ImagePickPageState();
}

class _ImagePickPageState extends State<ImagePickPage> {

  // List<AssetEntity> _selectedAssets = [];

  Future<void> _pickImages() async {

    // List<AssetEntity>? result = await InstaAssetPicker.pickAssets(
    //   context,
    //   title: 'Select images',
    //   maxAssets: 10,
    //   onCompleted: (Stream<InstaAssetsExportDetails> stream) {
    //     // Handle the completed stream if needed
    //   },
    // );

    // if (result != null && result.isNotEmpty) {
    //   setState(() {
    //     _selectedAssets = List.from(result);
    //   });
    // }

  }

  // Future<List<AssetEntity>?> callPicker() => InstaAssetPicker.pickAssets(
  //   context,
  //   title: 'Select images',
  //   maxAssets: 10,
  //   onCompleted: (Stream<InstaAssetsExportDetails> stream) {
  //   },
  // );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _pickImages,
            child: Text('Pick Images'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              // itemCount: _selectedAssets.length,
              itemBuilder: (context, index) {
                // return Image(
                //   // image: AssetEntityImageProvider(_selectedAssets[index]),
                //   fit: BoxFit.cover,
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}