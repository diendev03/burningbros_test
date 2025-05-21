import 'package:burningbros_test/utils/asset_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomImageNetwork extends StatelessWidget {
  final String url;
  final double width;

  const CustomImageNetwork({super.key, required this.url, this.width = 100});

  bool _isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath == true &&
        (url.startsWith('http://') || url.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl(url)) {
      return _buildDefaultImage();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.network(
        url,
        width: width,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: SpinKitSpinningCircle(color: Colors.indigoAccent));
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage();
        },
      ),
    );
  }

  Widget _buildDefaultImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.asset(AssetRes.defaultImage, width: width, height: width, fit: BoxFit.cover),
    );
  }
}
