
import 'dart:convert';
import 'dart:io';

import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/services/argument_services.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:devjang_cs/widgets/dialogs.dart';
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
      await _storage.write(key: '${_pageProvider.selectDocsModel.title}note', value: contents);

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
      final contents = await _storage.read(key: '${_pageProvider.selectDocsModel.title}note');
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
          Padding(
            padding: EdgeInsets.only(bottom: 20.0, left: screenWidth * 0.1, right: screenWidth * 0.1),
            child: quilBody(context, screenWidth, screenHeight),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0, left: screenWidth * 0.1, right: screenWidth * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () async {
                      _saveNote();
                      _pageProvider.updatePage(6);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          color: _colorsModel.wh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _colorsModel.bl),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text('저장 & 읽기자료 보기', style: TextStyle(
                            color: _colorsModel.bl,
                            fontSize: 16,
                          ),textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _loading = true;
                      });

                      final contents = jsonEncode(_quillController.document.toDelta().toJson());
                      List resList = await ArgumentServices().saveNote(key: _pageProvider.selectDocsModel.key ?? "", uid: AuthService().getUid() ?? "", contents: contents);

                      setState(() {
                        _loading = false;
                      });

                      if (!resList.first) {
                        Dialogs().onlyContentOneActionDialog(context: context, content: '제출오류\n${resList.last}', firstText: '확인');
                      } else {
                        Dialogs().onlyContentOneActionDialog(context: context, content: '제출이 완료되었습니다.', firstText: '확인');
                      }
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          color: _colorsModel.wh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _colorsModel.bl),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text('제출하기', style: TextStyle(
                            color: _colorsModel.bl,
                            fontSize: 16,
                          ),textAlign: TextAlign.center,),
                        ),
                      ),
                    ),
                  ),
                ],
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
