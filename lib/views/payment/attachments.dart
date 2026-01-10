import 'package:desktop_drop/desktop_drop.dart'; // Import this
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import 'package:warsha_commerce/controllers/drag_drop_controller.dart';
import 'package:warsha_commerce/utils/const_values.dart';
import 'package:warsha_commerce/utils/default_text.dart'; // For Uint8List

class DragDropMultipleImages extends StatefulWidget {
  const DragDropMultipleImages({super.key});

  @override
  State<DragDropMultipleImages> createState() => _DragDropMultipleImagesState();
}

class _DragDropMultipleImagesState extends State<DragDropMultipleImages> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DragDropController>(
      builder: (context, dropController, child) {
        return DropTarget(
          // 1. Handle External Drag & Drop events
          onDragEntered: (detail) => setState(() => _dragging = true),
          onDragExited: (detail) => setState(() => _dragging = false),
          onDragDone: (details) async {
            setState(() => _dragging = false);

            // Convert dropped XFiles to Uint8List
            List<Uint8List> newImages = [];
            for (var xfile in details.files) {
              var bytes = await xfile.readAsBytes();
              newImages.add(bytes);
            }
            dropController.addImages(newImages);
          },
          child: Container(
            width: double.infinity,
            height: 200,
            // margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: Constants.BORDER_RADIUS_5,
              color: _dragging
                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surfaceContainer,
              // changed surfaceTint to surfaceContainer for better contrast usually
              border: _dragging
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : Border.all(color: Colors.grey.shade300),
            ),

            // 2. Logic: If empty -> Big Upload Icon. If has data -> Grid View
            child: dropController.images.isEmpty
                ? _buildEmptyView(context, dropController)
                : _buildGridView(context, dropController),
          ),
        );
      },
    );
  }

  // View when no images are selected
  Widget _buildEmptyView(BuildContext context, DragDropController drop) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.gallery_add, size: 50, color: Colors.grey),
        const SizedBox(height: 10),
        DefaultText(txt: "ضيف صورك هنا \nاو", color: Theme.of(context).colorScheme.onPrimary,),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
          onPressed: () => _pickImages(drop),
          icon: Icon(Iconsax.document_upload, color: Theme.of(context).colorScheme.onPrimary),
          label: DefaultText(txt: 'تصفح من ملفاتك', color: Theme.of(context).colorScheme.onPrimary),
        ),
      ],
    );
  }

  // View when images exist (Thumbnails + Add Button)
  Widget _buildGridView(BuildContext context, DragDropController drop) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GridView.builder(
        itemCount: drop.images.length + 1, // +1 for the "Add More" button
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 images per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          if (index == drop.images.length) {
            return InkWell(
              onTap: () => _pickImages(drop),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.add_circle_copy, size: 30),
                    SizedBox(height: 5),
                    Text("ضيف اكتر", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          }

          // Image Thumbnail
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(
                  drop.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // Delete Button (Top Right)
              Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: () => drop.removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.close_circle, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper function to pick files
  Future<void> _pickImages(DragDropController drop) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // Key change: Allow multiple
      withData: true,
    );

    if (result != null) {
      // Map all selected files to a List of bytes
      List<Uint8List> newFiles = result.files
          .where((f) => f.bytes != null)
          .map((f) => f.bytes!)
          .toList();

      drop.addImages(newFiles);
    }
  }
}