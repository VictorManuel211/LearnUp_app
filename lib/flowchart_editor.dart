import 'package:flutter/material.dart';
import 'dart:ui';

class FlowchartEditor extends StatefulWidget {
  @override
  _FlowchartEditorState createState() => _FlowchartEditorState();
}

class _FlowchartEditorState extends State<FlowchartEditor> {
  List<FlowNode> nodes = [];
  List<FlowConnection> connections = [];
  FlowNode? selectedNode;

  @override
  void initState() {
    super.initState();
    nodes = [
      FlowNode("Inicio", Offset(80, 100)),
      FlowNode("Sumar números", Offset(250, 250)),
      FlowNode("Fin", Offset(420, 100)),
    ];
  }

  void addNode() {
    setState(() {
      nodes.add(FlowNode("Nuevo nodo", Offset(100, 100)));
    });
  }

  void connectNode(FlowNode target) {
    if (selectedNode != null && selectedNode != target) {
      setState(() {
        connections.add(FlowConnection(selectedNode!, target));
        selectedNode = null;
      });
    }
  }

  void removeNode(FlowNode node) {
    setState(() {
      nodes.remove(node);
      connections.removeWhere((c) => c.from == node || c.to == node);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editor de Diagramas de Flujo")),
      body: Stack(
        children: [
          Container(color: Colors.grey[200]),

          // DIBUJAR FLECHAS
          CustomPaint(
            painter: FlowConnectionPainter(connections),
            child: Container(),
          ),

          // DIBUJAR NODOS
          ...nodes.map((node) {
            return Positioned(
              left: node.position.dx,
              top: node.position.dy,
              child: Draggable(
                feedback: flowNodeWidget(node, dragging: true),
                childWhenDragging: Container(),
                onDragEnd: (details) => setState(() {
                  node.position = details.offset;
                }),
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
                  child: flowNodeWidget(node,
                      selected: selectedNode == node),
                ),
              ),
            );
          }),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addNode,
        child: Icon(Icons.add),
      ),
    );
  }

  void _editNode(FlowNode node) async {
    final controller = TextEditingController(text: node.label);
    final newText = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Editar nodo"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text("Guardar"),
          ),
        ],
      ),
    );
    if (newText != null && newText.isNotEmpty) {
      setState(() => node.label = newText);
    }
  }

  Widget flowNodeWidget(FlowNode node, {bool dragging = false, bool selected = false}) {
    return Container(
      width: 130,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dragging
            ? Colors.blue.withOpacity(0.5)
            : (selected ? Colors.orange : Colors.blue),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
      ),
      child: Text(node.label, style: TextStyle(color: Colors.white)),
    );
  }
}

class FlowNode {
  String label;
  Offset position;
  FlowNode(this.label, this.position);
}

class FlowConnection {
  FlowNode from;
  FlowNode to;
  FlowConnection(this.from, this.to);
}

class FlowConnectionPainter extends CustomPainter {
  final List<FlowConnection> connections;
  FlowConnectionPainter(this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (var c in connections) {
      final start = c.from.position + Offset(65, 30);
      final end = c.to.position + Offset(65, 30);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
