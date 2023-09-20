import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:permission_handler/permission_handler.dart';

//Future is a function that describes a parameter to be undefined presently, however it will be defined at any point in the future
//await is an async keyword that is used to execute future function
//in order for the buttons to be mutable, we made a stateful widget as the homepage.
//'?' after a keyword denotes that it might be a null var and '!' after a keyword denotes that the var cannot be null.

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //following code allows the user to pick an image from Photos to edit.
  File? image;
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image =
          imageTemp); //after selecting the image, it adds it to the homepage where the editing will take place.
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void editImage() async {
    //following code allows the user to edit the image with various filters.
    if (image == null) return;
    final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageFilters(
                  //image filters is part of the plugin "image_editor_plus"
                  image: image!
                      .readAsBytesSync(), //reads the image in bytes synchronously
                )));
    if (editedImage == null) return;
    // prompt for saving
    saveImage(editedImage!);
  }

  void saveImage(Uint8List data) async {
    //the chosen image is then saved by converting image data to a file
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = "filtered-$time";
    await requestPermission(Permission
        .storage); //part of the plugin permission_manager that requests access to Photos
    await ImageGallerySaver.saveImage(data,
        name:
            name); //part of the plugin image_gallery_saver that invokes the image data to be saved in Photos
    showSuccess();
  }

  void showSuccess() {
    //showcasing success of saving the image via snackbar(prompt)
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Image saved to Photos")));
  }

  Future<bool> requestPermission(Permission permission) async {
    //required to provide access to Google Photos
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    //main UI of the app
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Photo Editor"),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          image != null
              ? Column(
                  children: [
                    Image.file(image!),
                    MaterialButton(
                      color: Colors.blueAccent,
                      child: const Text(
                        "Edit the Image",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        editImage();
                      },
                    )
                  ],
                )
              : const Text("No image selected"),
          MaterialButton(
            color: Colors.blueAccent,
            child: const Text(
              "Pick an Image",
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              pickImage();
            },
          )
        ],
      )),
    );
  }
}
