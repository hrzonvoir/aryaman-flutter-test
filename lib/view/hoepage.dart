import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zonvior/controler/image_editing_controller.dart';

class ImageEditorPage extends StatelessWidget {
  final ImageEditorController controller = Get.put(ImageEditorController());

  ImageEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Image Editor'),
        actions: [
          Obx(() => IconButton(
                icon: const Icon(Icons.undo),
                onPressed: controller.canUndo() ? controller.undo : null,
              )),
          Obx(() => IconButton(
                icon: const Icon(Icons.redo),
                onPressed: controller.canRedo() ? controller.redo : null,
              )),
          Obx(() => IconButton(
                icon: const Icon(Icons.clear),
                onPressed:
                    controller.image != null ? controller.clearImage : null,
              )),
        ],
      ),
      body: Center(
        child: Obx(() => controller.image == null
            ? const Text('No image selected.', style: TextStyle(fontSize: 18))
            : Image.file(controller.image!)),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.add_a_photo),
                label: 'Pick Image',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.crop),
                label: 'Crop Image',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.filter),
                label: 'Filters',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.share),
                label: 'Share Image',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.save),
                label: 'Save Image',
              ),
            ],
            currentIndex: controller.currentIndex,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            onTap: (index) async {
              if (controller.image == null &&
                  (index == 1 || index == 2 || index == 3 || index == 4)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select an image first.')),
                );
                return;
              }

              switch (index) {
                case 0:
                  await controller.pickImage();
                  break;
                case 1:
                  await controller.cropImage();
                  break;
                case 2:
                  _showFilterOptions(context);
                  break;
                case 3:
                  await controller.shareImage();
                  break;
                case 4:
                  await controller.saveImage();
                  break;
              }
              controller.selectedIndex.value = index;
            },
          )),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            shrinkWrap: true,
            children: [
              _buildFilterOption(
                icon: Icons.filter,
                label: 'Grayscale',
                onTap: () {
                  controller.applyFilter(controller.grayscale);
                  Navigator.of(context).pop();
                },
              ),
              _buildFilterOption(
                icon: Icons.invert_colors,
                label: 'Invert',
                onTap: () {
                  controller.applyFilter(controller.invert);
                  Navigator.of(context).pop();
                },
              ),
              _buildFilterOption(
                icon: Icons.colorize,
                label: 'Sepia',
                onTap: () {
                  controller.applyFilter(controller.sepia);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40.0),
          const SizedBox(height: 8.0),
          Text(label, style: const TextStyle(fontSize: 16.0)),
        ],
      ),
    );
  }
}
