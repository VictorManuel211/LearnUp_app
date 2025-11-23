import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class UmlExample extends StatefulWidget {
  @override
  _UmlExampleState createState() => _UmlExampleState();
}

class _UmlExampleState extends State<UmlExample> {
  final Graph graph = Graph()..isTree = true;
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    super.initState();

    // ----- CLASES UML -----
    final manzanas = Node.Id("Manzanas");
    final verdes = Node.Id("Manzanas Verdes");
    final rojas = Node.Id("Manzanas Rojas");
    final bicolores = Node.Id("Manzanas Bicolores");
    final empacar = Node.Id("Empacar");
    final agricultor = Node.Id("Agricultor");

    // RELACIONES (flechas tipo herencia/composición)
    graph.addEdge(manzanas, verdes);
    graph.addEdge(manzanas, rojas);
    graph.addEdge(manzanas, bicolores);

    graph.addEdge(empacar, manzanas);
    graph.addEdge(agricultor, manzanas);

    // Configuración visual
    builder
      ..siblingSeparation = 40
      ..levelSeparation = 60
      ..subtreeSeparation = 50
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  // ----- WIDGET DE CLASE UML (versión estilo imagen) -----
  Widget umlClassWidget(String className) {
    Map<String, Map<String, List<String>>> umlData = {
      "Manzanas": {
        "attributes": ["+ Estado", "+ Tamaño"],
        "methods": []
      },
      "Agricultor": {
        "attributes": [],
        "methods": ["+ Agrupar()", "+ Clasificar()", "+ Empacar()"]
      },
      "Empacar": {
        "attributes": [],
        "methods": []
      },
      "Manzanas Verdes": {"attributes": [], "methods": []},
      "Manzanas Rojas": {"attributes": [], "methods": []},
      "Manzanas Bicolores": {"attributes": [], "methods": []},
    };

    final data = umlData[className] ??
        {"attributes": [], "methods": []};

    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: Colors.yellow[200], // Amarillo UML clásico
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // -------- NOMBRE DE CLASE ----------
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              className,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),

          Divider(height: 1, color: Colors.black),

          // ---------- ATRIBUTOS ----------
          if (data["attributes"]!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data["attributes"]!
                    .map((e) => Text(
                  e,
                  style: TextStyle(color: Colors.black, fontSize: 13),
                ))
                    .toList(),
              ),
            ),

          Divider(height: 1, color: Colors.black),

          // --------- MÉTODOS ----------
          if (data["methods"]!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data["methods"]!
                    .map((e) => Text(
                  e,
                  style: TextStyle(color: Colors.black, fontSize: 13),
                ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Diagrama UML Estilo Imagen")),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: EdgeInsets.all(120),
        minScale: 0.1,
        maxScale: 5,
        child: GraphView(
          graph: graph,
          algorithm:
          BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
          paint: Paint()
            ..color = Colors.white
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
          builder: (Node node) {
            String name = node.key?.value.toString() ?? "";
            return umlClassWidget(name);
          },
        ),
      ),
    );
  }
}

