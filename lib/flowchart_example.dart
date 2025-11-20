import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class FlowchartExample extends StatefulWidget {
  @override
  _FlowchartExampleState createState() => _FlowchartExampleState();
}

class _FlowchartExampleState extends State<FlowchartExample> {
  final Graph graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    super.initState();

    // Nodos del diagrama
    final inicio = Node.Id("Inicio");
    final ingresar = Node.Id("Ingresar datos");
    final calcular = Node.Id("Calcular suma");
    final mostrar = Node.Id("Mostrar resultado");
    final fin = Node.Id("Fin");

    // Conexiones
    graph.addEdge(inicio, ingresar);
    graph.addEdge(ingresar, calcular);
    graph.addEdge(calcular, mostrar);
    graph.addEdge(mostrar, fin);

    // Configuración de layout
    builder
      ..siblingSeparation = (20)
      ..levelSeparation = (40)
      ..subtreeSeparation = (30)
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  Widget rectangleWidget(String text, {Color color = Colors.blue}) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ejemplo: Diagrama de Flujo")),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: EdgeInsets.all(50),
        minScale: 0.01,
        maxScale: 5.0,
        child: GraphView(
          graph: graph,
          algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
          paint: Paint()
            ..color = Colors.black
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
          builder: (Node node) {
            var label = node.key?.value as String;
            return rectangleWidget(label);
          },
        ),
      ),
    );
  }
}
// TODO Implement this library.