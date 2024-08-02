import 'dart:io';

import 'package:devjang_cs/providers/page_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerWidget extends StatefulWidget {
  final fileUrl;
  const PdfViewerWidget({required this.fileUrl});

  @override
  _PdfViewerWidgetState createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final cacheManager = DefaultCacheManager();
    final url = widget.fileUrl;

    // 캐시에서 파일 불러오기
    final fileInfo = await cacheManager.getFileFromCache(url);
    if (fileInfo != null && fileInfo.file.existsSync()) {
      setState(() {
        pdfPath = fileInfo.file.path;
      });
    } else {
      // Firebase Storage에서 파일 불러오기
      final file = await cacheManager.getSingleFile(url);
      setState(() {
        pdfPath = file.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: pdfPath == null
          ? Center(child: CircularProgressIndicator())
          : SfPdfViewer.file(File(pdfPath!)),
    );
  }
}
