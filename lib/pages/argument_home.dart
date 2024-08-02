import 'package:devjang_cs/widgets/note_widget.dart';
import 'package:flutter/material.dart';

class ArgumentHome extends StatefulWidget {
  const ArgumentHome({Key? key}) : super(key: key);

  @override
  State<ArgumentHome> createState() => _ArgumentHomeState();
}

class _ArgumentHomeState extends State<ArgumentHome> {
  @override
  Widget build(BuildContext context) {
    return NoteWidget();
  }
}
