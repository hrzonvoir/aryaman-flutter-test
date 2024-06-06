import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;

class ImageEditorController extends GetxController {
  File? _image;
  final picker = ImagePicker();
  var selectedIndex = 0.obs;
  var imageHistory = <File?>[].obs;
  var currentImageIndex = (-1).obs;

  File? get image => _image;
  int get currentIndex => selectedIndex.value;
  int get currentImageHistoryIndex => currentImageIndex.value;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _addToHistory(_image);
      update();
    }
  }

  Future<void> cropImage() async {
    if (_image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      if (croppedFile != null) {
        _image = File(croppedFile.path);
        _addToHistory(_image);
        update();
      }
    }
  }

  Future<void> saveImage() async {
    if (_image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${path.basename(_image!.path)}';
      final newImage = await _image!.copy(filePath);

      final result = await GallerySaver.saveImage(newImage.path);
      Get.snackbar('Save Image', 'Image saved to $result');
    }
  }

  Future<void> shareImage() async {
    if (_image != null) {
      final XFile xFile = XFile(_image!.path);
      await Share.shareXFiles([XFile(xFile.path)],
          text: 'Check out this image!');
    }
  }

  void undo() {
    if (canUndo()) {
      currentImageIndex.value--;
      _image = imageHistory[currentImageIndex.value];
      update();
    }
  }

  void redo() {
    if (canRedo()) {
      currentImageIndex.value++;
      _image = imageHistory[currentImageIndex.value];
      update();
    }
  }

  bool canUndo() {
    return currentImageIndex.value > 0;
  }

  bool canRedo() {
    return currentImageIndex.value < imageHistory.length - 1;
  }

  void clearImage() {
    _image = null;
    imageHistory.clear();
    currentImageIndex.value = -1;
    update();
  }

  void applyFilter(Function filter) {
    if (_image != null) {
      final originalImage = img.decodeImage(_image!.readAsBytesSync());
      if (originalImage != null) {
        final filteredImage = filter(originalImage);
        getTemporaryDirectory().then((dir) {
          final filePath =
              '${dir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File(filePath);
          file.writeAsBytesSync(img.encodePng(filteredImage));
          _image = file;
          _addToHistory(_image);
          update();
        });
      }
    }
  }

  img.Image grayscale(img.Image src) => img.grayscale(src);
  img.Image invert(img.Image src) => img.invert(src);
  img.Image sepia(img.Image src) => img.sepia(src);

  void _addToHistory(File? image) {
    if (currentImageIndex.value < imageHistory.length - 1) {
      imageHistory.value = imageHistory.sublist(0, currentImageIndex.value + 1);
    }
    imageHistory.add(image);
    currentImageIndex.value = imageHistory.length - 1;
  }
}
