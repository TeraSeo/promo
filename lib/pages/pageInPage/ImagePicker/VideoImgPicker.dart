import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class WeChatPickerPage extends StatefulWidget {
  @override
  _WeChatPickerPageState createState() => _WeChatPickerPageState();
}

class _WeChatPickerPageState extends State<WeChatPickerPage> {
  List<AssetEntity> selectedAssets = [];

  void _onSelectAssets(List<AssetEntity> assets) {
    setState(() {
      selectedAssets = List.from(assets);
    });
  }

  Future<void> _checkPermission() async {
    final PermissionState state = await AssetPicker.permissionCheck(
      requestOption: const PermissionRequestOption(),
    );

    if (state == PermissionState.authorized) {
      // Permission granted, you can proceed with asset picking.
      _pickAssets();
    } else {
      // Handle cases where permission is denied or restricted.
      // You may want to show a message to the user.
      print('Permission denied or restricted.');
    }
  }

  Future<void> _pickAssets() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      // requestOption: const PermissionRequestOption(),
      // maxAssets: 9,
      // selectedAssets: selectedAssets,
      // onSelect: _onSelectAssets,
    );

    if (result != null) {
      setState(() {
        selectedAssets = List.from(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WeChat Picker Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _checkPermission,
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: selectedAssets.length,
        itemBuilder: (context, index) {
          return AssetThumbnail(asset: selectedAssets[index]);
        },
      ),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;

  AssetThumbnail({required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WeChatPickerPage(),
  ));
}
