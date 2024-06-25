import 'package:flutter/material.dart';
import 'package:flutter_drawing_app_sample/src/utils/painters/rectangle_painter.dart';
import 'package:dxf/dxf.dart';
import 'dart:html' as html;
import 'dart:convert';

import 'package:flutter_drawing_app_sample/src/views/widgets/draggable_rectangle.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<Map<String, dynamic>> elements = [];

  // scale to convert the canvas size to inches
  // 1 inch = 5 px in the canvas
  // 1 px = 0.2 inches
  double measurementScale = 0.2;

  // canvas size in inches
  Size scaledCanvasSize = const Size(200, 200);
  // canvas size in pixels
  Size get canvasSize => scaledCanvasSize / measurementScale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: buildBottomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: SizedBox(
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
                                elements.add({
                                  'start': start,
                                  'width': width,
                                  'height': fixedHeight,
                                });
                                start = null;
                                width = 0;
                                fixedHeight = 0;

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
                ...elements.map((element) {
                  return DraggableRectangle(
                    measurementScale: measurementScale,
                    key: UniqueKey(),
                    start: element['start'],
                    width: element['width'],
                    height: element['height'],
                    onDragEnd: (newOffset) {
                      setState(() {
                        element['start'] = newOffset;
                      });
                    },
                    onResize: (offsetChange, newWidth, newHeight) {
                      setState(() {
                        element['width'] = newWidth;
                        element['start'] += offsetChange;
                        element['height'] = newHeight;
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
      child: fixedHeight != 0
          ? Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      fixedHeight = 0;
                    });
                  },
                  child: const Text('Cancel')),
            )
          : Row(
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        fixedHeight = 25.5 / measurementScale;
                      });
                    },
                    child: const Text('New Kitchen Countertop')),
                TextButton(
                    onPressed: () {
                      setState(() {
                        fixedHeight = 30 / measurementScale;
                      });
                    },
                    child: const Text('New Island')),
                TextButton(
                    onPressed: () {
                      setState(() {
                        fixedHeight = 0;
                        elements.clear();
                      });
                    },
                    child: const Text('Clear All')),
                TextButton(
                  onPressed: showExportOptions,
                  child: const Text(
                    'Export',
                  ),
                )
              ],
            ),
    );
  }

  void showExportOptions() {
    //option to download the DXF file
    //option to email the DXF file

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Export Options'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    final dxf = exportDXF();
                    // Convert DXF document to a Blob
                    final blob =
                        html.Blob([dxf.dxfString], 'text/plain;charset=utf-8');

                    // Create an object URL for the Blob
                    final url = html.Url.createObjectUrlFromBlob(blob);

                    // Create a download link and click it programmatically
                    final anchor = html.AnchorElement(href: url)
                      ..setAttribute('download', 'drawing.dxf');
                    anchor.click();

                    // Revoke the object URL to free resources
                    html.Url.revokeObjectUrl(url);

                    Navigator.pop(context);
                  },
                  child: const Text('Export to DXF'),
                ),
                TextButton(
                  onPressed: () {
                    final dxf = exportDXF();

                    // Convert DXF content to base64
                    final dxfContent = dxf.dxfString;
                    final bytes = utf8.encode(dxfContent);
                    final base64Data = base64.encode(bytes);

                    // Prepare email link
                    const emailBody = 'Here is the DXF file attachment.';
                    const subject = 'DXF File Attachment';
                    final emailLink = Uri.encodeFull(
                        'mailto:?subject=$subject&body=$emailBody&attachment=data:application/octet-stream;base64,$base64Data');

                    launchUrl(Uri.parse(emailLink));

                    Navigator.pop(context);
                  },
                  child: const Text('Email DXF'),
                ),
              ],
            ),
          );
        });
  }

  DXF exportDXF() {
    final dxf = DXF.create();

    for (var element in elements) {
      //the points of the rectangle need to be scaled
      //and flipped vertically since the origin of the DXF is at the bottom left
      //and the origin of the canvas is at the top left

      List<List<double>> points = [
        [
          element['start'].dx * measurementScale,
          canvasSize.height - element['start'].dy * measurementScale
        ],
        [
          (element['start'].dx + element['width']) * measurementScale,
          canvasSize.height - element['start'].dy * measurementScale
        ],
        [
          (element['start'].dx + element['width']) * measurementScale,
          canvasSize.height -
              (element['start'].dy + element['height']) * measurementScale
        ],
        [
          element['start'].dx * measurementScale,
          canvasSize.height -
              (element['start'].dy + element['height']) * measurementScale
        ],
      ];

      final polyline = AcDbPolyline(vertices: points, isClosed: true);
      dxf.addEntities(polyline);
    }

    return dxf;
  }
}
