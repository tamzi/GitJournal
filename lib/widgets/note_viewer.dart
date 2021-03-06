import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';

class NoteViewer extends StatelessWidget {
  final Note note;
  const NoteViewer({Key key, @required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    theme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        body1: theme.textTheme.subhead,
      ),
    );

    // Copied from MarkdownStyleSheet except Grey is replaced with Highlight color
    var markdownStyleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      code: theme.textTheme.body1.copyWith(
        backgroundColor: theme.dialogBackgroundColor,
        fontFamily: "monospace",
        fontSize: theme.textTheme.body1.fontSize * 0.85,
      ),
      tableBorder: TableBorder.all(color: theme.highlightColor, width: 0),
      tableCellsDecoration: BoxDecoration(color: theme.dialogBackgroundColor),
      codeblockDecoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: BorderRadius.circular(2.0),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 5.0, color: theme.highlightColor),
        ),
      ),
    );

    var view = SingleChildScrollView(
      child: Column(
        children: <Widget>[
          if (note.canHaveMetadata) NoteTitleHeader(note.title),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: MarkdownBody(
              data: note.body,
              styleSheet: markdownStyleSheet,
              onTapLink: (String link) {
                if (link.startsWith('./')) {
                  final rootFolder = Provider.of<NotesFolderFS>(context);
                  var spec = link.substring(2);
                  var note = rootFolder.getNoteWithSpec(spec);
                  if (note != null) {
                    openNoteEditor(context, note);
                  } else {
                    showSnackbar(context, "Link '$link' not found");
                  }
                } else {
                  print("Launching " + link);
                  launch(link);
                }
              },
              imageDirectory: note.parent.folderPath + p.separator,
            ),
          ),
          // _buildFooter(context),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: const EdgeInsets.all(16.0),
    );

    return Hero(tag: note.filePath, child: view);
  }

  /*
  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_left),
            tooltip: 'Previous Entry',
            onPressed: showPrevNoteFunc,
          ),
          Expanded(
            flex: 10,
            child: Text(''),
          ),
          IconButton(
            icon: Icon(Icons.arrow_right),
            tooltip: 'Next Entry',
            onPressed: showNextNoteFunc,
          ),
        ],
      ),
    );
  }
  */
}

class NoteTitleHeader extends StatelessWidget {
  final String header;
  NoteTitleHeader(this.header);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(header, style: textTheme.title),
    );
  }
}
