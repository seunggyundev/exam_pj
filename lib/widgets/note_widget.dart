
import 'dart:convert';
import 'dart:io';

import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quil;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NoteWidget extends StatefulWidget {
  const NoteWidget({Key? key,}) : super(key: key);

  @override
  State<NoteWidget> createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  ColorsModel _colorsModel = ColorsModel();
  bool _loading = false;
  PageProvider _pageProvider = PageProvider();
  late quil.QuillController _quillController;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _quillController = quil.QuillController.basic();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadNote();
    });
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    setState(() {
      _loading = true;
    });

    try {
      final contents = jsonEncode(_quillController.document.toDelta().toJson());
      await _storage.write(key: '${_pageProvider.selectDocNm}note', value: contents);

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('노트가 성공적으로 저장되었습니다.')),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('노트를 저장하는 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _loadNote() async {
    setState(() {
      _loading = true;
    });

    try {
      final contents = await _storage.read(key: '${_pageProvider.selectDocNm}note');
      if (contents != null) {
        final document = quil.Document.fromJson(jsonDecode(contents));
        _quillController = quil.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        _quillController = quil.QuillController.basic();
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('노트를 불러오는 중 오류가 발생했습니다: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    _pageProvider = Provider.of<PageProvider>(context, listen: true);

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Stack(
        children: [
          quilBody(context, screenWidth, screenHeight),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () async {
                _saveNote();
              },
              child: Container(
                width: screenWidth,
                height: 80,
                decoration: BoxDecoration(
                  color: _colorsModel.main,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text('등록하기', style: TextStyle(
                      color: _colorsModel.wh,
                      fontSize: 16,
                    ),),
                  ),
                ),
              ),
            ),
          ),
          _loading ? Center(child: CircularProgressIndicator(color: _colorsModel.main,),) : Container(),
        ],
      ),
    );
  }

  Widget quilBody(context, screenWidth, screenHeight) {
    return Container(
      width: screenWidth,
      // height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          quil.QuillToolbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  QuillToolbarHistoryButton(
                    isUndo: true,
                    controller: _quillController,
                  ),
                  QuillToolbarHistoryButton(
                    isUndo: false,
                    controller: _quillController,
                  ),
                  QuillToolbarToggleStyleButton(
                    options: const QuillToolbarToggleStyleButtonOptions(),
                    controller: _quillController,
                    attribute: Attribute.bold,
                  ),
                  QuillToolbarToggleStyleButton(
                    options: const QuillToolbarToggleStyleButtonOptions(),
                    controller: _quillController,
                    attribute: Attribute.italic,
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.underline,
                  ),
                  QuillToolbarClearFormatButton(
                    controller: _quillController,
                  ),
                  const VerticalDivider(),
                  // QuillToolbarImageButton(
                  //   controller: _quillController,
                  // ),
                  // QuillToolbarCameraButton(
                  //   controller: _quillController,
                  // ),
                  QuillToolbarCustomButton(
                    controller: _quillController,
                  ),
                  const VerticalDivider(),
                  QuillToolbarColorButton(
                    controller: _quillController,
                    isBackground: false,
                  ),
                  QuillToolbarColorButton(
                    controller: _quillController,
                    isBackground: true,
                  ),
                  const VerticalDivider(),
                  QuillToolbarToggleCheckListButton(
                    controller: _quillController,
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.ol,
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.ul,
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.inlineCode,
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.blockQuote,
                  ),
                  QuillToolbarIndentButton(
                    controller: _quillController,
                    isIncrease: true,
                  ),
                  QuillToolbarIndentButton(
                    controller: _quillController,
                    isIncrease: false,
                  ),
                  const VerticalDivider(),
                  QuillToolbarLinkStyleButton(controller: _quillController),
                ],
              ),
            ),
          ),
          quil.QuillEditor.basic(
            configurations: quil.QuillEditorConfigurations(
              minHeight: 400,
              controller: _quillController,
              autoFocus: false,
              showCursor: true,
              textSelectionThemeData: TextSelectionThemeData(cursorColor: _colorsModel.bl, selectionColor: _colorsModel.bl, selectionHandleColor: _colorsModel.bl,),
              customStyles: DefaultStyles(
                color: _colorsModel.bl,
              ),
              sharedConfigurations: const quil.QuillSharedConfigurations(
                locale: Locale('ko'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
