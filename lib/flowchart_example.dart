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
    final usuario = Node.Id("Usuario");
    final cliente = Node.Id("Cliente");
    final admin = Node.Id("Administrador");

    // Relación de herencia
    graph.addEdge(usuario, cliente);
    graph.addEdge(usuario, admin);

    // Configuración visual
    builder
      ..siblingSeparation = 40
      ..levelSeparation = 60
      ..subtreeSeparation = 50
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  // Cada clase UML como un rectángulo con 3 secciones
  Widget umlClassWidget(String className) {
    Map<String, Map<String, List<String>>> umlData = {
      "Usuario": {
        "attributes": ["+ nombre: String", "+ email: String"],
        "methods": ["+ login()", "+ logout()"]
      },
      "Cliente": {
        "attributes": ["+ numCompras: int"],
        "methods": ["+ comprar()"]
      },
      "Administrador": {
        "attributes": ["+ nivelAcceso: int"],
        "methods": ["+ banearUsuario()"]
      }
    };

    final data = umlData[className] ??
        {"attributes": [], "methods": []};

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // NOMBRE DE LA CLASE
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              className,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          Divider(height: 1, color: Colors.black),

          // ATRIBUTOS
          if (data["attributes"]!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: data["attributes"]!
                    .map((e) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(e, style: TextStyle(fontSize: 13)),
                ))
                    .toList(),
              ),
            ),

          Divider(height: 1, color: Colors.black),

          // MÉTODOS
          if (data["methods"]!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: data["methods"]!
                    .map((e) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(e, style: TextStyle(fontSize: 13)),
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
      appBar: AppBar(title: Text("Ejemplo: Diagrama UML")),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 5.0,
        child: GraphView(
          graph: graph,
          algorithm:
          BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
          paint: Paint()
            ..color = Colors.black
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
