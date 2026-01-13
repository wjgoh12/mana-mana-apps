import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerFromMemory extends StatelessWidget {
  final String property;
  final String? year;
  final String? month;
  final String? unitType;
  final String? unitNo;
  final Uint8List pdfData;

  PdfViewerFromMemory(
      {required this.property,
      required this.year,
      required this.month,
      required this.unitType,
      required this.unitNo,
      required this.pdfData});

  void share(RenderBox box) async {
    Directory dir = await getApplicationDocumentsDirectory();
    File file = File(
        '${dir.absolute.path}/${property}_${unitNo}_${getMonthName(month!)}_$year.pdf');
    await file.create(recursive: true);
    await file.writeAsBytes(pdfData);
    Rect sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;
    await Share.shareXFiles([XFile(file.absolute.path)],
        sharePositionOrigin: sharePositionOrigin);
  }

  String getMonthName(String month) {
    Map<String, String> monthMap = {
      '1': 'Jan',
      '2': 'Feb',
      '3': 'Mar',
      '4': 'Apr',
      '5': 'May',
      '6': 'Jun',
      '7': 'Jul',
      '8': 'Aug',
      '9': 'Sep',
      '10': 'Oct',
      '11': 'Nov',
      '12': 'Dec'
    };
    return monthMap[month] ?? month;
  }

  @override
  Widget build(BuildContext context) {
    final shareButtonKey = GlobalKey();
    Widget _shareButton = CircleAvatar(
      radius: 28,
      backgroundColor: Theme.of(context).primaryColor,
      child: IconButton(
          key: shareButtonKey,
          icon: const Icon(Icons.share, color: Colors.white),
          color: Theme.of(context).primaryColor,
          highlightColor: Theme.of(context).primaryColor,
          hoverColor: Theme.of(context).primaryColor,
          splashColor: Theme.of(context).primaryColor,
          focusColor: Theme.of(context).primaryColor,
          onPressed: () => share(
              shareButtonKey.currentContext?.findRenderObject() as RenderBox)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$property $unitNo - ${getMonthName(month ?? '')} $year',
          style: const TextStyle(fontSize: AppDimens.fontSizeBig,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _shareButton,
      body: SfPdfViewer.memory(
        pdfData,
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load PDF: ${details.error}')),
          );
        },
      ),
    );
  }
}
