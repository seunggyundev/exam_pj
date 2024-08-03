import 'dart:async';
import 'dart:io';
import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/widgets/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PdfViewerWidget extends StatefulWidget {
  const PdfViewerWidget();

  @override
  _PdfViewerWidgetState createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  String? pdfPath;
  bool _loading = false;
  ColorsModel _colorsModel = ColorsModel();
  PageProvider _pageProvider = PageProvider();
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadPdf();
    });
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _loading = true;
      });

      final cacheManager = DefaultCacheManager();
      final url = _pageProvider.selectDocsModel.doc ?? "";

      // 캐시에서 파일 불러오기
      final fileInfo = await cacheManager.getFileFromCache(url);
      print('fileInfo ${fileInfo}');
      if (fileInfo != null && fileInfo.file.existsSync()) {
        setState(() {
          pdfPath = fileInfo.file.path;
        });
      } else {
        // Firebase Storage에서 파일 불러오기
        final ref = FirebaseStorage.instance.refFromURL(url);
        final downloadUrl = await ref.getDownloadURL();
        final file = await cacheManager.getSingleFile(downloadUrl);
        setState(() {
          pdfPath = file.path;
        });
      }

      setState(() {
        _loading = false;
      });
    } catch(e) {
      print("error load pdf $e");
      setState(() {
        _loading = false;
      });
      Dialogs().onlyContentOneActionDialog(context: context, content: '자료로드 오류\n${e}', firstText: '확인');
    }
  }

  @override
  Widget build(BuildContext context) {
    _pageProvider = Provider.of<PageProvider>(context, listen: true);

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: <Widget>[
        SizedBox(
          height: screenHeight * 0.8,
          child: Column(
            children: [
              pdfPath != null
                  ? SfPdfViewer.file(
                File(pdfPath!),
                controller: _pdfViewerController,
              )
                  : Container(),
              _loading
                  ? Center(
                child: CircularProgressIndicator(
                  color: _colorsModel.main,
                ),
              )
                  : Container(),
            ],
          ),
        ),
        const SizedBox(height: 15,),
        GestureDetector(
          onTap: () {
            _pageProvider.updatePage(7);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: screenWidth * 0.4,
              decoration: BoxDecoration(
                border: Border.all(color: _colorsModel.bl),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Center(
                  child: Text("에세이 작성하기", style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
