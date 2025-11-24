// Archivo: uml_editor_with_export.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // para MatrixUtils.transformPoint
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';


class UmlEditor extends StatefulWidget {
  @override
  _UmlEditorState createState() => _UmlEditorState();
}

class _UmlEditorState extends State<UmlEditor> {
  bool showHelp = true;

  List<UmlNode> nodes = [];
  List<UmlConnection> connections = [];
  UmlNode? selectedNode;

  TransformationController controller = TransformationController();
  GlobalKey repaintKey = GlobalKey();

  // herramienta activa para crear nodos / tipo conexión
  UmlNodeType activeNodeType = UmlNodeType.classBox;
  ConnectionType activeConnectionType = ConnectionType.association;

  @override
  void initState() {
    super.initState();
    _loadFromPrefsOrDefault();
  }


  Future<void> _loadFromPrefsOrDefault() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('uml_diagram');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        final nodeList = (decoded['nodes'] as List).map((e) => UmlNode.fromJson(e)).toList();
        final connList = (decoded['connections'] as List).map((e) => UmlConnection.fromJson(e, nodeList)).toList();
        setState(() {
          nodes = nodeList;
          connections = connList;
        });
        return;
      } catch (e) {
        // ignore and create default
      }
    }


    // default example
    nodes = [
      UmlNode("Usuario", Offset(80, 80), UmlNodeType.classBox,
          attributes: ["nombre: String", "email: String"], methods: ["login()", "logout()"]),
      UmlNode("Cliente", Offset(320, 260), UmlNodeType.classBox, attributes: ["numCompras: int"], methods: ["comprar()"]),
      UmlNode("Administrador", Offset(560, 80), UmlNodeType.classBox, attributes: ["nivelAcceso: int"], methods: ["banearUsuario()"]),
    ];
    connections = [
      UmlConnection(nodes[0], nodes[1], ConnectionType.inheritance),
      UmlConnection(nodes[0], nodes[2], ConnectionType.inheritance),
    ];

    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'connections': connections.map((e) => e.toJson(nodes)).toList(),
    };
    await prefs.setString('uml_diagram', jsonEncode(map));
  }

  // Añadir nodo en una posición central del lienzo visible
  void addNodeAtCenter(UmlNodeType type) {
    final size = MediaQuery.of(context).size;
    final centerScreen = Offset(size.width / 2, size.height / 2);
    final sceneCenter = _globalToScene(centerScreen);

    setState(() {
      nodes.add(UmlNode(
        type == UmlNodeType.classBox ? "NuevaClase" : (type == UmlNodeType.interfaceBox ? "NuevaInterfaz" : "NuevoEnum"),
        sceneCenter,
        type,
      ));
    });
    _saveToPrefs();
  }

  void connectNode(UmlNode target) {
    if (selectedNode != null && selectedNode != target) {
      setState(() {
        connections.add(UmlConnection(selectedNode!, target, activeConnectionType));
        selectedNode = null;
      });
      _saveToPrefs();
    }
  }

  void removeNode(UmlNode node) {
    setState(() {
      nodes.remove(node);
      connections.removeWhere((c) => c.from == node || c.to == node);
      if (selectedNode == node) selectedNode = null;
    });
    _saveToPrefs();
  }

  void zoomIn() {
    setState(() {
      controller.value = Matrix4.identity()..scale(1.15 * _currentScale());
    });
  }

  void zoomOut() {
    setState(() {
      controller.value = Matrix4.identity()..scale(max(0.2, 0.85 * _currentScale()));
    });
  }

  double _currentScale() {
    return controller.value.getMaxScaleOnAxis();
  }

  // Convierte coordenada global a coordenada del scene
  Offset _globalToScene(Offset global) {
    final renderBox = context.findRenderObject() as RenderBox;
    final local = renderBox.globalToLocal(global);
    final matrix = controller.value;
    final inverted = Matrix4.inverted(matrix);
    final scenePoint = MatrixUtils.transformPoint(inverted, local);
    return scenePoint;
  }

  // Exportar JSON: mostrar JSON en diálogo y copiar
  void exportJSON() {
    final map = {'nodes': nodes.map((e) => e.toJson()).toList(), 'connections': connections.map((e) => e.toJson(nodes)).toList()};
    final pretty = const JsonEncoder.withIndent('  ').convert(map);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Exportar JSON'),
        content: SingleChildScrollView(child: SelectableText(pretty)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar')),
        ],
      ),
    );
  }

  // Exportar PNG: renderizar RepaintBoundary
  Future<void> exportPNG() async {
    try {
      RenderRepaintBoundary boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Mostrar la imagen en un diálogo
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('PNG generado'),
          content: SingleChildScrollView(child: Image.memory(pngBytes)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar'))],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PNG: \$e')));
    }
  }

  // DIALOGO DE EDICIÓN: nombre, atributos (una por linea), métodos (una por linea)
  void _editNodeDialog(UmlNode node) async {
    final nameController = TextEditingController(text: node.label);
    final attrController = TextEditingController(text: node.attributes.join('\n'));
    final methodController = TextEditingController(text: node.methods.join('\n'));

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar ${node.type == UmlNodeType.classBox ? 'Clase' : node.type == UmlNodeType.interfaceBox ? 'Interfaz' : 'Enum'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nombre')),
              SizedBox(height: 8),
              TextField(controller: attrController, decoration: InputDecoration(labelText: 'Atributos (una por línea)'), maxLines: 6),
              SizedBox(height: 8),
              TextField(controller: methodController, decoration: InputDecoration(labelText: 'Métodos (una por línea)'), maxLines: 6),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                node.label = nameController.text.trim();
                node.attributes = attrController.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                node.methods = methodController.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
              });
              _saveToPrefs();
              Navigator.pop(ctx, true);
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      // guardado
    }
  }

  bool isNearLine(Offset point, Offset a, Offset b) {
    const double tolerance = 12.0; // distancia para detectar toque

    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;

    // Si la línea es un punto, evita división por 0
    if (dx == 0 && dy == 0) return false;

    // Proyección escalar del punto sobre el segmento
    final t = ((point.dx - a.dx) * dx + (point.dy - a.dy) * dy) /
        (dx * dx + dy * dy);

    // Limitar t para que esté dentro del segmento
    final clampedT = t.clamp(0.0, 1.0);

    final closest = Offset(
      a.dx + clampedT * dx,
      a.dy + clampedT * dy,
    );

    // Distancia del toque al punto más cercano de la línea
    return (closest - point).distance <= tolerance;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editor de Diagramas UML'),
        actions: [
          IconButton(tooltip: 'Exportar JSON', icon: Icon(Icons.code), onPressed: exportJSON),
          IconButton(tooltip: 'Exportar PNG', icon: Icon(Icons.image), onPressed: exportPNG),
          IconButton(tooltip: 'Reset Zoom', icon: Icon(Icons.center_focus_strong), onPressed: () {
            setState(() {
              controller.value = Matrix4.identity();
            });
          }),
        ],
      ),
      body: Stack(
        children: [
          Container(color: Colors.grey[100]),

          // Lienzo grande dentro de InteractiveViewer
          RepaintBoundary(
            key: repaintKey,
            child: InteractiveViewer(
              constrained: false,
              transformationController: controller,
              minScale: 0.2,
              maxScale: 5.0,
              boundaryMargin: EdgeInsets.all(4000),
              child: SizedBox(
                width: 3000,
                height: 3000,
                child: Stack(
                  children: [
                    // Fondo cuadriculado
                    Positioned.fill(child: CustomPaint(painter: GridPainter())),

                    // Conexiones pintadas por debajo
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onLongPressStart: (details) {
                        final local = details.localPosition;

                        for (var c in List<UmlConnection>.from(connections)) {
                          final start = c.from.position + Offset(110, 50);
                          final end = c.to.position + Offset(110, 50);

                          if (isNearLine(local, start, end)) {
                            setState(() => connections.remove(c));
                            _saveToPrefs();
                            break;
                          }
                        }
                      },
                      child: CustomPaint(
                        painter: UmlConnectionPainter(connections),
                        size: Size(3000, 3000),
                      ),
                    ),

                    // NODOS
                    ...nodes.map((node) {
                      return Positioned(
                        left: node.position.dx,
                        top: node.position.dy,
                        child: Draggable<UmlNode>(
                          data: node,
                          feedback: Material(color: Colors.transparent, child: Transform.scale(scale: 1.0, child: node.buildWidget(selected: true))),
                          childWhenDragging: Opacity(opacity: 0.4, child: node.buildWidget()),
                          onDragEnd: (details) {
                            setState(() {
                              node.position = _globalToScene(details.offset);
                              _saveToPrefs();
                            });
                          },
                          child: GestureDetector(
                            onLongPress: () => _editNodeDialog(node),
                            onTap: () {
                              if (selectedNode == null) {
                                setState(() => selectedNode = node);
                              } else {
                                connectNode(node);
                              }
                            },
                            onDoubleTap: () => removeNode(node),
                            child: node.buildWidget(selected: selectedNode == node),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),

          // Panel de herramientas lateral
          Positioned(
            left: 10,
            top: 80,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Container(
                width: 72,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ToolButton(icon: Icons.class_, label: 'Clase', selected: activeNodeType == UmlNodeType.classBox, onTap: () {
                      setState(() {
                        activeNodeType = UmlNodeType.classBox;
                      });
                      addNodeAtCenter(UmlNodeType.classBox);
                    }),
                    SizedBox(height: 8),
                    ToolButton(icon: Icons.architecture, label: 'Interface', selected: activeNodeType == UmlNodeType.interfaceBox, onTap: () {
                      setState(() {
                        activeNodeType = UmlNodeType.interfaceBox;
                      });
                      addNodeAtCenter(UmlNodeType.interfaceBox);
                    }),
                    SizedBox(height: 8),
                    ToolButton(icon: Icons.list, label: 'Enum', selected: activeNodeType == UmlNodeType.enumBox, onTap: () {
                      setState(() {
                        activeNodeType = UmlNodeType.enumBox;
                      });
                      addNodeAtCenter(UmlNodeType.enumBox);
                    }),
                    Divider(),
                    // Selector de tipo de conexión
                    ConnectionToolToggle(active: activeConnectionType, onChanged: (t) {
                      setState(() {
                        activeConnectionType = t;
                      });
                    }),
                    Divider(),
                    Tooltip(message: 'Agregar nodo en el centro', child: IconButton(icon: Icon(Icons.add_box_outlined), onPressed: () => addNodeAtCenter(activeNodeType))),
                  ],
                ),
              ),
            ),
          ),

          // MENSAJE DE AYUDA SUPERPUESTO
          if (showHelp)
            Positioned(
              top: 20,
              left: 100,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 320,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Ayuda rápida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 8),
                    Text('• Toca un nodo y luego otro → crea conexión del tipo seleccionado.', style: TextStyle(color: Colors.white70)),
                    Text('• Mantén presionado un nodo → editar nombre, atributos, métodos.', style: TextStyle(color: Colors.white70)),
                    Text('• Doble tap → eliminar nodo.', style: TextStyle(color: Colors.white70)),
                    Text('• Panel izquierdo → herramientas y tipo de conexión.', style: TextStyle(color: Colors.white70)),
                    Text('• Manten presionado conexion para eliminar una.', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => setState(() => showHelp = false), child: Text('Cerrar')))
                  ]),
                ),
              ),
            ),

          // Botones flotantes (zoom)
          Positioned(
            right: 10,
            bottom: 10,
            child: Column(children: [
              Tooltip(message: 'Acercar', child: FloatingActionButton(heroTag: 'btnZoomIn', onPressed: zoomIn, mini: true, child: Icon(Icons.zoom_in))),
              SizedBox(height: 8),
              Tooltip(message: 'Alejar', child: FloatingActionButton(heroTag: 'btnZoomOut', onPressed: zoomOut, mini: true, child: Icon(Icons.zoom_out))),
            ]),
          ),
        ],
      ),
    );
  }
}

// MODELOS y utilidades

enum UmlNodeType { classBox, interfaceBox, enumBox }

enum ConnectionType { association, inheritance, implementation, aggregation, composition, dependency }

class UmlNode {
  String label;
  Offset position;
  UmlNodeType type;
  List<String> attributes;
  List<String> methods;

  UmlNode(this.label, this.position, this.type,
      {List<String>? attributes, List<String>? methods})
      : this.attributes = attributes ?? [],
        this.methods = methods ?? [];

  Widget buildWidget({bool selected = false}) {
    final color = type == UmlNodeType.classBox
        ? Colors.white
        : (type == UmlNodeType.interfaceBox
        ? Colors.blue.shade50
        : Colors.yellow.shade50);

    final borderColor = selected ? Colors.orange : Colors.black87;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        color: color,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // NOMBRE DE LA CLASE
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            width: double.infinity,
            color: Colors.grey[200],
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,   // <<< CAMBIO
              ),
            ),
          ),

          Divider(height: 1, color: Colors.black),

          // ATRIBUTOS
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: attributes.isEmpty
                ? SizedBox.shrink()
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: attributes.map(
                    (a) => Text(
                  "• $a",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,   // <<< CAMBIO
                  ),
                ),
              ).toList(),
            ),
          ),

          Divider(height: 1, color: Colors.black),

          // MÉTODOS
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: methods.isEmpty
                ? SizedBox.shrink()
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: methods.map(
                    (m) => Text(
                  "• $m",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,   // <<< CAMBIO
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }


  Map<String, dynamic> toJson() => {
    'label': label,
    'x': position.dx,
    'y': position.dy,
    'type': type.toString().split('.').last,
    'attributes': attributes,
    'methods': methods,
  };

  static UmlNode fromJson(Map<String, dynamic> j) {
    return UmlNode(
      j['label'] as String,
      Offset((j['x'] as num).toDouble(), (j['y'] as num).toDouble()),
      UmlNodeType.values.firstWhere(
            (e) => e.toString().split('.').last == (j['type'] as String),
        orElse: () => UmlNodeType.classBox,
      ),
      attributes:
      (j['attributes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      methods:
      (j['methods'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}


class UmlConnection {
  UmlNode from;
  UmlNode to;
  ConnectionType type;

  UmlConnection(this.from, this.to, this.type);

  Map<String, dynamic> toJson(List<UmlNode> nodePool) => {
    'from': nodePool.indexOf(from),
    'to': nodePool.indexOf(to),
    'type': type.toString().split('.').last,
  };

  static UmlConnection fromJson(Map<String, dynamic> j, List<UmlNode> nodePool) {
    final fromIdx = j['from'] as int;
    final toIdx = j['to'] as int;
    final typeStr = j['type'] as String;
    final type = ConnectionType.values.firstWhere((e) => e.toString().split('.').last == typeStr, orElse: () => ConnectionType.association);
    return UmlConnection(nodePool[fromIdx], nodePool[toIdx], type);
  }
}

// PINTOR DE CONEXIONES UML
class UmlConnectionPainter extends CustomPainter {
  final List<UmlConnection> connections;
  UmlConnectionPainter(this.connections);

  final Paint linePaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  // punto donde la línea toca el borde del nodo
  Offset _edgePoint(UmlNode a, UmlNode b) {
    const nodeWidth = 220;
    const nodeHeight = 120;

    final centerA = a.position + Offset(nodeWidth / 2, nodeHeight / 2);
    final centerB = b.position + Offset(nodeWidth / 2, nodeHeight / 2);

    final dx = centerB.dx - centerA.dx;
    final dy = centerB.dy - centerA.dy;

    final halfW = nodeWidth / 2;
    final halfH = nodeHeight / 2;

    final scaleX = halfW / dx.abs();
    final scaleY = halfH / dy.abs();
    final scale = min(scaleX, scaleY);

    return centerA + Offset(dx * scale, dy * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var c in connections) {
      final start = _edgePoint(c.from, c.to);
      final end = _edgePoint(c.to, c.from);

      switch (c.type) {
        case ConnectionType.association:
          _drawLine(canvas, start, end, solid: true);
          break;

        case ConnectionType.inheritance:
          _drawLine(canvas, start, end, solid: true);
          _drawInheritanceTriangle(canvas, start, end, filled: true);
          break;

        case ConnectionType.implementation:
          _drawLine(canvas, start, end, solid: false);
          _drawInheritanceTriangle(canvas, start, end, filled: false);
          break;

        case ConnectionType.aggregation:
          _drawLine(canvas, start, end, solid: true);
          _drawDiamond(canvas, start, end, filled: false);
          break;

        case ConnectionType.composition:
          _drawLine(canvas, start, end, solid: true);
          _drawDiamond(canvas, start, end, filled: true);
          break;

        case ConnectionType.dependency:
          _drawLine(canvas, start, end, solid: false);
          break;
      }
    }
  }

  void _drawLine(Canvas canvas, Offset a, Offset b, {bool solid = true}) {
    if (solid) {
      canvas.drawLine(a, b, linePaint);
    } else {
      _drawDashedLine(canvas, a, b, linePaint, dash: 8, gap: 6);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint,
      {double dash = 5, double gap = 5}) {
    final total = (b - a).distance;
    final dir = (b - a) / total;
    double drawn = 0;
    while (drawn < total) {
      canvas.drawLine(a + dir * drawn, a + dir * min(drawn + dash, total), paint);
      drawn += dash + gap;
    }
  }

  void _drawInheritanceTriangle(Canvas canvas, Offset a, Offset b,
      {bool filled = true}) {
    final angle = (b - a).direction;

    final tip = b;
    final base1 = tip - Offset(18 * cos(angle - 0.3), 18 * sin(angle - 0.3));
    final base2 = tip - Offset(18 * cos(angle + 0.3), 18 * sin(angle + 0.3));

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base1.dx, base1.dy)
      ..lineTo(base2.dx, base2.dy)
      ..close();

    final fill = Paint()
      ..color = filled ? Colors.white : Colors.white
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2;

    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawDiamond(Canvas canvas, Offset a, Offset b, {bool filled = false}) {
    final angle = (b - a).direction;
    final center = a + (b - a) * 0.12;
    const size = 12.0;

    final p1 = center + Offset(size * cos(angle), size * sin(angle));
    final p2 = center + Offset(size * cos(angle + pi / 2), size * sin(angle + pi / 2));
    final p3 = center + Offset(size * cos(angle + pi), size * sin(angle + pi));
    final p4 = center + Offset(size * cos(angle - pi / 2), size * sin(angle - pi / 2));

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    final fillPaint = Paint()
      ..color = filled ? Colors.black : Colors.white
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// Pintor de cuadrícula para estética
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade300..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget pequeño para botones del panel de herramientas
class ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const ToolButton({required this.icon, required this.label, required this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: selected ? Colors.blue.shade100 : Colors.black, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 22), SizedBox(height: 2), Text(label, style: TextStyle(fontSize: 9))],
        ),
      ),
    );
  }
}

// Selector gráfico de tipo de conexión
class ConnectionToolToggle extends StatelessWidget {
  final ConnectionType active;
  final ValueChanged<ConnectionType> onChanged;

  const ConnectionToolToggle({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget btn(ConnectionType t, IconData icon, String tooltip) {
      final isActive = active == t;
      return Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () => onChanged(t),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            width: 56,
            height: 36,
            decoration: BoxDecoration(color: isActive ? Colors.orange.shade100 : Colors.black, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
            child: Center(child: Icon(icon, size: 18)),
          ),
        ),
      );
    }

    return Column(children: [
      btn(ConnectionType.association, Icons.remove, 'Asociación (línea)'),
      btn(ConnectionType.inheritance, Icons.change_history, 'Herencia (triángulo)'),
      btn(ConnectionType.implementation, Icons.blur_linear, 'Implementación (punteada + triángulo)'),
      btn(ConnectionType.aggregation, Icons.circle_outlined, 'Agregación (rombo hueco)'),
      btn(ConnectionType.composition, Icons.circle, 'Composición (rombo lleno)'),
      btn(ConnectionType.dependency, Icons.show_chart, 'Dependencia (línea punteada)'),
    ]);
  }
}


