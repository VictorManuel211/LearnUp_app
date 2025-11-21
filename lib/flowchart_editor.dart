import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

class UmlEditor extends StatefulWidget {
  @override
  _UmlEditorState createState() => _UmlEditorState();
}

class _UmlEditorState extends State<UmlEditor> {
  List<UmlNode> nodes = [];
  List<UmlConnection> connections = [];
  UmlNode? selectedNode;

  TransformationController controller = TransformationController();
  double currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    nodes = [
      UmlNode("ClaseInicio", Offset(80, 80), UmlNodeType.classBox),
      UmlNode("Operación", Offset(260, 260), UmlNodeType.interfaceBox),
      UmlNode("ClaseFin", Offset(450, 80), UmlNodeType.classBox),
    ];
  }

  void addNode(UmlNodeType type) {
    setState(() {
      nodes.add(
        UmlNode(
          type == UmlNodeType.classBox ? "Nueva Clase" : "Nueva Interfaz",
          Offset(100, 100),
          type,
        ),
      );
    });
  }

  void connectNode(UmlNode target) {
    if (selectedNode != null && selectedNode != target) {
      setState(() {
        connections.add(UmlConnection(selectedNode!, target));
        selectedNode = null;
      });
    }
  }

  void removeNode(UmlNode node) {
    setState(() {
      nodes.remove(node);
      connections.removeWhere((c) => c.from == node || c.to == node);
    });
  }

  void zoomIn() {
    setState(() {
      currentScale += 0.1;
      controller.value = Matrix4.identity()..scale(currentScale);
    });
  }

  void zoomOut() {
    setState(() {
      currentScale -= 0.1;
      if (currentScale < 0.2) currentScale = 0.2;
      controller.value = Matrix4.identity()..scale(currentScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editor de Diagramas UML")),
      body: Stack(
        children: [
          Container(color: Colors.grey[200]),

          InteractiveViewer(
            transformationController: controller,
            minScale: 0.2,
            maxScale: 5.0,
            boundaryMargin: EdgeInsets.all(1000), // puedes moverte libremente
            child: SizedBox(
              width: 3000,    // espacio enorme de trabajo
              height: 3000,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: UmlConnectionPainter(connections),
                  ),

                  ...nodes.map((node) {
                    return Positioned(
                      left: node.position.dx,
                      top: node.position.dy,
                      child: Draggable(
                        feedback: umlNodeWidget(node, dragging: true),
                        childWhenDragging: Container(),
                        onDragEnd: (details) {
                          setState(() {
                            node.position = controller.toScene(details.offset);
                          });
                        },
                        child: GestureDetector(
                          onLongPress: () => _editNode(node),
                          onTap: () {
                            if (selectedNode == null) {
                              setState(() => selectedNode = node);
                            } else {
                              connectNode(node);
                            }
                          },
                          onDoubleTap: () => removeNode(node),
                          child: umlNodeWidget(node, selected: selectedNode == node),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),


          Positioned(
            right: 10,
            bottom: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "btnClass",
                  onPressed: () => addNode(UmlNodeType.classBox),
                  child: Icon(Icons.class_),
                  tooltip: "Agregar Clase",
                ),
                SizedBox(height: 15),

                FloatingActionButton(
                  heroTag: "btnInterface",
                  onPressed: () => addNode(UmlNodeType.interfaceBox),
                  child: Icon(Icons.architecture),
                  tooltip: "Agregar Interfaz",
                ),
                SizedBox(height: 15),

                FloatingActionButton(
                  heroTag: "btnZoomIn",
                  onPressed: zoomIn,
                  child: Icon(Icons.zoom_in),
                ),
                SizedBox(height: 15),

                FloatingActionButton(
                  heroTag: "btnZoomOut",
                  onPressed: zoomOut,
                  child: Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editNode(UmlNode node) async {
    final controllerText = TextEditingController(text: node.label);
    final newText = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Editar elemento UML"),
        content: TextField(controller: controllerText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controllerText.text),
            child: Text("Guardar"),
          ),
        ],
      ),
    );
    if (newText != null && newText.isNotEmpty) {
      setState(() => node.label = newText);
    }
  }

  Widget umlNodeWidget(UmlNode node,
      {bool dragging = false, bool selected = false}) {
    Color color = node.type == UmlNodeType.classBox
        ? Colors.blue
        : Colors.green;

    return Container(
      width: 150,
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dragging
            ? color.withOpacity(0.5)
            : (selected ? Colors.orange : color),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
      ),
      child: Text(
        node.label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

enum UmlNodeType { classBox, interfaceBox }

class UmlNode {
  String label;
  Offset position;
  UmlNodeType type;

  UmlNode(this.label, this.position, this.type);
}

class UmlConnection {
  UmlNode from;
  UmlNode to;

  UmlConnection(this.from, this.to);
}

class UmlConnectionPainter extends CustomPainter {
  final List<UmlConnection> connections;

  UmlConnectionPainter(this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (var c in connections) {
      final start = c.from.position + Offset(75, 35);
      final end = c.to.position + Offset(75, 35);

      canvas.drawLine(start, end, paint);

      _drawArrow(canvas, start, end, paint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double arrowSize = 10;

    final angle = (end - start).direction;

    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowSize * cos(angle - 0.3),
      end.dy - arrowSize * sin(angle - 0.3),
    );
    path.lineTo(
      end.dx - arrowSize * cos(angle + 0.3),
      end.dy - arrowSize * sin(angle + 0.3),
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

