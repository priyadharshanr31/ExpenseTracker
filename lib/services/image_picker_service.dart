import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<XFile?> pickImageFromCamera() async {
    return pickImage(ImageSource.camera);
  }

  Future<XFile?> pickImageFromGallery() async {
    return pickImage(ImageSource.gallery);
  }
}
