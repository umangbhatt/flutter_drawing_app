import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_app_sample/src/utils/painters/rectangle_painter.dart';

class DraggableRectangle extends StatefulWidget {
  final Offset start;
  final double width;
  final double height;
  final Function(Offset) onDragEnd;
  final Function(Offset, double, double) onResize;
  final double measurementScale;

  const DraggableRectangle(
      {required Key key,
      required this.start,
      required this.width,
      required this.height,
      required this.onDragEnd,
      required this.onResize,
      required this.measurementScale})
      : super(key: key);

  @override
  _DraggableElementState createState() => _DraggableElementState();
}

class _DraggableElementState extends State<DraggableRectangle> {
  late Offset position;
  late double width;
  late double height;

  bool highlightTopEdge = false;
  bool highlightBottomEdge = false;
  bool highlightLeftEdge = false;
  bool highlightRightEdge = false;

  @override
  void initState() {
    super.initState();
    position = widget.start;
    width = widget.width;
    height = widget.height;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: CustomPaint(
        painter: RectanglePainter(
          measurementScale: widget.measurementScale,
          start: const Offset(0, 0),
          width: width,
          height: height,
          color: Colors.black,
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      position += details.delta;
                    });
                  },
                  onPanEnd: (details) {
                    widget.onDragEnd(position);
                  },
                  child: const Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.move,
                      child: Icon(Icons.open_with),
                    ),
                  )),

              //right edge
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    showEdgeValueUpdateDialog(height, (newHeight) {
                      setState(() {
                        height = newHeight;
                      });
                      widget.onResize(Offset.zero, width, height);
                    });
                  },
                  onTapDown: (details) {
                    setState(() {
                      highlightRightEdge = true;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      highlightRightEdge = false;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      width += details.delta.dx;
                      if (width < 0) {
                        width = 0;
                      }
                    });
                  },
                  onPanEnd: (details) {
                    widget.onResize(Offset.zero, width, height);
                  },
                  child: MouseRegion(
                    onEnter: (event) {
                      setState(() {
                        highlightRightEdge = true;
                      });
                    },
                    onExit: (event) {
                      setState(() {
                        highlightRightEdge = false;
                      });
                    },
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: Container(
                      width: 10,
                      color: highlightRightEdge
                          ? Colors.blue.withOpacity(0.5)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),

              //left edge
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    showEdgeValueUpdateDialog(height, (newHeight) {
                      setState(() {
                        height = newHeight;
                      });
                      widget.onResize(Offset.zero, width, height);
                    });
                  },
                  onTapDown: (details) {
                    setState(() {
                      highlightLeftEdge = true;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      highlightLeftEdge = false;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      width -= details.delta.dx;
                      position += Offset(details.delta.dx, 0);
                      if (width < 0) {
                        width = 0;
                      }
                    });
                  },
                  onPanEnd: (details) {
                    widget.onResize(
                        Offset(details.localPosition.dx, 0), width, height);
                  },
                  child: MouseRegion(
                    onEnter: (event) {
                      setState(() {
                        highlightLeftEdge = true;
                      });
                    },
                    onExit: (event) {
                      setState(() {
                        highlightLeftEdge = false;
                      });
                    },
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: Container(
                      width: 10,
                      color: highlightLeftEdge
                          ? Colors.blue.withOpacity(0.5)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),

              //top edge
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      showEdgeValueUpdateDialog(width, (newWidth) {
                        setState(() {
                          width = newWidth;
                        });
                        widget.onResize(Offset.zero, width, height);
                      });
                    },
                    onTapDown: (details) {
                      setState(() {
                        highlightTopEdge = true;
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        highlightTopEdge = false;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      setState(() {
                        height -= details.delta.dy;
                        position += Offset(0, details.delta.dy);
                        if (height < 0) {
                          height = 0;
                        }
                      });
                    },
                    onPanEnd: (details) {
                      widget.onResize(
                          Offset(0, details.localPosition.dy), width, height);
                    },
                    child: MouseRegion(
                      onEnter: (event) {
                        setState(() {
                          highlightTopEdge = true;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          highlightTopEdge = false;
                        });
                      },
                      cursor: SystemMouseCursors.resizeUpDown,
                      child: Container(
                        height: 10,
                        color: highlightTopEdge
                            ? Colors.blue.withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                  )),

              //bottom edge
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      showEdgeValueUpdateDialog(width, (newWidth) {
                        setState(() {
                          width = newWidth;
                        });
                        widget.onResize(Offset.zero, width, height);
                      });
                    },
                    onTapDown: (details) {
                      setState(() {
                        highlightBottomEdge = true;
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        highlightBottomEdge = false;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      setState(() {
                        height += details.delta.dy;

                        if (height < 0) {
                          height = 0;
                        }
                      });
                    },
                    onPanEnd: (details) {
                      widget.onResize(Offset.zero, width, height);
                    },
                    child: MouseRegion(
                      onEnter: (event) {
                        setState(() {
                          highlightBottomEdge = true;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          highlightBottomEdge = false;
                        });
                      },
                      cursor: SystemMouseCursors.resizeUpDown,
                      child: Container(
                        height: 10,
                        color: highlightBottomEdge
                            ? Colors.blue.withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void showEdgeValueUpdateDialog(
      double initialValue, Function(double) onChanged) {
    final scaledInitialValue = initialValue * widget.measurementScale;

    final controller =
        TextEditingController(text: scaledInitialValue.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter new value'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isEmpty) {
                  return;
                }

                if (double.tryParse(controller.text) == null) {
                  return;
                }

                onChanged(
                    double.parse(controller.text) / widget.measurementScale);
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}