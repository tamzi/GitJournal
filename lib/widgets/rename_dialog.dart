import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

class RenameDialog extends StatefulWidget {
  final String oldPath;
  final String inputDecoration;
  final String dialogTitle;

  RenameDialog({
    @required this.oldPath,
    @required this.inputDecoration,
    @required this.dialogTitle,
  });

  @override
  _RenameDialogState createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  TextEditingController _textController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: basename(widget.oldPath));
  }

  @override
  Widget build(BuildContext context) {
    var form = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: widget.inputDecoration),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a name';
              }

              var newPath = join(dirname(widget.oldPath), value);
              if (FileSystemEntity.typeSync(newPath) !=
                  FileSystemEntityType.notFound) {
                return 'Already Exists';
              }
              return null;
            },
            autofocus: true,
            keyboardType: TextInputType.text,
            controller: _textController,
          ),
        ],
      ),
      autovalidate: true,
    );

    return AlertDialog(
      title: Text(widget.dialogTitle),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        FlatButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              var newName = _textController.text;
              Navigator.of(context).pop(newName);
            }
          },
          child: const Text("Rename"),
        ),
      ],
      content: form,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
