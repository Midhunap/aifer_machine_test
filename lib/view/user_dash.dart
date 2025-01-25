import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var imageList = [].obs;

  @override
  void initState() {
    super.initState();
    getPhotos();
  }

  Future<void> getPhotos() async {
    try {
      final url = 'https://api.unsplash.com/photos?client_id=CuJflaSz2DRVDGvnVPxL0o79eHdUyqI7-9mPA_4m_bg';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        imageList.value = data;
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Icon(Icons.arrow_back_ios,color: Colors.white,),
        title: Text("Aifer Test App",style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 50),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                color: Colors.white,
                child: Obx(() {
                  return imageList.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50,horizontal: 8),
                    child: StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      children: List.generate(imageList.length, (index) {
                        return StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: index % 2 == 0 ? 2 : 1,
                          child: ImageTile(imageUrl: imageList[index]['urls']['regular']),
                        );
                      }),
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class ImageTile extends StatelessWidget {
  final String imageUrl;

  ImageTile({required this.imageUrl});

  Future<void> _downloadImage(BuildContext context, String url) async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final response = await http.get(Uri.parse(url));
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image saved to: $filePath")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permission denied")),
        );
      }
    } catch (e) {
      print("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _downloadImage(context, imageUrl),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator(
                color: Colors.grey,
              ));
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Icon(Icons.error, color: Colors.red));
            },
          ),
        ),
      ),
    );
  }
}
