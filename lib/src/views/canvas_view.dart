import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_app_sample/src/models/rectangle_model.dart';
import 'package:flutter_drawing_app_sample/src/utils/painters/rectangle_painter.dart';
import 'package:dxf/dxf.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert';

import 'package:flutter_drawing_app_sample/src/views/widgets/draggable_rectangle.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({super.key});

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  //keeps track of current rectangle being drawn
  Offset? start;
  double width = 0;
  double fixedHeight = 0;
  //list of rectangles drawn
  List<RectangleModel> rectangles = [];

// scale to convert the canvas size to inches
  // 1 inch = 5 px in the canvas
  // 1 px = 0.2 inches
  double measurementScale = 0.2;
  // canvas size in inches
  Size get scaledCanvasSize => canvasSize * measurementScale;
  // canvas size in pixels

  Size canvasSize = Size.zero;

  bool isMobileView = false;

  @override
  Widget build(BuildContext context) {
    isMobileView = MediaQuery.of(context).size.width < 500;

    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: buildBottomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

            return SizedBox(
              width: canvasSize.width,
              height: canvasSize.height,
              child: Stack(
                children: [
                  //base canvas with GestureDetector to draw rectangles
                  Positioned.fill(
                    child: Container(
                      color: Colors.white,
                      child: fixedHeight == 0
                          ? const SizedBox.expand()
                          : GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onHorizontalDragStart: (details) {
                                setState(() {
                                  start = details.localPosition;
                                  start = Offset(
                                      start!.dx, start!.dy - fixedHeight / 2);
                                  width = 0;
                                });
                              },
                              onHorizontalDragUpdate: (details) {
                                if (start == null) return;
                                setState(() {
                                  double diff =
                                      details.localPosition.dx - start!.dx;
                                  if (diff < 0) {
                                    width = 0;
                                  } else {
                                    width = diff;
                                  }
                                });
                              },
                              onHorizontalDragEnd: (details) {
                                if (start != null && width > 0) {
                                  if (!checkOverlapOrOutOfBounds(RectangleModel(
                                      start: start!,
                                      width: width,
                                      height: fixedHeight))) {
                                    rectangles.add(
                                      RectangleModel(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch,
                                        start: start!,
                                        width: width,
                                        height: fixedHeight,
                                      ),
                                    );
                                    fixedHeight = 0;
                                  }
                                  start = null;
                                  width = 0;

                                  setState(() {});
                                }
                              },
                              child: Builder(builder: (context) {
                                if (start == null || width == 0) {
                                  return const SizedBox.expand();
                                }

                                return CustomPaint(
                                  painter: RectanglePainter(
                                    measurementScale: measurementScale,
                                    showMeasurements: true,
                                    start: start!,
                                    width: width,
                                    height: fixedHeight,
                                    color: Colors.black,
                                  ),
                                );
                              }),
                            ),
                    ),
                  ),
                  //drawn rectangles
                  ...(rectangles).map((element) {
                    return DraggableRectangle(
                      key: UniqueKey(),
                      measurementScale: measurementScale,
                      start: element.start,
                      width: element.width,
                      height: element.height,
                      onDragEnd: (newOffset) {
                        final newElement = element.copyWith(start: newOffset);
                        if (!checkOverlapOrOutOfBounds(newElement)) {
                          final newElement = element.copyWith(start: newOffset);
                          final index = rectangles.indexOf(element);
                          rectangles[index] = newElement;
                        }
                        setState(() {});
                      },
                      onResize: (offsetChange, newWidth, newHeight) {
                        Offset newStart = element.start + offsetChange;
                        final newElement = element.copyWith(
                            start: newStart,
                            width: newWidth,
                            height: newHeight);
                        if (!checkOverlapOrOutOfBounds(newElement)) {
                          final newElement = element.copyWith(
                              start: newStart,
                              width: newWidth,
                              height: newHeight);
                          final index = rectangles.indexOf(element);
                          rectangles[index] = newElement;
                        }

                        setState(() {});
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
      child: fixedHeight != 0
          ? Row(
              children: [
                const Text('Drag to draw a rectangle'),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      fixedHeight = 0;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            )
          : Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      fixedHeight = 25.5 / measurementScale;
                    });
                  },
                  child: const Text('New Kitchen Countertop'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      fixedHeight = 30 / measurementScale;
                    });
                  },
                  child: const Text('New Island'),
                ),
                if (isMobileView) ...[
                  const Spacer(),
                  PopupMenuButton(
                      child: const Icon(Icons.more_vert),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            onTap: showExportOptions,
                            child: const Text('Export'),
                          ),
                          PopupMenuItem(
                            child: const Text('Clear All'),
                            onTap: () {
                              setState(() {
                                fixedHeight = 0;
                                rectangles.clear();
                              });
                            },
                          ),
                        ];
                      })
                ] else ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        fixedHeight = 0;
                        rectangles.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                  TextButton(
                    onPressed: showExportOptions,
                    child: const Text('Export'),
                  )
                ]
              ],
            ),
    );
  }

  bool checkOverlapOrOutOfBounds(RectangleModel element) {
    Offset start = element.start;
    double width = element.width;
    double height = element.height;

    Rect newRect = Rect.fromPoints(
      start,
      Offset(start.dx + width, start.dy + height),
    );

    if (newRect.left < 0 ||
        newRect.top < 0 ||
        newRect.right > canvasSize.width ||
        newRect.bottom > canvasSize.height) {
      showSnackbar('Rectangle out of bounds');
      return true; // Out of bounds
    }

    for (var rectangle in rectangles) {
      if (rectangle.id == element.id) {
        continue; // Skip checking against itself (for resize check
      }

      Offset existingStart = rectangle.start;
      double existingWidth = rectangle.width;
      double existingHeight = rectangle.height;

      Rect existingRect = Rect.fromPoints(
        existingStart,
        Offset(existingStart.dx + existingWidth,
            existingStart.dy + existingHeight),
      );

      if (newRect.overlaps(existingRect)) {
        showSnackbar('Rectangles overlap');
        return true; // Overlaps with existing rectangle
      }
    }

    return false; // No overlap found
  }

  void showExportOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final dxf = exportDXF();

                  if (kIsWeb) {
                    await FileSaver.instance.saveFile(
                      name: 'drawing',
                      bytes: utf8.encode(dxf.dxfString),
                      ext: 'dxf',
                    );
                  } else {
                    bool status = await Permission.storage.isGranted;
                    if (Platform.isAndroid) {
                      status = await Permission.manageExternalStorage.isGranted;
                    }

                    if (!status) {
                      status = (await Permission.storage.request()).isGranted;
                      if (Platform.isAndroid) {
                        status =
                            (await Permission.manageExternalStorage.request())
                                .isGranted;
                      }
                    }

                    if (!status) {
                      showSnackbar('Permission denied');
                      return;
                    }

                    await FileSaver.instance.saveAs(
                        name: 'drawing',
                        ext: 'dxf',
                        mimeType: MimeType.custom,
                        customMimeType: 'image/x-dxf',
                        bytes: utf8.encode(dxf.dxfString));
                  }

                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Export to DXF'),
              ),
              if (!kIsWeb)
                TextButton(
                  onPressed: () async {
                    final dxf = exportDXF();

                    final directory = await getApplicationDocumentsDirectory();
                    final path = '${directory.path}/drawing.dxf';
                    final file = File(path);
                    await file.writeAsString(dxf.dxfString);

                    final MailOptions mailOptions = MailOptions(
                      subject: 'DXF file',
                      attachments: [path],
                      isHTML: false,
                    );

                    await FlutterMailer.send(mailOptions);

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Email DXF'),
                ),
            ],
          ),
        );
      },
    );
  }

  DXF exportDXF() {
    final dxf = DXF.create();
    for (var element in rectangles) {
      List<List<double>> points = [
        [
          element.start.dx * measurementScale,
          canvasSize.height - element.start.dy * measurementScale,
        ],
        [
          (element.start.dx + element.width) * measurementScale,
          canvasSize.height - element.start.dy * measurementScale,
        ],
        [
          (element.start.dx + element.width) * measurementScale,
          canvasSize.height -
              (element.start.dy + element.height) * measurementScale,
        ],
        [
          element.start.dx * measurementScale,
          canvasSize.height -
              (element.start.dy + element.height) * measurementScale,
        ],
      ];
      final polyline = AcDbPolyline(vertices: points, isClosed: true);
      dxf.addEntities(polyline);
    }
    return dxf;
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
