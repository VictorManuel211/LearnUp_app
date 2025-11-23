import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'database/quiz_dao.dart';
import 'flowchart_example.dart';
import 'flowchart_editor.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:diacritic/diacritic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(milliseconds: 200));

  final userId = await UserManager.getOrCreateUser();

  runApp(BuenasPracticasApp(userId: userId));
}

///  APP PRINCIPAL
class BuenasPracticasApp extends StatelessWidget {
  final String userId;
  const BuenasPracticasApp({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buenas Prácticas de Programación',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        primaryColor: const Color(0xFF00FFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Color(0xFF00FFFF),
          iconTheme: IconThemeData(color: Color(0xFF00FFFF)),
          elevation: 4,
          shadowColor: Color(0xFF00FFFF),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF00FFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: HomeScreen(userId: userId),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({required this.userId, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  bool _showPNJ = true;

  @override
  void initState() {
    super.initState();
    _loadPNJState();
  }

  Future<void> _loadPNJState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showPNJ = prefs.getBool("show_pnj") ?? true;
    });
  }

  void _hidePNJ() {
    setState(() => _showPNJ = false);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      BienvenidaScreen(userId: widget.userId),
      TheoryScreen(),
      ExamplesScreen(),
      QuizScreen(),
      AssistantScreen(),
    ];

    return Scaffold(
      extendBody: true,

      body: Stack(
        children: [

          /// 🔥 NEON CYBERPUNK BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                radius: 1.2,
                colors: [
                  Color(0xFF0A0017), // oscuro profundo
                  Color(0xFF12002A), // púrpura suave
                  Color(0xFF00101A), // azul muy oscuro
                ],
                center: Alignment(0.4, -0.4),
              ),
            ),
          ),

          /// 🌐 Glow sutil alrededor (como neblina neon)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.cyan.withOpacity(0.06),
                  Colors.purple.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          /// Pantalla actual
          screens[_index],


          ///  PNJ flotante con glow neon
          if (_showPNJ)
            Positioned(
              right: 20,
              bottom: 100,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _index = 4),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.5),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/assistant/pnj.png',
                        height: 295,
                      ),
                    ),
                  ),

                  ///  Botón cerrar estilo neon minimal
                  Positioned(
                    right: -5,
                    top: -5,
                    child: GestureDetector(
                      onTap: _hidePNJ,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black87,
                          border: Border.all(
                            color: Colors.cyanAccent,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.6),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),

      /// 🟦 NAVBAR estilo GLASS NEON CYBERPUNK
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.cyanAccent.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.75),
                  Colors.black.withOpacity(0.45),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.25),
                  blurRadius: 20,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              selectedItemColor: Colors.cyanAccent,
              unselectedItemColor: Colors.purpleAccent.withOpacity(0.6),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book),
                  label: 'Teoría',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.code),
                  label: 'Ejemplos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.quiz),
                  label: 'Evaluaciones',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble),
                  label: 'Asistente',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




/// 🔹 PNJ FLOTANTE SIN SOMBRA
class PNJAssistant extends StatefulWidget {
  final String assetPath;
  final VoidCallback? onTap;

  const PNJAssistant({
    required this.assetPath,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _PNJAssistantState createState() => _PNJAssistantState();
}

class _PNJAssistantState extends State<PNJAssistant>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double size = 180;

    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(widget.assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// AssistantScreen: chat oscuro tipo WhatsApp, PNJ avatar en burbujas

enum Sender { user, bot }

class ChatMessage {
  final Sender sender;
  final String text;
  final DateTime timestamp;

  ChatMessage({required this.sender, required this.text})
      : timestamp = DateTime.now();
}

class AssistantScreen extends StatefulWidget {
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
        sender: Sender.bot,
        text:
        "Bienvenido. Soy su asistente de buenas prácticas de software. Puedes preguntarme sobre diseño, patrones o arquitectura, tambien puedes preguntarme cualquier duda con respecto a esta aplicacion")
  ];

  // Memoria corta: últimos mensajes del usuario
  final List<String> _recentUserMessages = [];
  final TextEditingController _controller = TextEditingController();

  bool _isTyping = false;
  final String _avatarAsset = 'assets/assistant/pnj.png';

  // CONFIGURACIÓN DE IA
  bool _useAI = true; // alternar desde el botón del AppBar
  final String _apiKey = ""; // <- API Key aquí (vacío = offline)

  // PERSONALIDAD ACTUAL
  String _modo = "formal";
  final Map<String, String> _personalidades = {
    "formal":
    "Eres un asistente técnico formal, preciso y sin emojis. Das explicaciones profesionales y estructuradas.",
    "mentor":
    "Eres un mentor experto en desarrollo de software, paciente y didáctico. Acompañas el aprendizaje paso a paso.",
    "casual":
    "Eres un desarrollador relajado que explica conceptos de forma sencilla y conversacional, con ejemplos prácticos.",
    "motivacional":
    "Eres un mentor que motiva al programador a mejorar y aprender de sus errores, usando tono positivo y alentador."
  };

  @override
  void initState() {
    super.initState();
    _loadMessages();     // carga chat al abrir la pantalla
  }

  // ENVÍO DE MENSAJES
  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(sender: Sender.user, text: trimmed));
      _recentUserMessages.add(trimmed.toLowerCase());
      if (_recentUserMessages.length > 3) {
        _recentUserMessages.removeAt(0);
      }
      _controller.clear();
      _isTyping = true;
    });

// Guardar inmediatamente
    _saveMessages();


    // Cambiar de modo con comandos tipo /modo formal
    if (trimmed.toLowerCase().startsWith("/modo")) {
      final nuevo = trimmed.toLowerCase().split(" ").last;
      if (_personalidades.containsKey(nuevo)) {
        setState(() {
          _modo = nuevo;
          _messages.add(ChatMessage(
              sender: Sender.bot,
              text:
              "Modo cambiado a *$_modo*. (${_modo[0].toUpperCase()}${_modo.substring(1)})"));
          _isTyping = false;
        });
        return;
      }
    }

    // obtener respuesta
    Future.delayed(const Duration(milliseconds: 700), () async {
      final reply = await _getHybridReply(trimmed);
      setState(() {
        _messages.add(ChatMessage(sender: Sender.bot, text: reply));
        _isTyping = false;
      });
      //  Guardar inmediatamente
      _saveMessages();
    });
  }

  //  MODO HÍBRIDO (IA + LOCAL)
  Future<String> _getHybridReply(String prompt) async {
    if (_useAI && _apiKey.isNotEmpty) {
      try {
        final reply = await _askModel(prompt);
        if (reply.trim().isNotEmpty) return reply.trim();
      } catch (e) {
        debugPrint("️ Error IA: $e");
      }
    }
    return _generateReply(prompt, List<String>.from(_recentUserMessages));
  }

  // LLAMADA AL MODELO IA
  Future<String> _askModel(String prompt) async {
    OpenAI.apiKey = _apiKey;

    final response = await OpenAI.instance.chat.create(
      model: "gpt-4o-mini",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              _personalidades[_modo] ?? _personalidades["formal"]!,
            ),
          ],
        ),
        ..._messages.map(
              (m) => OpenAIChatCompletionChoiceMessageModel(
            role: m.sender == Sender.bot
                ? OpenAIChatMessageRole.assistant
                : OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(m.text),
            ],
          ),
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
          ],
        ),
      ],
    );

    // Accede correctamente al texto de la respuesta
    final messageContent = response.choices.first.message.content;

    if (messageContent != null && messageContent.isNotEmpty) {
      return messageContent.first.text ?? "";
    } else {
      return "No se recibió respuesta del modelo.";
    }
  }

// Guardar todos los mensajes
  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();

    // Convertir lista a JSON
    List<String> jsonMessages = _messages.map((msg) {
      return jsonEncode({
        "sender": msg.sender == Sender.user ? "user" : "bot",
        "text": msg.text,
        "timestamp": msg.timestamp.toIso8601String(),
      });
    }).toList();

    await prefs.setStringList("chat_history", jsonMessages);
  }

// Cargar mensajes
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList("chat_history");

    if (stored == null) return;

    List<ChatMessage> loaded = stored.map((m) {
      final data = jsonDecode(m);
      return ChatMessage(
        sender: data["sender"] == "user" ? Sender.user : Sender.bot,
        text: data["text"],
      );
    }).toList();

    setState(() {
      _messages.clear();
      _messages.addAll(loaded);
    });
  }

// Borrar chat completamente
  Future<void> _resetChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("chat_history");

    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
          sender: Sender.bot,
          text: "hey, soy tu asistente virtual, puedes preguntarme sobre diseño, patrones o arquitectura, tambien puedes preguntarme cualquier duda con respecto a esta aplicacion¿En qué puedo ayudarte ahora?"));
    });
  }
  void _confirmResetChat() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reiniciar conversación"),
        content: const Text("¿Deseas borrar todo el chat y comenzar desde cero?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reiniciar"),
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  sender: Sender.bot,
                  text:
                  " hey, soy tu asistente virtual, puedes preguntarme sobre diseño, patrones o arquitectura, tambien puedes preguntarme cualquier duda con respecto a esta aplicacion¿En qué puedo ayudarte ahora?",
                ));
              });

              await _saveMessages(); // Guardar cambios
            },
          ),
        ],
      ),
    );
  }





  // RESPUESTAS LOCALES MEJORADAS
  String _generateReply(String msg, List<String> context) {
    //
    String _normalize(String text) {
      return removeDiacritics(text.toLowerCase());
    }

    String enrich(String base) {
      final extract = msg.length > 120 ? msg.substring(0, 120) + "..." : msg;
      return "$base\n\nPor cierto, mencionaste: \"$extract\". Si quieres puedes preguntar por algun tema relacionado a ello o a las buenas practicas";
    }

    final m = _normalize(msg);

    bool any(List<String> keys) =>
        keys.any((k) => m.contains(removeDiacritics(k.toLowerCase())));

    // --- RESPUESTAS -------------------------

    // GENERALES
    if (any(["buenas prácticas", "buenas practicas", "best practices", "software engineering", "ingeniería de software" "¿Que son las buenas practicas en la ingenieria de software?"]))
      return enrich("Las buenas prácticas de ingeniería de software son un conjunto de directrices y recomendaciones que buscan optimizar el proceso de creación de aplicaciones y sistemas, ayudan a construir sistemas más claros, mantenibles y seguros. Incluyen principios como modularidad, pruebas tempranas, documentación efectiva y diseño orientado al usuario.");

    if (any(["desarrollo de software", "software development"]))
      return enrich("El desarrollo de software es un proceso iterativo que abarca análisis, diseño, codificación, pruebas y evolución. Su objetivo es transformar una necesidad del usuario en una solución funcional y de calidad.");

    if (any(["ciclo de vida", "life cycle"]))
      return enrich("El ciclo de vida del software es un proceso estructurado que guía el desarrollo de aplicaciones desde su concepción hasta su retiro, suele incluir: planificación, diseño arquitectónico, desarrollo, pruebas, despliegue y mantenimiento. Cada fase retroalimenta a las demás para mejorar el producto final.");

    if (any(["metodología ágil", "metodologia agil", "agile"]))
      return enrich("Son un conjunto de técnicas aplicadas en ciclos de trabajo cortos, con el objetivo de que el proceso de entrega de un proyecto sea más eficiente. Las metodologías ágiles —como Scrum o Kanban— trabajan en ciclos cortos para entregar valor de forma continua. Fomentan la colaboración, la adaptabilidad y la retroalimentación frecuente.");

    if (any(["calidad", "quality"]))
      return enrich("La calidad del software no es solo ausencia de errores: también implica usabilidad, rendimiento, seguridad, mantenibilidad y satisfacción del usuario final.");

    if (any(["mantenimiento", "maintenance"]))
      return enrich("El mantenimiento de software se refiere a todas las actividades necesarias para asegurar que un sistema de software siga funcionando de manera óptima a lo largo del tiempo, incluye corregir fallos, mejorar funcionalidades y adaptar el sistema a nuevos requisitos o tecnologías. Representa una parte significativa del costo total del ciclo de vida.");

    if (any(["gestión de proyectos", "gestion de proyectos", "project management"]))
      return enrich("La gestión de proyectos de software coordina recursos, riesgos, tiempos y expectativas. Su meta es entregar soluciones con calidad y dentro de los límites definidos.");

    if (any(["productividad", "productivity", "eficiencia", "efficiency"]))
      return enrich("La productividad en un equipo de desarrollo mejora con automatización, buena comunicación, revisiones de código y procesos claros. No se trata de hacer más, sino de hacer mejor.");

    if (any(["colaboración", "colaboracion", "team"]))
      return enrich("Una buena colaboración entre desarrolladores acelera la entrega de valor y reduce errores. Técnicas como pair programming o code reviews fortalecen el trabajo en equipo.");

    if (any(["documentación", "documentacion", "documentation"]))
      return enrich("La documentación es una guía viva que ayuda a entender decisiones, procesos y estructuras del sistema. Facilita el onboarding y reduce ambigüedades.");

    if (any(["mejora continua", "continuous improvement"]))
      return enrich("La mejora continua implica analizar qué funcionó, qué no, y ajustar procesos para la siguiente iteración. Equipos que reflexionan avanzan más rápido.");

    // PLANIFICACIÓN
    if (any(["requisito", "requirement", "analysis"]))
      return enrich("El análisis de requisitos define qué debe hacer el producto y por qué. Es la base para un desarrollo alineado a las necesidades del usuario.");

    if (any(["estimación", "estimacion", "resource estimation"]))
      return enrich("Las estimaciones permiten prever tiempos y recursos. Aunque nunca son exactas, ayudan a tomar decisiones realistas y evitar sobrecarga del equipo.");

    if (any(["cronograma", "timeline", "schedule", "hito", "milestone"]))
      return enrich("Es una representación gráfica, ordenada y esquemática de eventos, generalmente venideros. Un cronograma bien definido organiza entregas, prioridades y dependencias es clave para coordinar equipos y evitar bloqueos.");

    if (any(["riesgo", "risk management"]))
      return enrich("La gestión de riesgos identifica amenazas potenciales y crea planes de mitigación antes de que se conviertan en problemas reales.");

    if (any(["plan de proyecto", "project plan"]))
      return enrich("Un plan de proyecto sólido describe objetivos, alcance, recursos, cronograma, roles, riesgos y canales de comunicación.");

    if (any(["comunicación", "comunicacion", "communication"]))
      return enrich("Esto es muy importante, la comunicación efectiva evita malentendidos y reduce retrabajo. En desarrollo, la claridad es tan importante como el código.");

    if (any(["herramienta", "management tool", "jira", "trello", "asana", "notion"]))
      return enrich("Herramientas recomendadas: Jira para proyectos ágiles, Trello para equipos pequeños, Asana para gestión visual y Notion para documentación integrada.");

    if (any(["control de versiones", "version control", "git"]))
      return enrich("Git es un sistema de control de versiones distribuido, lo que significa que un clon local del proyecto es un repositorio de control de versiones completo. Git permite gestionar cambios, colaborar sin conflictos y mantener un historial claro del proyecto. Es esencial en cualquier equipo moderno.");

    // DISEÑO
    if (any(["diseño modular", "diseno modular", "modular design", "arquitectura limpia", "clean architecture"]))
      return enrich("Un diseño modular separa responsabilidades y reduce el acoplamiento. Clean Architecture organiza capas para facilitar mantenimiento y pruebas.");

    if (any(["orientación a objetos", "orientacion a objetos", "object-oriented", "oop", "orientada a objetos"]))
      return enrich("La programación orientada a objetos usa conceptos como encapsulación, herencia y polimorfismo para modelar sistemas más expresivos y reutilizables.");

    if (any(["responsabilidad única", "responsabilidad unica", "single responsibility", "srp"]))
      return enrich("El principio SRP indica que una clase debe tener una sola razón de cambio. Evita clases 'gigantes' y facilita pruebas.");

    if (any(["patrón de diseño", "patron de diseño", "patron de diseno", "design pattern", "mvc", "mvvm"]))
      return enrich("Los patrones de diseño ofrecen soluciones probadas a problemas comunes. Ejemplos: Singleton, Factory, Observer, MVC y MVVM.");

    if (any(["uml"]))
      return enrich("Los diagramas UML ayudan a visualizar estructuras, interacciones y comportamientos. Son útiles para documentar y alinear al equipo.");

    if (any(["reutilización", "reutilizacion", "reusability"]))
      return enrich("La reutilización reduce duplicación y acelera el desarrollo. Componentes bien diseñados se convierten en piezas reutilizables.");

    if (any(["centrado en el usuario", "user-centered", "ux", "ui"]))
      return enrich("El diseño centrado en el usuario prioriza usabilidad, accesibilidad y claridad. Una buena experiencia simplifica la curva de aprendizaje.");

    if (any(["seguridad por diseño", "security by design"]))
      return enrich("Security by Design implica considerar riesgos desde el inicio, incluyendo validaciones, cifrado y manejo seguro de datos.");

    // CODIFICACIÓN
    if (any(["solid"]))
      return enrich("SOLID es un conjunto de principios que facilita mantener, escalar y extender el código sin romper lo existente.");

    if (any(["dry", "don’t repeat yourself", "dont repeat yourself"]))
      return enrich("DRY promueve evitar duplicación. Si copias código, probablemente hay un componente que deberías abstraer.");

    if (any(["kiss", "keep it simple", "simple"]))
      return enrich("KISS nos recuerda que las mejores soluciones suelen ser las más simples. Evita complejidad innecesaria.");

    if (any(["yagni"]))
      return enrich("YAGNI es una filosofía de desarrollo de software que consiste en que no se debe agregar nunca una funcionalidad excepto cuando sea necesaria, dice: no construyas algo hasta que realmente lo necesites. Evita sobreingeniería.");

    if (any(["refactorización", "refactorizacion", "refactoring"]))
      return enrich("Refactorizar mejora la estructura interna sin cambiar el comportamiento externo. Es clave para mantener la salud del código.");

    if (any(["legibilidad", "readability", "naming"]))
      return enrich("Un código claro, con buenos nombres y estructura lógica, cuesta menos de mantener y reduce errores.");

    if (any(["comentario", "comment"]))
      return enrich("Los comentarios deben explicar la intención, no describir lo obvio. Buen código se entiende solo, los comentarios complementan.");

    if (any(["revisión de código", "revision de codigo", "code review"]))
      return enrich("Las code reviews detectan errores temprano, comparten conocimiento y fortalecen la calidad técnica del equipo.");

    if (any(["ci", "cd", "continuous integration", "continuous deployment"]))
      return enrich("CI/CD automatiza compilación, pruebas y despliegues. Reduce riesgos y acelera el ciclo de entrega.");

    // PRUEBAS
    if (any(["prueba unitaria", "unit test", "pruebas unitarias"]))
      return enrich("Las pruebas unitarias validan piezas pequeñas del sistema. Son rápidas y ayudan a detectar fallos desde el inicio.");

    if (any(["integración", "integracion", "integration test"]))
      return enrich("Las pruebas de integración verifican cómo interactúan módulos distintos entre sí.");

    if (any(["sistema", "system test"]))
      return enrich("Las pruebas de sistema validan el comportamiento completo en un entorno similar al real.");

    if (any(["aceptación", "aceptacion", "acceptance test"]))
      return enrich("Las pruebas de aceptación confirman que el software cumple los requisitos del usuario.");

    if (any(["automatizada", "automated test", "automatizacion","automatización","DevOps"]))
      return enrich("Las pruebas automatizadas aceleran el feedback y permiten ejecutar cientos de validaciones en segundos. En la metodología DevOps, trabajan como un equipo con un conjunto de herramientas y prácticas compartidas.");

    if (any(["rendimiento", "performance", "carga", "load"]))
      return enrich("Las pruebas de rendimiento verifican tiempos de respuesta; las de carga miden estabilidad bajo estrés.");

    if (any(["seguridad", "security"]))
      return enrich("Las pruebas de seguridad identifican vulnerabilidades como inyecciones, accesos indebidos o configuraciones inseguras.");

    if (any(["usabilidad", "usability", "ux"]))
      return enrich("Las pruebas de usabilidad evalúan qué tan fácil es usar el producto y qué tan satisfecho queda el usuario.");

    if (any(["cobertura", "coverage"]))
      return enrich("La cobertura indica cuánto del código ha sido ejecutado por pruebas; no es garantía de calidad, pero sí una métrica útil.");

    if (any(["regresión", "regresion", "regression"]))
      return enrich("Las pruebas de regresión aseguran que nuevas modificaciones no rompan funcionalidades existentes.");

    // GESTIÓN Y MEJORA CONTINUA
    if (any(["retrospectiva", "retrospective"]))
      return enrich("Las retrospectivas permiten aprender del proceso y ajustar para mejorar en el siguiente ciclo.");

    if (any(["métrica", "metrica", "kpi", "indicador"]))
      return enrich("Las métricas y KPIs ayudan a medir progreso, calidad y eficiencia. Bien usadas, guían decisiones objetivas.");

    if (any(["feedback"]))
      return enrich("El feedback continuo mejora la calidad del software y ayuda al equipo a aprender y crecer.");

    if (any(["auditoría", "auditoria", "audit"]))
      return enrich("Las auditorías de código revisan estándares, seguridad y cumplimiento. Son una forma de garantizar consistencia técnica.");

    if (any(["qa", "control de calidad", "Testing", "testing"]))
      return enrich("El testing es una prueba que consiste en analizar si un software o programa informático funciona correctamente. QA se encarga de asegurar que el software cumpla con los estándares acordados. No es solo probar: es prevenir defectos.");

    if (any(["integridad", "integrity", "compliance"]))
      return enrich("La integridad y el cumplimiento garantizan que el sistema opere de forma confiable y en línea con regulaciones.");

    // CONCLUSIÓN
    if (any(["usuario final", "end user", "customer"]))
      return enrich("Buenas prácticas, diseño claro y pruebas adecuadas impactan directamente en la satisfacción del usuario.");

    if (any(["actualizado", "update", "trend"]))
      return enrich("Estar al día con herramientas, patrones y tecnologías fomenta innovación y competitividad.");

    if (any(["no aplicar", "bad practices", "consecuencias" "malas"]))
      return enrich("No seguir buenas prácticas puede generar deuda técnica, errores frecuentes y costos elevados de mantenimiento.");

    if (any(["código limpio", "codigo limpio", "Clean Code", "clean code"]))
      return enrich("Código limpio es un término usado para describir código de computadoras que es fácil de leer, entender y mantener. Código limpio se escribe de una manera que lo hace simple, conciso y expresivo.");

    if (any(["TDD", "Test Driven Development", "desarrollo basado", "guiado"]))
      return enrich("El Test-Driven Development (TDD), o Desarrollo Guiado por Pruebas, es una metodología de desarrollo de software que ha ganado mucha popularidad en los últimos años. Se centra en la creación de pruebas unitarias antes de escribir el código que se pretende probar. Este enfoque, aunque inicialmente puede parecer contraintuitivo, ofrece numerosos beneficios en términos de calidad del código, mantenibilidad y reducción de errores.");

    if (any(["Planificación ", "gestion", "gestión", "planificación"]))
      return enrich("La planificación es el proceso de definir los objetivos del proyecto, identificar las tareas necesarias para alcanzar esos objetivos, asignar recursos y establecer un cronograma. Es importante tener en cuenta factores como los requisitos del cliente, las limitaciones de tiempo y los recursos disponibles. Una buena planificación garantiza que todas las partes involucradas estén alineadas y tengan claro qué se espera de ellos.");

    if (any(["microservicio", "microservicios", "microservice"]))
      return enrich("La arquitectura de microservicios divide una aplicación en componentes pequeños, independientes y desplegables por separado. Esto permite escalabilidad granular, despliegues rápidos y mayor resiliencia.");

    if (any(["docker", "contenedor", "container"]))
      return enrich("Docker permite empaquetar aplicaciones junto con sus dependencias en contenedores ligeros y reproducibles. Facilita despliegues consistentes entre entornos.");

    if (any(["kubernetes", "k8s"]))
      return enrich("Kubernetes es un orquestador de contenedores que gestiona despliegues, escalado automático y autorecuperación. Es esencial para arquitecturas modernas distribuidas.");

    if (any(["nosql", "mongo", "mongodb", "base de datos no relacional"]))
      return enrich("Las bases NoSQL manejan datos no estructurados y permiten escalabilidad horizontal. Son ideales para grandes volúmenes con esquemas flexibles.");

    if (any(["sql", "postgres", "mysql", "consultas"]))
      return enrich("Las bases relacionales organizan datos en tablas y permiten consultas complejas mediante SQL. Son confiables para sistemas con integridad referencial.");

    if (any(["indice", "index", "performance db"]))
      return enrich("La indexación acelera búsquedas en bases de datos creando estructuras optimizadas. Es clave para mejorar el rendimiento en tablas grandes.");

    if (any(["oauth", "jwt", "token", "autenticacion"]))
      return enrich("OAuth y JWT son mecanismos modernos para autenticar usuarios y autorizar accesos. Permiten sesiones seguras sin almacenar contraseñas en el cliente.");

    if (any(["cifrado", "encriptacion", "aes", "rsa"]))
      return enrich("El cifrado protege datos mediante algoritmos como AES o RSA. Se usa para resguardar información sensible en tránsito o almacenamiento.");

    if (any(["iac", "terraform", "cloudformation"]))
      return enrich("Infrastructure as Code permite definir infraestructura mediante archivos declarativos. Facilita reproducibilidad, versionado y despliegues confiables.");

    if (any(["logging", "logs", "monitoring", "observabilidad"]))
      return enrich("La observabilidad incluye métricas, logs y trazas para entender el comportamiento del sistema en producción y detectar problemas rápido.");

    if (any(["machine learning", "ml", "modelo predictivo"]))
      return enrich("Machine Learning permite crear modelos que aprenden patrones a partir de datos. Se utiliza para predicciones, clasificación e inteligencia aplicada.");

    if (any(["big data", "hadoop", "spark"]))
      return enrich("Big Data trabaja con volúmenes masivos de información mediante sistemas distribuidos. Frameworks como Spark permiten procesamiento a gran escala.");

    if (any(["neuronal", "neuronales", "deep learning"]))
      return enrich("Las redes neuronales imitan el funcionamiento del cerebro para resolver problemas complejos como visión artificial o procesamiento del lenguaje.");

    if (any(["cloud", "nube", "aws", "azure", "gcp"]))
      return enrich("El cómputo en la nube ofrece recursos escalables bajo demanda. Proveedores como AWS, Azure y GCP facilitan despliegues ágiles y globales.");

    if (any(["serverless", "lambda", "functions"]))
      return enrich("Serverless permite ejecutar código sin gestionar servidores. Se paga solo por uso y es ideal para tareas event-driven.");

    if (any(["design thinking", "innovacion", "prototipo"]))
      return enrich("Design Thinking impulsa soluciones centradas en el usuario mediante empatía, ideación y prototipado rápido.");

    if (any(["roadmap", "estrategia de producto"]))
      return enrich("Un roadmap define la evolución del producto a mediano plazo. Prioriza iniciativas según valor, impacto y necesidades del mercado.");

    if (any(["rest", "api", "endpoint", "swagger"]))
      return enrich("Una API REST organiza recursos mediante métodos HTTP. Es un estándar para integrar servicios de forma simple y escalable.");

    if (any(["graphql", "consulta graphql"]))
      return enrich("GraphQL permite solicitar solo los datos necesarios a través de un único endpoint. Reduce sobrecarga y mejora eficiencia.");

    if (any(["websocket", "tiempo real", "socket"]))
      return enrich("WebSockets habilitan comunicación bidireccional en tiempo real entre cliente y servidor. Son ideales para chats, juegos o dashboards.");

    // DEFAULT
    return enrich("No tengo una respuesta directa para ese tema, pero puedo ayudarte con conceptos como SOLID, Agile, Testing, arquitectura o buenas prácticas.");
  }




  // INTERFAZ
  Widget _buildMessage(ChatMessage msg) {
    final isBot = msg.sender == Sender.bot;
    final bubbleColor =
    isBot ? const Color(0xFF0078D7) : const Color(0xFF2E2E2E);
    final textColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment:
        isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(_avatarAsset, fit: BoxFit.cover),
              ),
            ),
          if (isBot) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(14)),
              child: Text(msg.text,
                  style: TextStyle(color: textColor, fontSize: 15)),
            ),
          ),
          if (!isBot) const SizedBox(width: 8),
          if (!isBot)
            CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[700],
                child: const Text('',
                    style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.transparent,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(_avatarAsset, fit: BoxFit.cover)),
        ),
        const SizedBox(width: 8),
        const Text("Escribiendo...",
            style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF005C9E),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                  Image.asset(_avatarAsset, width: 36, fit: BoxFit.cover)),
            ),
            const SizedBox(width: 10),
            Text('Asistente (${_modo[0].toUpperCase()}${_modo.substring(1)})',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          // Alternar IA / Offline
          IconButton(
            icon: Icon(
              _useAI ? Icons.memory : Icons.offline_bolt,
              color: Colors.white,
            ),
            tooltip: _useAI ? "IA activada" : "Modo offline",
            onPressed: () {
              setState(() {
                _useAI = !_useAI;
              });
            },
          ),

          //  Reiniciar el chat
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: "Reiniciar conversación",
            onPressed: () {
              _confirmResetChat();
            },
          ),
        ],

      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, i) {
                  if (_isTyping && i == _messages.length) {
                    return _typingIndicator();
                  }
                  return _buildMessage(_messages[i]);
                },
              ),
            ),
            Container(
              color: const Color(0xFF0A0A0B),
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje....',
                        hintStyle:
                        const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF171717),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFF006DCE),
                    onPressed: () => _sendMessage(_controller.text),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({required this.userId});
  final String userId;

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  String userName = "Usuario";
  int avatarIndex = 0;
  String? profileImagePath;
  Database? _db;

  final List<Map<String, dynamic>> avatars = [
    {"icon": Icons.school, "label": "Estudiante"},
    {"icon": Icons.engineering, "label": "Tutor"},
    {"icon": Icons.code, "label": "Programador"},
    {"icon": Icons.computer, "label": "Desarrollador"},
    {"icon": Icons.lightbulb, "label": "Creativo"},
    {"icon": Icons.person, "label": "Genérico"},
  ];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'user_data.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile (
            id TEXT PRIMARY KEY,
            name TEXT,
            avatarIndex INTEGER,
            photo TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1) {
          await db.execute("ALTER TABLE user_profile ADD COLUMN photo TEXT");
        }
      },
    );

    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final result = await _db!.query(
      'user_profile',
      where: "id = ?",
      whereArgs: [widget.userId],
    );

    if (result.isNotEmpty) {
      setState(() {
        userName = result.first['name'] as String;
        avatarIndex = result.first['avatarIndex'] as int;
        profileImagePath = result.first['photo'] as String?;
      });
    } else {
      await _db!.insert("user_profile", {
        "id": widget.userId,
        "name": userName,
        "avatarIndex": avatarIndex,
        "photo": null
      });
    }
  }

  Future<void> _saveUserProfile(String name, int index, String? imgPath) async {
    await _db!.update(
      "user_profile",
      {
        "name": name,
        "avatarIndex": index,
        "photo": imgPath,
      },
      where: "id = ?",
      whereArgs: [widget.userId],
    );

    setState(() {
      userName = name;
      avatarIndex = index;
      profileImagePath = imgPath;
    });
  }

  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final imgPath = p.join(appDir.path, "profile_${widget.userId}.png");

    await File(file.path).copy(imgPath);
    return imgPath;
  }

  void _showEditDialog() {
    TextEditingController nameCtrl = TextEditingController(text: userName);
    int tempIndex = avatarIndex;
    String? tempImg = profileImagePath;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setStateModal) {
          return AlertDialog(
            title: const Text("Editar Perfil"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final img = await _pickImage();
                      if (img != null) setStateModal(() => tempImg = img);
                    },
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage:
                      tempImg != null ? FileImage(File(tempImg!)) : null,
                      child: tempImg == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),
                  const SizedBox(height: 10),
                  const Text("Rol / estilo visual:"),
                  Wrap(
                    spacing: 8,
                    children: List.generate(avatars.length, (i) {
                      return GestureDetector(
                        onTap: () => setStateModal(() => tempIndex = i),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: tempIndex == i
                                  ? Colors.cyan
                                  : Colors.grey[300],
                              child: Icon(
                                avatars[i]["icon"],
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              avatars[i]["label"],
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveUserProfile(nameCtrl.text, tempIndex, tempImg);
                  Navigator.pop(context);
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0017), // fondo dark neon
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AVATAR
              profileImagePath != null
                  ? CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(File(profileImagePath!)),
              )
                  : CircleAvatar(
                radius: 50,
                backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                child: Icon(
                  avatars[avatarIndex]["icon"],
                  size: 50,
                  color: Colors.cyanAccent,
                ),
              ),

              const SizedBox(height: 15),
              Text(
                "¡Hola, $userName!",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                ),
                child: const Text(
                  "Esta es una app de apoyo para las buenas prácticas en la ingeniería de software. "
                      "Aquí encontrarás teoría, ejemplos, evaluaciones y un asistente que te guiará.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),

              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _showEditDialog,
                icon: const Icon(Icons.settings),
                label: const Text("Editar Perfil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 30),

// 🔗 Enlace a la página web
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse("https://tusitio.com"); // 🔥 cambia aquí tu web
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.6)),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.web, color: Colors.cyanAccent),
                      SizedBox(width: 10),
                      Text(
                        "Visitar página oficial",
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

// 📧 Contacto por correo
              GestureDetector(
                onTap: () async {
                  final email = Uri(
                    scheme: "mailto",
                    path: "a22300157@unideh.edu.mx",
                    query: "subject=Contacto desde LearnUp",
                  );
                  await launchUrl(email);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.6)),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email, color: Colors.cyanAccent),
                      SizedBox(width: 10),
                      Text(
                        "Contacto: a22300157@unideh.edu.mx",
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// GENERADOR DE USER ID AUTOMÁTICO
class UserManager {
  static Future<String> getOrCreateUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("userId");

    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString("userId", id);
    }
    return id;
  }
}




class TheoryScreen extends StatefulWidget {
  @override
  _TheoryScreenState createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  String searchQuery = '';
  List<String> favorites = [];

  final List<String> topics = [
    'Buenas prácticas en desarrollo de software',
    'Ciclo de vida del software',
    'Metodologías ágiles (Scrum, Kanban)',
    'Gestión de proyectos de software',
    'Calidad del software',
    'Mantenimiento del software',
    'Análisis de requisitos',
    'Estimación de recursos y tiempos',
    'Gestión de riesgos',
    'Planificación y cronograma',
    'Comunicación efectiva en proyectos',
    'Herramientas de gestión de proyectos',
    'Arquitectura de software',
    'Diseño modular y orientación a objetos',
    'Principio de responsabilidad única (SRP)',
    'Patrones de diseño (MVC, MVVM, Singleton)',
    'Diseño centrado en el usuario (UX/UI)',
    'Seguridad por diseño',
    'Diagramas UML',
    'Reutilización de componentes',
    'Principios SOLID',
    'Principio DRY y KISS',
    'Principio YAGNI',
    'Refactorización de código',
    'Control de versiones con Git',
    'Comentarios y documentación',
    'Revisión de código (Code Review)',
    'Integración y despliegue continuo (CI/CD)',
    'Manejo de errores y excepciones',
    'Optimización y eficiencia',
    'Entorno de desarrollo (IDE y herramientas)',
    'Pruebas unitarias',
    'Pruebas de integración',
    'Pruebas de sistema y aceptación',
    'Pruebas automatizadas',
    'Pruebas de rendimiento y carga',
    'Pruebas de seguridad',
    'Pruebas de usabilidad',
    'Cobertura y regresión de código',
    'Retrospectivas y mejora continua',
    'Métricas e indicadores (KPIs)',
    'Feedback y auditoría de código',
    'Control de calidad (QA)',
    'Integridad y cumplimiento normativo',
    'Colaboración en equipo y cultura DevOps',
    'Actualización profesional y tendencias',
    'Desarrollo guiado por pruebas (TDD)',
    'Integración de APIs y Servicios REST',
    'Programación asíncrona y concurrencia',
    'Contenedores y Docker',
    'Kubernetes y orquestación',
    'Observabilidad: logs, métricas y trazas',
    'Arquitectura orientada a eventos',
    'Cloud Computing (AWS, Azure, GCP)',
    'Desarrollo móvil multiplataforma',
    'Bases de datos SQL y NoSQL',
    'Caso de uso: Gestión de usuarios',
    'Caso de uso: Carrito de compras',
    'Caso de uso: Gestión de tareas',
    'Caso de uso: Reservas de citas',
    'Caso de uso: Sistema de comentarios',
    'Caso de uso: Gestión de archivos',
    'Caso de uso: Sistema de notificaciones',
    'Caso de uso: UML - Diagrama de Clases',
    'Caso de uso: UML - Diagrama de Secuencia',
    'Caso de uso: UML - Diagrama de Actividades',
    'Caso de uso: UML - Diagrama de Casos de Uso',
    'Caso de uso: UML - Diagrama de Estados',
    'Caso de uso: UML - Diagrama de Componentes',
    'Libros y autores: Robert C. Martin',
    'Libros y autores: Martin Fowler',
    'Libros y autores: Kent Beck',
    'Libros y autores: Gang of Four (GoF)',
    'Libros y autores: Eric Evans',
    'Libros y autores: Jez Humble',
    'Libros y autores: Steve McConnell',
    'Libros y autores: The Pragmatic Programmers',
    'Videos de apoyo',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Cargar favoritos (máx 5)
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favoriteTopics') ?? [];
    });
  }

  // Guardar favoritos
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteTopics', favorites);
  }


  // Alternar favoritogbvh
  void _toggleFavorite(String topic) {
    setState(() {
      if (favorites.contains(topic)) {
        favorites.remove(topic);
      } else {
        if (favorites.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Solo puedes tener 5 temas favoritos.')),
          );
          return;
        }
        favorites.add(topic);
      }
    });

    _saveFavorites();
  }

  @override
  Widget build(BuildContext context) {
    // Ordenar: favoritos primero
    final sortedTopics = [
      ...favorites,
      ...topics.where((t) => !favorites.contains(t)).toList()
    ];

    final filteredTopics = sortedTopics
        .where((t) => t.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Teoría")),
      body: Column(
        children: [
          // 🔎 Buscador
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar tema...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),

          // 📚 Lista de temas
          Expanded(
            child: ListView.builder(
              itemCount: filteredTopics.length,
              itemBuilder: (context, index) {
                final topic = filteredTopics[index];
                final isFav = favorites.contains(topic);

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(topic),
                    leading: IconButton(
                      icon: Icon(
                        isFav ? Icons.star : Icons.star_border,
                        color: isFav ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () => _toggleFavorite(topic),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicDetailScreen(topic: topic),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}


class TopicDetailScreen extends StatelessWidget {
  final String topic;

  const TopicDetailScreen({required this.topic});

  @override
  Widget build(BuildContext context) {
    final content = _getTopicContent(topic);

    return Scaffold(
      appBar: AppBar(title: Text(topic)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: _buildClickableContent(content),
        ),
      ),
    );
  }

  /// 🔥 Convierte texto con URLs en enlaces clicables
  Widget _buildClickableContent(String text) {
    final urlRegex = RegExp(r'https?://[^\s]+');
    final matches = urlRegex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text,
          style: TextStyle(fontSize: 16, height: 1.4));
    }

    final List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      final url = match.group(0)!;

      // Texto antes de la URL
      spans.add(TextSpan(text: text.substring(lastIndex, match.start)));

      // 🔗 URL clicable
      spans.add(
        TextSpan(
          text: url,
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              }
            },
        ),
      );

      lastIndex = match.end;
    }

    // Último fragmento
    spans.add(TextSpan(text: text.substring(lastIndex)));

    return SelectableText.rich(
      TextSpan(children: spans),
      style: TextStyle(fontSize: 16, height: 1.4),
    );
  }

  String _getTopicContent(String topic) {
    switch (topic) {
    //  GENERALES
      case 'Buenas prácticas en desarrollo de software':
        return '''
Título: Buenas prácticas en desarrollo de software

Definición: 
Las buenas prácticas en desarrollo de software son un conjunto de principios, técnicas y normas que los equipos adoptan para garantizar que el código sea eficiente, mantenible, seguro y escalable. Estas prácticas abarcan desde la planificación del proyecto hasta la entrega y mantenimiento del producto, e incluyen aspectos como el diseño limpio, la documentación clara, la gestión adecuada del control de versiones, la revisión de código y las pruebas automatizadas.

Importancia:  
Aplicar buenas prácticas reduce la probabilidad de errores, facilita la colaboración entre desarrolladores y asegura la calidad del software a largo plazo. Además, mejora la productividad del equipo al minimizar el tiempo dedicado a corregir problemas y facilita la incorporación de nuevos miembros al proyecto.

Beneficios principales:  
- Código más legible y fácil de mantener.  
- Menor cantidad de errores y vulnerabilidades.  
- Mayor eficiencia en el trabajo en equipo.  
- Reducción de costos en mantenimiento y soporte.  
- Mejora continua del producto y la satisfacción del cliente.

Ejemplos o casos comunes:  
- Uso de control de versiones (como Git).  
- Aplicación de principios SOLID en programación orientada a objetos.  
- Revisión de código (Code Review) antes de fusionar cambios.  
- Implementación de pruebas unitarias y de integración.  
- Seguimiento de estándares de codificación y convenciones de estilo.
''';

      case 'Ciclo de vida del software':
        return '''
Fases del ciclo de vida del software:  
El ciclo de vida del software describe las etapas que sigue un proyecto desde su concepción hasta su retiro o reemplazo. Estas fases garantizan un desarrollo ordenado, controlado y con calidad.  
Las etapas más comunes son:

1. Planificación: Definición de objetivos, alcance, recursos, costos y cronograma.  
2. Análisis de requisitos: Identificación y documentación de las necesidades del usuario.  
3. Diseño: Creación de la arquitectura del sistema, diagramas y modelos de datos.  
4. Desarrollo: Programación y construcción del software conforme al diseño.  
5. Pruebas: Validación del producto para asegurar que cumple con los requisitos y funciona correctamente.  
6. Despliegue: Implementación del software en el entorno de producción.  
7. Mantenimiento: Corrección de errores, actualizaciones y mejoras a lo largo del tiempo.

Relación con la calidad del software:  
Cada fase del ciclo de vida influye directamente en la calidad final del software. Una planificación deficiente o una falta de pruebas puede derivar en un producto inestable o inseguro. En cambio, un ciclo de vida bien gestionado permite identificar errores tempranamente y optimizar los recursos, asegurando la entrega de un producto confiable y alineado con las expectativas del cliente.
''';

      case 'Metodologías ágiles (Scrum, Kanban)':
        return '''
Conceptos básicos de Agile: 
Las metodologías ágiles son enfoques de desarrollo de software que priorizan la flexibilidad, la colaboración y la entrega continua de valor al cliente. En lugar de seguir un plan rígido, Agile promueve iteraciones cortas y revisiones frecuentes para adaptarse rápidamente a los cambios en los requisitos o el mercado.

Diferencias entre Scrum y Kanban:  
- Scrum: Divide el trabajo en iteraciones llamadas *sprints* (generalmente de 2 a 4 semanas). Cada sprint incluye planificación, desarrollo, revisión y retrospectiva. Se enfoca en roles definidos y una estructura organizada.  
- Kanban: Se basa en la visualización del flujo de trabajo mediante un tablero de tareas (Kanban board). No tiene iteraciones fijas; se busca un flujo continuo de entrega y mejora del proceso, limitando el trabajo en progreso (WIP).

Ventajas de la iteración y retroalimentación continua:  
- Permite detectar y corregir errores tempranamente.  
- Mejora la comunicación con el cliente y el equipo.  
- Incrementa la calidad y la rapidez de entrega.  
- Fomenta la mejora continua del proceso y del producto.

Roles principales (en Scrum):  
- Scrum Master: Facilita el proceso, elimina obstáculos y asegura que el equipo siga las prácticas ágiles.  
- Product Owner: Representa los intereses del cliente, prioriza el *backlog* y define los objetivos del producto.  
- Equipo de desarrollo: Grupo multifuncional encargado de construir el producto, participar en la planificación y entregar incrementos funcionales al final de cada sprint.
''';

      case 'Gestión de proyectos de software':
        return '''
Título: Gestión de proyectos de software

Definición y objetivos:  
La gestión de proyectos de software consiste en planificar, organizar, coordinar y controlar los recursos, actividades y plazos de un proyecto de desarrollo de software para alcanzar los objetivos definidos, cumpliendo con los requisitos de calidad, tiempo y presupuesto.

Planificación de recursos y tiempos:  
Se establecen las tareas, responsables, plazos y dependencias entre actividades. Esto incluye estimación de esfuerzo, asignación de personal, definición de entregables y creación de un cronograma realista.

Gestión de riesgos y comunicación:  
Identificación y análisis de riesgos potenciales, establecimiento de planes de contingencia y seguimiento constante. La comunicación efectiva con el equipo y los stakeholders asegura que todos estén alineados y se eviten malentendidos.

Herramientas recomendadas:  
- Jira: Para seguimiento de tareas, *backlogs* y sprints.  
- Trello: Tableros visuales para organizar tareas y flujo de trabajo.  
- Asana: Planificación de proyectos, asignación de tareas y seguimiento de progreso.  

Beneficios principales:  
- Mejora la organización y control del proyecto.  
- Reduce retrasos y sobrecostos.  
- Aumenta la transparencia y colaboración del equipo.  
- Facilita la entrega de un producto de calidad acorde a los objetivos del cliente.
''';

      case 'Calidad del software':
        return '''
Título: Calidad del software

Definición:  
La calidad del software se refiere al grado en que un producto de software cumple con los requisitos funcionales y no funcionales, satisface las expectativas del usuario y se mantiene confiable, seguro y eficiente a lo largo del tiempo.

Atributos principales:  
- Funcionalidad: Cumplimiento de los requisitos especificados.  
- Rendimiento: Velocidad, eficiencia y capacidad de respuesta del software.  
- Seguridad: Protección contra accesos no autorizados y vulnerabilidades.  
- Mantenibilidad: Facilidad de realizar cambios, correcciones y mejoras.  
- Usabilidad: Experiencia intuitiva y agradable para el usuario final.  

Buenas prácticas para asegurar calidad:  
- Implementar pruebas automatizadas y manuales.  
- Revisar y documentar el código de forma consistente.  
- Aplicar estándares de desarrollo y auditorías periódicas.  
- Realizar revisiones de diseño y análisis de riesgos.  
- Monitorear el rendimiento y la experiencia del usuario en producción.
''';

      case 'Mantenimiento del software':
        return '''
Título: Mantenimiento del software

Tipos de mantenimiento:  
- Correctivo: Solución de errores y fallas detectadas en el software.  
- Evolutivo: Adaptación a nuevas necesidades del negocio o mejoras funcionales.  
- Adaptativo: Ajustes para compatibilidad con nuevos entornos, sistemas operativos o tecnologías.

Importancia en el ciclo de vida del software:  
El mantenimiento asegura la continuidad operativa, la satisfacción del usuario y la prolongación de la vida útil del software. Sin mantenimiento, incluso un software bien diseñado puede volverse obsoleto o inseguro.

Herramientas o estrategias útiles:  
- Sistemas de control de versiones (Git, SVN) para gestionar cambios.  
- Documentación actualizada del código y procedimientos.  
- Pruebas regresivas para asegurar que los cambios no introduzcan nuevos errores.  
- Monitoreo de rendimiento y reportes de incidencias.
''';

    //  PLANIFICACIÓN
      case 'Análisis de requisitos':
        return '''
Título: Análisis de requisitos

Propósito del análisis:  
El análisis de requisitos busca identificar, documentar y comprender las necesidades y expectativas de los usuarios y stakeholders. Su objetivo es definir qué debe hacer el software y cómo debe comportarse, asegurando que el producto final cumpla con los objetivos del proyecto.

Técnicas para recopilar requisitos:  
- Entrevistas con usuarios y stakeholders.  
- Cuestionarios y encuestas.  
- Talleres de trabajo (*workshops*).  
- Observación directa y análisis de procesos existentes.  
- Historias de usuario y casos de uso.

Requisitos funcionales y no funcionales:  
- Funcionales: describen acciones, procesos o comportamientos específicos del software.  
- No funcionales: abarcan calidad, rendimiento, seguridad, escalabilidad y usabilidad.

Errores comunes a evitar:  
- Documentación ambigua o incompleta.  
- No involucrar a todos los stakeholders.  
- Cambios frecuentes sin control.  
- Suponer necesidades en lugar de validarlas con el usuario.
''';

      case 'Estimación de recursos y tiempos':
        return '''
Título: Estimación de recursos y tiempos

Métodos de estimación:  
- PERT (Program Evaluation and Review Technique): estima tiempos considerando escenarios optimista, pesimista y más probable.  
- Planning Poker: técnica colaborativa basada en la experiencia del equipo para asignar esfuerzo a tareas.  
- Análisis histórico: usar datos de proyectos previos como referencia.

Importancia de la precisión en las estimaciones:  
Estimaciones realistas permiten planificar recursos, definir cronogramas viables y evitar sobrecostos o retrasos, facilitando la toma de decisiones en todas las fases del proyecto.

Factores que afectan el esfuerzo y costo:  
- Complejidad del software.  
- Experiencia y disponibilidad del equipo.  
- Tecnología y herramientas utilizadas.  
- Cambios en los requisitos o alcance durante el proyecto.
''';

      case 'Gestión de riesgos':
        return '''
Título: Gestión de riesgos

Identificación, evaluación y mitigación de riesgos:  
- Identificar posibles eventos que puedan afectar negativamente al proyecto.  
- Evaluar probabilidad e impacto de cada riesgo.  
- Definir estrategias de mitigación, transferencia, aceptación o eliminación de riesgos.

Tipos de riesgos comunes en proyectos de software:  
- Técnicos: fallos en la tecnología o incompatibilidades.  
- Humanos: falta de capacitación, baja productividad o rotación de personal.  
- Organizacionales: cambios en políticas, presupuesto o prioridades.  
- Externos: cambios regulatorios, problemas con proveedores o clientes.

Plan de contingencia:  
Desarrollar acciones alternativas y protocolos claros para responder rápidamente ante riesgos críticos, minimizando impacto en tiempos, costos y calidad.
''';

      case 'Planificación y cronograma':
        return '''
Título: Planificación y cronograma

Creación de un plan de trabajo:  
Definir todas las actividades necesarias para cumplir los objetivos del proyecto, asignar responsables, recursos y dependencias, asegurando un flujo organizado y predecible.

Definición de hitos y entregables:  
- Hitos: puntos clave que marcan progreso o finalización de fases importantes.  
- Entregables: productos tangibles o resultados que deben completarse en fechas específicas.

Uso de herramientas de planificación:  
- Diagramas de Gantt para visualización de tareas y tiempos.  
- Software de gestión como Jira, Trello o Microsoft Project.  
- Tableros Kanban para seguimiento del flujo de trabajo.
''';

      case 'Comunicación efectiva en proyectos':
        return '''
Título: Comunicación efectiva en proyectos

Importancia de la comunicación clara:  
Una comunicación efectiva asegura que todos los miembros del equipo y stakeholders comprendan objetivos, expectativas, avances y problemas, evitando malentendidos y retrasos.

Técnicas de documentación y reuniones efectivas:  
- Actas y reportes de reuniones.  
- Resúmenes diarios o semanales de progreso.  
- Reuniones breves (*stand-ups*) para coordinar actividades y detectar obstáculos.

Uso de canales y herramientas colaborativas:  
- Correo electrónico, chat corporativo y videoconferencias.  
- Documentos compartidos y wikis para mantener información centralizada.  
- Plataformas de colaboración como Slack, Notion o Teams.
''';

      case 'Herramientas de gestión de proyectos':
        return '''
Título: Herramientas de gestión de proyectos

Herramientas principales:  
- Jira: seguimiento ágil de tareas, *backlogs* y sprints.  
- Trello: tableros visuales y flujos Kanban.  
- Notion: documentación, gestión de tareas y bases de datos.  
- Microsoft Project: planificación detallada de recursos y cronogramas.

Ventajas y comparación:  
- Jira: ideal para equipos ágiles grandes, control avanzado de tareas.  
- Trello: simple, flexible, útil para equipos pequeños o proyectos ligeros.  
- Notion: muy adaptable, integra documentación y gestión de proyectos.  
- Microsoft Project: potente para planificación formal y control de recursos.

Casos de uso según tamaño del proyecto:  
- Proyectos ágiles con múltiples iteraciones: Jira o Trello.  
- Proyectos que requieren documentación centralizada: Notion.  
- Proyectos con dependencias complejas y planificación formal: Microsoft Project.
''';

    //  DISEÑO
      case 'Arquitectura de software':
        return '''
Título: Arquitectura de software

Definición de arquitectura:  
La arquitectura de software es la estructura fundamental de un sistema, que define sus componentes, sus interacciones y las directrices para su diseño y evolución. Sirve como base para la toma de decisiones técnicas y la organización del desarrollo.

Tipos de arquitectura:  
- Monolítica: Todo el sistema está integrado en una única aplicación.  
- Microservicios: Sistema dividido en servicios independientes que se comunican entre sí.  
- Limpia (*Clean Architecture*): Separación clara de responsabilidades en capas para mejorar mantenibilidad y testeo.

Importancia de separar responsabilidades:  
Una arquitectura bien definida permite escalar el sistema, facilita el mantenimiento y mejora la calidad del software al reducir acoplamientos y dependencias innecesarias.
''';

      case 'Diseño modular y orientación a objetos':
        return '''
Título: Diseño modular y orientación a objetos

Principios del diseño modular:  
Dividir el sistema en módulos independientes con responsabilidades claras, facilitando la comprensión, el mantenimiento y la reutilización del código.

Beneficios del encapsulamiento y reutilización:  
- Facilita la prueba y el mantenimiento.  
- Reduce duplicación de código y errores.  
- Permite construir sistemas más complejos de manera controlada.

Ejemplos prácticos:  
- Clases y objetos que representan entidades del negocio.  
- Módulos independientes para funciones específicas (como autenticación, gestión de usuarios o pagos).  
- Librerías reutilizables entre diferentes proyectos.
''';

      case 'Principio de responsabilidad única (SRP)':
        return '''
Título: Principio de responsabilidad única (SRP)

Definición del principio:  
Cada módulo o clase debe tener una única razón para cambiar, es decir, solo una responsabilidad bien definida.

Ejemplo de aplicación:  
- Clase “Factura” solo se encarga de manejar datos de facturación, mientras que la clase “GeneradorPDF” se encarga de generar los archivos PDF.  

Beneficios en mantenibilidad y escalabilidad:  
- Facilita la comprensión del código.  
- Reduce efectos colaterales al modificar funcionalidades.  
- Permite escalar y reutilizar componentes de manera más segura.
''';

      case 'Patrones de diseño (MVC, MVVM, Singleton)':
        return '''
Título: Patrones de diseño

Qué son los patrones de diseño:  
Soluciones probadas y reutilizables para problemas comunes en el diseño de software, que ayudan a estructurar y organizar el código de manera eficiente.

Cuándo aplicarlos:  
- MVC (Model-View-Controller): Separar lógica de negocio, presentación y control para aplicaciones web o móviles.  
- MVVM (Model-View-ViewModel): Separar la UI de la lógica de negocio con enlace de datos, común en Flutter o WPF.  
- Singleton: Garantizar que una clase tenga solo una instancia, útil para controladores o gestores de configuración.

Ejemplos comunes en Flutter o backend:  
- Usar MVC para organizar un backend en Node.js.  
- MVVM para manejar estados en Flutter con *Provider* o *Riverpod*.  
- Singleton para manejar conexión a base de datos.
''';

      case 'Diseño centrado en el usuario (UX/UI)':
        return '''
Título: Diseño centrado en el usuario (UX/UI)

Principios de UX y UI:  
- UX: Experiencia del usuario, enfocada en facilidad de uso, eficiencia y satisfacción.  
- UI: Interfaz del usuario, enfocada en diseño visual, consistencia y accesibilidad.

Ejemplos de diseño intuitivo:  
- Menús y botones claros y consistentes.  
- Flujo de navegación lógico y predecible.  
- Feedback visual para acciones del usuario.

Herramientas para prototipado y pruebas:  
- Figma, Adobe XD o Sketch para diseño de interfaces.  
- Pruebas de usuario y prototipos interactivos para validar ideas.
''';

      case 'Seguridad por diseño':
        return '''
Título: Seguridad por diseño

Concepto de seguridad preventiva:  
Integrar medidas de seguridad desde el inicio del desarrollo, anticipando vulnerabilidades y protegiendo datos sensibles.

Buenas prácticas para proteger datos y autenticación:  
- Validación y sanitización de entradas de usuario.  
- Cifrado de datos en reposo y en tránsito.  
- Gestión segura de contraseñas y tokens de autenticación.  
- Revisiones y auditorías de seguridad periódicas.

Ejemplos comunes:  
- Uso de HTTPS y certificados SSL.  
- Implementación de OAuth 2.0 para autenticación.  
- Aplicación de *input validation* para prevenir inyecciones SQL o XSS.
''';

      case 'Diagramas UML':
        return '''
Título: Diagramas UML

Tipos de diagramas:  
- Clases: Muestra la estructura del sistema y relaciones entre clases.  
- Casos de uso: Representa las interacciones entre usuarios y el sistema.  
- Secuencia: Describe el flujo de mensajes entre objetos en el tiempo.

Cuándo y cómo usarlos:  
- Durante el diseño y análisis para documentar el sistema.  
- Facilitan la comunicación entre desarrolladores y stakeholders.  
- Ayudan a identificar dependencias y potenciales problemas de arquitectura.

Herramientas recomendadas:  
- Lucidchart, Visual Paradigm, StarUML, draw.io.
''';

      case 'Reutilización de componentes':
        return '''
Título: Reutilización de componentes

Ventajas de crear componentes reutilizables:  
- Reduce duplicación de código y esfuerzo de desarrollo.  
- Facilita mantenimiento y actualización de funcionalidades.  
- Mejora la consistencia y calidad del software.

Estrategias para modularizar el código:  
- Dividir funcionalidades en módulos o librerías independientes.  
- Diseñar APIs internas claras y estables.  
- Aplicar principios de diseño como SRP y bajo acoplamiento.

Ejemplo de implementación práctica:  
- Crear un componente de botón genérico en Flutter que se puede usar en múltiples pantallas.  
- Librería de validación de formularios compartida entre distintos proyectos.
''';

    //  CODIFICACIÓN
      case 'Principios SOLID':
        return '''
[Significado de cada principio]
S — Single Responsibility: una clase debe tener una sola razón para cambiar.  
O — Open/Closed: el software debe estar abierto a extensión pero cerrado a modificación.  
L — Liskov Substitution: una subclase debe poder reemplazar a la clase base sin problemas.  
I — Interface Segregation: las interfaces deben ser específicas, no gigantes con métodos innecesarios.  
D — Dependency Inversion: las dependencias deben apuntar a abstracciones, no a implementaciones.

[Ejemplos en código]
- Aplicar SRP separando lógica de negocio y lógica de presentación.  
- Utilizar interfaces y clases abstractas para permitir extensiones futuras.  
- Invertir dependencias usando inyección de dependencias.

[Ventajas en escalabilidad y mantenimiento]
- Código más modular.  
- Facilita pruebas unitarias.  
- Reduce acoplamiento.  
- Permite agregar nuevas funcionalidades sin romper las existentes.
''';

      case 'Principio DRY y KISS':
        return '''
[Definición de cada principio]
DRY — Don't Repeat Yourself: evita duplicar lógica, datos o estructuras.  
KISS — Keep It Simple, Stupid: el diseño debe ser lo más simple posible.

[Cómo aplicarlos en código limpio]
- Crear funciones reutilizables.  
- Evitar copiar y pegar código.  
- Dividir problemas grandes en piezas simples.  
- Elegir soluciones claras en lugar de "trucos" complejos.

[Errores comunes al no seguirlos]
- Múltiples versiones del mismo algoritmo difíciles de mantener.  
- Código innecesariamente complejo que causa bugs.  
- Tiempos mayores de desarrollo debido a duplicidad.
''';

      case 'Principio YAGNI':
        return '''
[Significado y aplicación práctica]
YAGNI — You Aren’t Gonna Need It: no implementes funcionalidades hasta que sean realmente necesarias.

[Relación con la simplicidad del diseño]
- Evita la sobreingeniería.  
- Reduce esfuerzo perdido en código que no se usa.  
- Permite que el sistema evolucione solo cuando el negocio lo exige.
''';

      case 'Refactorización de código':
        return '''
[Qué es refactorizar]
Refactorizar es mejorar la estructura interna del código sin cambiar su comportamiento externo.

[Cuándo hacerlo]
- Al detectar duplicidad.  
- Cuando el código se vuelve difícil de leer.  
- Después de implementar nuevas características.  
- Como parte del ciclo de TDD: Red → Green → Refactor.

[Técnicas y herramientas recomendadas]
- Renombrar variables y métodos para claridad.  
- Extraer métodos/clases.  
- Eliminar código muerto.  
- Herramientas: SonarQube, linters, IDE refactor tools.
''';

      case 'Control de versiones con Git':
        return '''
[Conceptos básicos de Git]
- Repositorios.  
- Commits.  
- Branches.  
- Merge y rebase.  
- Staging area.

[Flujos de trabajo: Git Flow, trunk-based]
- Git Flow: ramas largas, releases, hotfixes.  
- Trunk-based: integración continua en main con ramas cortas.

[Buenas prácticas en commits y ramas]
- Commits pequeños y descriptivos.  
- Ramas por feature o bugfix.  
- Evitar commits "misc" o "fix all".  
- Integrar cambios frecuentemente.
''';


      case 'Comentarios y documentación':
        return '''
[Importancia de documentar el código]
- Facilita mantenimiento.  
- Ayuda al equipo a entender el propósito del código.  
- Soporta la continuidad del proyecto.

[Tipos de documentación: técnica, API, usuario]
- Técnica: arquitectura, decisiones, diagramas.  
- API: endpoints, modelos, ejemplos de uso.  
- Usuario: cómo utilizar el sistema o app.

[Ejemplos de comentarios útiles]
- Explicación de una decisión técnica.  
- Indicar complejidades ocultas.  
- Describir parámetros o side-effects.
''';


      case 'Revisión de código (Code Review)':
        return '''
[Propósito de las revisiones]
- Mejorar calidad del código.  
- Detectar errores antes de llegar a producción.  
- Compartir conocimiento entre el equipo.

[Checklist de revisión de calidad]
- Legibilidad.  
- Estructura limpia.  
- Eliminación de duplicidad.  
- Seguridad y validaciones.  
- Manejo adecuado de errores.  
- Pruebas incluidas.

[Beneficios para el equipo]
- Cohesión técnica.  
- Menor acumulación de deuda técnica.  
- Estándares más consistentes.
''';


      case 'Integración y despliegue continuo (CI/CD)':
        return '''
[Concepto de CI/CD]
CI — Integración Continua: integrar cambios frecuentemente para detectar errores rápido.  
CD — Despliegue Continuo: automatizar despliegues en ambientes productivos o preproductivos.

[Herramientas comunes: Jenkins, GitHub Actions, GitLab CI]
- Jenkins: muy configurable.  
- GitHub Actions: integrado con GitHub.  
- GitLab CI/CD: pipelines nativos y fáciles de configurar.

[Ventajas de la automatización]
- Menos errores humanos.  
- Despliegues consistentes.  
- Feedback rápido.  
- Mayor velocidad de entrega.
''';


      case 'Manejo de errores y excepciones':
        return '''
[Tipos de errores comunes]
- Errores de lógica.  
- Errores de validación.  
- Excepciones no controladas.  
- Errores de red, IO o tiempo de espera.

[Estrategias de manejo y logging]
- Try/catch bien ubicado.  
- Logs detallados sin exponer datos sensibles.  
- Retries cuando corresponda.  
- Fallbacks y degradación controlada.

[Buenas prácticas de resiliencia]
- Validar datos antes de operar.  
- No capturar excepciones genéricas sin necesidad.  
- Implementar monitoreo y alertas.
''';


      case 'Optimización y eficiencia':
        return '''
[Técnicas de optimización]
- Reducir operaciones costosas.  
- Usar estructuras de datos adecuadas.  
- Evitar loops innecesarios.  
- Caching.

[Medición de rendimiento]
- Benchmarks.  
- Profilers.  
- Métricas de tiempo y memoria.

[Balance entre legibilidad y velocidad]
- Primero legible, luego rápido.  
- Optimizar solo cuando es necesario.  
- Evitar microoptimizaciones prematuras.
''';


      case 'Entorno de desarrollo (IDE y herramientas)':
        return '''
[Configuración del entorno]
- Ajustar formateo automático.  
- Atajos de teclado.  
- Configurar compiladores y runtimes.

[Plugins útiles]
- Linter.  
- Autocompletado avanzado.  
- Integración con Git.  
- Snippets para acelerar escritura.

[Consejos para productividad]
- Mantener el entorno limpio.  
- Automatizar tareas repetitivas.  
- Usar terminal integrada.  
- Organizar el proyecto en carpetas claras.
''';


    //  PRUEBAS
      case 'Pruebas unitarias':
        return '''
Título: Principios SOLID

Significado de cada principio:  
- S: Single Responsibility Principle (SRP) – Una clase debe tener una única responsabilidad.  
- O: Open/Closed Principle – Abierto a extensión, cerrado a modificación.  
- L: Liskov Substitution Principle – Las subclases deben ser sustituibles por sus clases base.  
- I: Interface Segregation Principle – Interfaces pequeñas y específicas, no generales.  
- D: Dependency Inversion Principle – Dependencia de abstracciones, no de implementaciones concretas.

Ejemplos en código:  
- Uso de clases enfocadas en una sola tarea.  
- Interfaces específicas para funcionalidades concretas.  
- Dependencia inyectada mediante interfaces en lugar de instancias directas.

Ventajas en escalabilidad y mantenimiento:  
- Código más limpio, modular y reutilizable.  
- Menor riesgo de errores al realizar cambios.  
- Facilita pruebas unitarias y refactorización.
''';

      case 'Pruebas de integración':
        return '''
    return `
Título: Principio DRY y KISS

Definición de cada principio:  
- DRY (Don’t Repeat Yourself)**: Evitar duplicación de código, centralizando la lógica.  
- KISS (Keep It Simple, Stupid)**: Mantener el diseño simple y claro, evitando complejidad innecesaria.

Cómo aplicarlos en código limpio:  
- Crear funciones y módulos reutilizables.  
- Escribir código legible y fácil de entender.  
- Evitar soluciones excesivamente complicadas cuando una simple es suficiente.

Errores comunes al no seguirlos:  
- Código duplicado que dificulta mantenimiento.  
- Sistemas complejos y difíciles de depurar.  
- Mayor probabilidad de introducir errores al modificar código repetido.
''';

      case 'Pruebas de sistema y aceptación':
        return '''
Título: Principio YAGNI

Significado y aplicación práctica:  
YAGNI (You Aren’t Gonna Need It) indica que no se debe implementar funcionalidades hasta que sean realmente necesarias, evitando sobrecargar el software con características innecesarias.

Relación con la simplicidad del diseño:  
- Mantiene el código más limpio y fácil de mantener.  
- Reduce tiempo y esfuerzo en desarrollo.  
- Evita complejidad innecesaria y dependencias no usadas.
''';

      case 'Pruebas automatizadas':
        return '''
Título: Refactorización de código

Qué es refactorizar:  
Es el proceso de mejorar la estructura interna del código sin cambiar su comportamiento externo, buscando claridad, eficiencia y mantenibilidad.

Cuándo hacerlo:  
- Antes de agregar nuevas funcionalidades.  
- Después de detectar código duplicado o mal estructurado.  
- Al realizar mantenimiento o corrección de errores.

Técnicas y herramientas recomendadas:  
- Renombrar variables y métodos para mayor claridad.  
- Extraer funciones o clases para modularizar.  
- IDEs con soporte para refactorización automática (VSCode, IntelliJ).  
- Pruebas unitarias para asegurar que el comportamiento se mantiene.
''';

      case 'Pruebas de rendimiento y carga':
        return '''
Título: Control de versiones con Git

Conceptos básicos de Git:  
- Repositorios locales y remotos.  
- Commits, ramas y merges.  
- Historia de cambios y recuperación de versiones anteriores.

Flujos de trabajo:  
- Git Flow: ramas específicas para desarrollo, producción y releases.  
- Trunk-Based Development: integración continua en la rama principal.

Buenas prácticas en commits y ramas:  
- Mensajes de commit claros y descriptivos.  
- Ramas cortas y enfocadas en tareas específicas.  
- Revisar y probar antes de fusionar cambios.
''';

      case 'Pruebas de seguridad':
        return '''
Título: Comentarios y documentación

Importancia de documentar el código:  
Permite que otros desarrolladores comprendan la lógica, facilita mantenimiento y asegura la transferencia de conocimiento.

Tipos de documentación:  
- Técnica: explicación detallada del código y arquitectura.  
- API: instrucciones para uso de funciones o servicios.  
- Usuario: guía sobre cómo utilizar la aplicación o sistema.

Ejemplos de comentarios útiles:  
- Explicar la razón de decisiones complejas.  
- Documentar algoritmos y fórmulas utilizadas.  
- Marcar TODOs o mejoras pendientes de manera clara.
''';

      case 'Pruebas de usabilidad':
        return '''
Título: Revisión de código (Code Review)

Propósito de las revisiones:  
- Detectar errores antes de integrar cambios.  
- Asegurar consistencia y calidad del código.  
- Compartir conocimiento entre miembros del equipo.

Checklist de revisión de calidad:  
- Código limpio y legible.  
- Buen uso de principios de diseño y patrones.  
- Pruebas unitarias y cobertura adecuada.  
- Cumplimiento de estándares y convenciones.

Beneficios para el equipo:  
- Mejora de la calidad general del software.  
- Aprendizaje y difusión de buenas prácticas.  
- Reducción de bugs y problemas en producción.
''';

      case 'Cobertura y regresión de código':
        return '''
Título: Integración y despliegue continuo (CI/CD)

Concepto de CI/CD:  
- **CI (Integración Continua)**: Combinar cambios frecuentemente en la rama principal, con pruebas automáticas.  
- **CD (Despliegue Continuo)**: Automatizar la entrega y despliegue de software a entornos de producción.

Herramientas comunes:  
- Jenkins, GitHub Actions, GitLab CI, CircleCI.

Ventajas de la automatización:  
- Reducción de errores humanos.  
- Entrega rápida de funcionalidades.  
- Feedback inmediato sobre fallos o problemas de integración.
''';

    //  GESTIÓN Y MEJORA CONTINUA
      case 'Retrospectivas y mejora continua':
        return '''
Título: Retrospectivas y mejora continua

Qué es una retrospectiva:  
Reunión periódica del equipo para analizar lo que funcionó, lo que no y qué se puede mejorar en el próximo ciclo de trabajo.

Estructura de la reunión:  
- Revisión de objetivos cumplidos y pendientes.  
- Identificación de problemas y obstáculos.  
- Generación de acciones concretas de mejora.  
- Compromiso del equipo con los cambios.

Importancia del aprendizaje iterativo:  
- Permite mejorar procesos y productos de forma continua.  
- Fomenta la comunicación y colaboración del equipo.  
- Reduce errores y optimiza la productividad en ciclos futuros.
''';

      case 'Métricas e indicadores (KPIs)':
        return '''
Título: Métricas e indicadores (KPIs)

Qué son los KPIs:  
Indicadores clave de desempeño que permiten medir el progreso, eficiencia y calidad del trabajo de un equipo de desarrollo.

Ejemplos aplicables a equipos de desarrollo:  
- Velocidad (*velocity*) en Scrum.  
- Número de errores encontrados y corregidos.  
- Cobertura de pruebas unitarias.  
- Tiempo promedio de resolución de incidencias.

Cómo medir progreso y calidad:  
- Definir KPIs claros y relevantes para los objetivos del proyecto.  
- Monitorear y reportar periódicamente.  
- Ajustar estrategias según resultados para mejorar desempeño.
''';

      case 'Feedback y auditoría de código':
        return '''
Título: Feedback y auditoría de código

Diferencias entre revisión y auditoría:  
- Revisión de código: proceso colaborativo para mejorar calidad y compartir conocimiento.  
- Auditoría de código: evaluación formal de cumplimiento de estándares, seguridad y buenas prácticas.

Cómo dar feedback constructivo:  
- Ser específico y objetivo, centrándose en el código y no en la persona.  
- Sugerir mejoras prácticas y alternativas.  
- Fomentar el aprendizaje y la colaboración del equipo.

Impacto en la mejora continua:  
- Mejora la calidad del software y reduce errores futuros.  
- Promueve buenas prácticas y consistencia en el código.  
- Facilita la transferencia de conocimiento y desarrollo profesional.
''';

      case 'Control de calidad (QA)':
        return '''
Título: Control de calidad (QA)

Concepto de QA:  
Aseguramiento de la calidad mediante procesos de verificación y validación que garantizan que el software cumpla con los requisitos y estándares definidos.

Proceso de verificación y validación:  
- Planificación de pruebas y definición de casos de prueba.  
- Ejecución de pruebas manuales y automatizadas.  
- Registro y seguimiento de incidencias.  
- Revisión de resultados y mejora continua del proceso.

Rol del QA en equipos ágiles:  
- Colaborar con desarrolladores para prevenir errores.  
- Validar funcionalidades y detectar problemas antes de producción.  
- Mantener métricas de calidad y retroalimentar al equipo.
''';

      case 'Integridad y cumplimiento normativo':
        return '''
Título: Integridad y cumplimiento normativo

Normas y estándares:  
- ISO 9001, ISO/IEC 25010: estándares de calidad de software.  
- GDPR y otras leyes de protección de datos personales.

Cómo asegurar cumplimiento técnico y legal:  
- Implementar políticas de seguridad y privacidad desde el diseño.  
- Auditorías y revisiones periódicas de procesos y código.  
- Capacitación del equipo en normas y regulaciones aplicables.
''';

      case 'Colaboración en equipo y cultura DevOps':
        return '''
Título: Colaboración en equipo y cultura DevOps

Qué es DevOps:  
Cultura y conjunto de prácticas que integra desarrollo de software (Dev) y operaciones (Ops) para entregar aplicaciones de forma más rápida, confiable y continua.

Principios de colaboración y entrega continua:  
- Comunicación y coordinación entre equipos de desarrollo y operaciones.  
- Automatización de pruebas, integración y despliegue.  
- Monitoreo constante y retroalimentación rápida.

Herramientas que facilitan la cultura DevOps:  
- Jenkins, GitHub Actions, GitLab CI/CD para automatización.  
- Docker, Kubernetes para despliegue y orquestación de contenedores.  
- Slack, Teams o Notion para comunicación y coordinación.
''';

      case 'Actualización profesional y tendencias':
        return '''
Título: Actualización profesional y tendencias

Importancia de mantenerse actualizado:  
El sector tecnológico evoluciona constantemente; aprender nuevas herramientas, lenguajes y metodologías es clave para mantenerse competitivo y eficiente.

Fuentes de aprendizaje:  
- Blogs y newsletters especializados.  
- Cursos online y certificaciones.  
- Conferencias, webinars y meetups del sector.  
- Comunidades y foros de desarrolladores.

Competencias más demandadas actualmente:  
- Desarrollo en la nube y DevOps.  
- Inteligencia artificial y machine learning.  
- Seguridad informática y protección de datos.  
- Programación en múltiples lenguajes y frameworks modernos.
''';

      case 'Desarrollo guiado por pruebas (TDD)':
        return '''
Título: Desarrollo guiado por pruebas (TDD)

Definición:
TDD (Test-Driven Development) es una metodología donde las pruebas se escriben antes del código funcional. Se sigue el ciclo: Red (escribir prueba), Green (hacerla pasar), Refactor (mejorar código sin cambiar comportamiento).

Importancia:
Asegura que el código se construya con propósito, reduce errores y hace que el diseño sea más limpio y modular.

Beneficios:
- Menor número de bugs en producción.
- Código más fácil de mantener.
- Mayor confianza al refactorizar.
- Diseño más claro desde la base.

Ejemplos:
- Crear una función que calcule descuentos comenzando por una prueba que defina el resultado esperado.
''';

      case 'Integración de APIs y Servicios REST':
        return '''
Título: Integración de APIs y Servicios REST

Definición:
Consiste en consumir o exponer servicios a través de HTTP utilizando endpoints que intercambian datos, típicamente en formato JSON.

Importancia:
Permite construir aplicaciones conectadas, escalables y distribuidas mediante la comunicación entre sistemas.

Beneficios:
- Separación entre frontend y backend.
- Integración con terceros (pagos, mapas, autenticación).
- Reutilización de servicios.

Ejemplos:
- Consumir API de clima en una app móvil.
- Exponer endpoints CRUD para una base de datos.
''';

      case 'Programación asíncrona y concurrencia':
        return '''
Título: Programación asíncrona y concurrencia

Definición:
Técnicas que permiten ejecutar tareas al mismo tiempo o sin bloquear el flujo principal, utilizando hilos, futuros, async/await, o promesas.

Importancia:
Evita bloqueos, mejora el rendimiento y permite manejar procesos complejos como peticiones múltiples o tareas pesadas.

Beneficios:
- Mejor experiencia del usuario.
- Mayor rendimiento en aplicaciones.
- Procesamiento eficiente de múltiples tareas.

Ejemplos:
- Llamadas HTTP concurrentes.
- Procesamiento de archivos en segundo plano.
''';

      case 'Contenedores y Docker':
        return '''
Título: Contenedores y Docker

Definición:
Docker permite empaquetar aplicaciones con todas sus dependencias en contenedores portables y reproducibles.

Importancia:
Asegura que la aplicación funcione igual en cualquier entorno (dev, test, prod).

Beneficios:
- Despliegue rápido y consistente.
- Aislamiento de servicios.
- Escalabilidad en la nube.

Ejemplos:
- Ejecutar una API dentro de un contenedor.
- Crear múltiples servicios usando Docker Compose.
''';

      case 'Kubernetes y orquestación':
        return '''
Título: Kubernetes y orquestación

Definición:
Kubernetes es una plataforma de orquestación que automatiza despliegue, escalado y gestión de aplicaciones basadas en contenedores.

Importancia:
Permite manejar sistemas complejos distribuidos de manera estable y automatizada.

Beneficios:
- Escalado automático.
- Alta disponibilidad.
- Gestión centralizada de servicios.

Ejemplos:
- Escalar automáticamente pods según carga.
- Distribuir contenedores en clústeres.
''';

      case 'Observabilidad: logs, métricas y trazas':
        return '''
Título: Observabilidad (Logs, métricas y trazas)

Definición:
Conjunto de prácticas para monitorear aplicaciones mediante registros, estadísticas y seguimiento de solicitudes.

Importancia:
Permite detectar errores, diagnosticar problemas y entender el comportamiento en producción.

Beneficios:
- Mejor tiempo de respuesta ante fallos.
- Detección de cuellos de botella.
- Visión completa del sistema.

Ejemplos:
- Uso de herramientas como Grafana, Prometheus, ELK.
''';

      case 'Arquitectura orientada a eventos':
        return '''
Título: Arquitectura orientada a eventos

Definición:
Modelo de arquitectura donde los sistemas reaccionan a eventos generados y consumidos mediante colas, tópicos o brokers.

Importancia:
Favorece la escalabilidad, la independencia de servicios y una alta capacidad de procesamiento.

Beneficios:
- Comunicación desacoplada.
- Procesamiento asíncrono.
- Mejor rendimiento en sistemas distribuidos.

Ejemplos:
- Uso de Kafka, RabbitMQ o AWS SNS/SQS.
''';

      case 'Cloud Computing (AWS, Azure, GCP)':
        return '''
Título: Cloud Computing

Definición:
Uso de recursos computacionales bajo demanda (almacenamiento, servidores, bases de datos) ofrecidos por proveedores en la nube.

Importancia:
Permite escalar aplicaciones globalmente sin gestionar infraestructura física.

Beneficios:
- Pago por uso.
- Alta disponibilidad.
- Escalabilidad automática.

Ejemplos:
- Desplegar una API en AWS Lambda.
- Usar Firebase como backend sin servidor.
''';

      case 'Desarrollo móvil multiplataforma':
        return '''
Título: Desarrollo móvil multiplataforma

Definición:
Creación de aplicaciones móviles que funcionan tanto en iOS como Android con un solo código base (ej: Flutter, React Native).

Importancia:
Reduce tiempos y costos de desarrollo.

Beneficios:
- Mantenimiento centralizado.
- Experiencia consistente en ambas plataformas.
- Reutilización de componentes.

Ejemplos:
- Apps creadas con Flutter usando widgets reutilizables.
''';

      case 'Bases de datos SQL y NoSQL':
        return '''
Título: Bases de datos SQL y NoSQL

Definición:
Dos enfoques de almacenamiento: SQL basado en tablas y relaciones; NoSQL basado en documentos, grafos o columnas.

Importancia:
Permiten elegir la mejor estructura según el tipo de datos y necesidades del proyecto.

Beneficios:
- SQL: integridad y estructura estable.
- NoSQL: flexibilidad y alto rendimiento en escalabilidad horizontal.

Ejemplos:
- PostgreSQL, MySQL, MongoDB, Redis, Cassandra.
''';

      case 'Caso de uso: Gestión de usuarios':
        return '''
Título: Caso de uso - Gestión de usuarios

Descripción:
El sistema debe permitir que un usuario pueda registrarse, iniciar sesión y actualizar sus datos personales.

Actores:
- Usuario
- Sistema de autenticación

Flujo principal:
1. El usuario ingresa sus datos para registrarse.
2. El sistema valida la información y crea la cuenta.
3. El usuario puede iniciar sesión con credenciales válidas.
4. El usuario actualiza información (nombre, email, contraseña).
5. El sistema confirma los cambios.

Objetivo:
Practicar autenticación, validaciones, manejo de errores y CRUD básico.

Ejercicios sugeridos:
- Validación de contraseñas seguras.
- Manejo de sesión y tokens.
- Almacenamiento en base de datos.
''';

      case 'Caso de uso: Carrito de compras':
        return '''
Título: Caso de uso - Carrito de compras

Descripción:
El sistema permite añadir, modificar y eliminar productos del carrito antes de proceder al pago.

Actores:
- Cliente
- Sistema de inventario

Flujo principal:
1. El cliente selecciona un producto del catálogo.
2. Lo agrega al carrito.
3. Puede actualizar cantidades.
4. Puede eliminar productos.
5. El sistema muestra el total actualizado.

Objetivo:
Practicar estructuras de datos, cálculos, estados de UI y persistencia temporal.

Ejercicios sugeridos:
- Calcular subtotales y totales.
- Verificar disponibilidad de inventario.
- Guardar carrito localmente.
''';

      case 'Caso de uso: Gestión de tareas':
        return '''
Título: Caso de uso - Gestión de tareas

Descripción:
El usuario crea tareas, las organiza, cambia su estado y las elimina cuando están completadas.

Actores:
- Usuario

Flujo principal:
1. Crear una nueva tarea.
2. Marcar como completada / pendiente.
3. Editar nombre o descripción.
4. Eliminar tareas.
5. Filtrar entre completadas, pendientes y todas.

Objetivo:
Practicar CRUD, filtros, validaciones y estados.

Ejercicios sugeridos:
- Añadir prioridad a las tareas.
- Añadir categorías y búsquedas.
- Sincronizar tareas con backend.
''';

      case 'Caso de uso: Reservas de citas':
        return '''
Título: Caso de uso - Reservas de citas

Descripción:
El usuario elige un día y hora disponible para agendar una cita con un proveedor de servicio.

Actores:
- Usuario
- Sistema de agenda

Flujo principal:
1. El usuario selecciona un servicio.
2. El sistema muestra horarios disponibles.
3. El usuario selecciona un horario.
4. El sistema valida disponibilidad y registra la cita.
5. Se envía confirmación y opción de cancelar.

Objetivo:
Practicar manejo de fechas, disponibilidad, validaciones y transacciones.

Ejercicios sugeridos:
- Evitar doble reserva.
- Enviar recordatorios.
- Calcular duración de servicios.
''';

      case 'Caso de uso: Sistema de comentarios':
        return '''
Título: Caso de uso - Sistema de comentarios

Descripción:
Los usuarios pueden publicar comentarios, responderlos y calificarlos con "me gusta".

Actores:
- Usuario autenticado

Flujo principal:
1. Publicar comentario en una publicación.
2. Responder a otro comentario.
3. Eliminar su propio comentario.
4. Dar "me gusta".
5. El sistema actualiza el contador.

Objetivo:
Practicar relaciones en base de datos, jerarquías (comentarios anidados) y moderación.

Ejercicios sugeridos:
- Limitar longitud de comentarios.
- Detectar spam.
- Ordenar por relevancia o fecha.
''';

      case 'Caso de uso: Gestión de archivos':
        return '''
Título: Caso de uso - Gestión de archivos

Descripción:
El usuario sube archivos, los visualiza, los elimina o los reemplaza.

Actores:
- Usuario

Flujo principal:
1. Seleccionar archivo.
2. Validar tipo y tamaño.
3. Subirlo al servidor.
4. Mostrar lista de archivos.
5. El usuario puede eliminar o reemplazar.

Objetivo:
Practicar validaciones, almacenamiento, manejo de errores y seguridad.

Ejercicios sugeridos:
- Limitar tamaños.
- Previsualización de imágenes.
- Manejo de archivos duplicados.
''';

      case 'Caso de uso: Sistema de notificaciones':
        return '''
Título: Caso de uso - Sistema de notificaciones

Descripción:
El sistema envía notificaciones al usuario según eventos (mensajes, actualizaciones, alertas).

Actores:
- Usuario
- Sistema

Flujo principal:
1. Ocurre un evento relevante.
2. El sistema genera una notificación.
3. El usuario la recibe (push, email o in-app).
4. El usuario la marca como leída.

Objetivo:
Practicar asincronía, colas de mensajes y UX de notificaciones.

Ejercicios sugeridos:
- Notificaciones locales vs push.
- Bandeja de notificaciones con estado.
- Configuración de preferencias del usuario.
''';

      case 'Caso de uso: UML - Diagrama de Clases':
        return '''
Título: Caso de uso - Crear un Diagrama de Clases

Descripción:
El estudiante debe representar la estructura de un sistema mediante clases, atributos, métodos y relaciones (herencia, agregación, composición, asociaciones).

Actores:
- Estudiante
- Sistema a modelar (descripción del problema)

Flujo principal:
1. Leer el caso del sistema.
2. Identificar entidades principales.
3. Transformarlas en clases con atributos y métodos.
4. Definir las relaciones entre clases.
5. Dibujar el diagrama UML completo.

Objetivo:
Practicar la identificación de clases, relaciones y responsabilidades.

Ejercicios sugeridos:
- Crear un diagrama de clases para un sistema de biblioteca.
- Representar herencia e interfaces.
- Separar clases de dominio, servicios y controladores.
''';

      case 'Caso de uso: UML - Diagrama de Secuencia':
        return '''
Título: Caso de uso - Crear un Diagrama de Secuencia

Descripción:
Modelar cómo interactúan los objetos en el tiempo para ejecutar una funcionalidad del sistema.

Actores:
- Estudiante
- Objetos del sistema

Flujo principal:
1. Seleccionar un caso de uso (ej: "iniciar sesión").
2. Identificar participantes (usuario, controlador, servicio, repositorio).
3. Determinar mensajes enviados entre objetos.
4. Ordenar los mensajes cronológicamente.
5. Dibujar el diagrama con lifelines y activations.

Objetivo:
Comprender el flujo dinámico del sistema y la interacción entre capas.

Ejercicios sugeridos:
- Diagrama de secuencia para registrar un usuario.
- Manejo de errores (credenciales inválidas).
- Diagrama para procesar un pago en un ecommerce.
''';

      case 'Caso de uso: UML - Diagrama de Actividades':
        return '''
Título: Caso de uso - Crear un Diagrama de Actividades

Descripción:
Representar el flujo de actividades, decisiones y paralelismos dentro de un proceso del sistema.

Actores:
- Estudiante

Flujo principal:
1. Identificar el proceso principal.
2. Dividirlo en actividades.
3. Agregar decisiones, uniones y bifurcaciones si aplica.
4. Dibujar el flujo desde inicio a fin.
5. Validar coherencia del proceso.

Objetivo:
Practicar modelado de procesos y flujos lógicos.

Ejercicios sugeridos:
- Diagrama de actividades para el proceso de checkout.
- Manejar ramificaciones (carrito vacío, producto sin stock).
- Flujo de aprobación de un documento.
''';

      case 'Caso de uso: UML - Diagrama de Casos de Uso':
        return '''
Título: Caso de uso - Crear un Diagrama de Casos de Uso

Descripción:
Modelar funcionalidades del sistema desde la perspectiva del usuario mediante actores y casos de uso.

Actores:
- Estudiante
- Usuarios del sistema

Flujo principal:
1. Identificar actores.
2. Identificar casos de uso principales.
3. Definir relaciones (include, extend, generalización).
4. Crear el diagrama.
5. Validar límites del sistema.

Objetivo:
Aprender a representar requerimientos funcionales visualmente.

Ejercicios sugeridos:
- Diagrama de casos de uso para una app de banco.
- Añadir casos extendidos para errores.
- Separar actores principales y secundarios.
''';

      case 'Caso de uso: UML - Diagrama de Estados':
        return '''
Título: Caso de uso - Crear un Diagrama de Estados

Descripción:
Representar los distintos estados que puede atravesar un objeto y los eventos que producen cambios entre esos estados.

Actores:
- Estudiante

Flujo principal:
1. Elegir un objeto con comportamiento dinámico (ej: pedido, sesión).
2. Identificar estados posibles.
3. Identificar transiciones entre estados.
4. Agregar eventos y condiciones.
5. Dibujar el diagrama de estados completo.

Objetivo:
Comprender comportamientos de ciclo de vida y lógica de transición.

Ejercicios sugeridos:
- Estado de un pedido (creado → pagado → enviado → entregado).
- Estados de una sesión de usuario.
- Ciclo de vida de un ticket de soporte.
''';

      case 'Caso de uso: UML - Diagrama de Componentes':
        return '''
Título: Caso de uso - Crear un Diagrama de Componentes

Descripción:
Modelar la arquitectura del sistema a nivel de módulos, componentes, servicios y dependencias.

Actores:
- Estudiante

Flujo principal:
1. Identificar módulos principales del sistema.
2. Agrupar funcionalidades en componentes.
3. Definir interfaces y dependencias.
4. Dibujar el diagrama con conectores.
5. Validar cohesión y acoplamiento.

Objetivo:
Practicar representación de arquitectura modular.

Ejercicios sugeridos:
- Componentes de una app con frontend, API y base de datos.
- Servicio de autenticación separado.
- Integración con servicios externos.
''';

      case 'Libros y autores: Robert C. Martin':
        return '''
Título: Robert C. Martin (Uncle Bob)

Descripción:
Uno de los autores más influyentes en buenas prácticas de programación y arquitectura. Defensor de la disciplina, el código limpio y el desarrollo profesional.

Ideas principales:
- El código debe ser legible, simple y expresivo.
- Las funciones deben ser pequeñas y hacer una sola cosa.
- La arquitectura limpia separa reglas de negocio de detalles técnicos.
- La responsabilidad del desarrollador es escribir software mantenible.

Libros recomendados:
- Clean Code
- Clean Architecture
- The Clean Coder

Temas ideales para investigar:
- Principios SOLID
- Responsabilidad profesional del desarrollador
- Diseño orientado a la mantenibilidad
''';

      case 'Libros y autores: Martin Fowler':
        return '''
Título: Martin Fowler

Descripción:
Experto en arquitectura, patrones de diseño, refactorización y diseño orientado a dominios. Miembro destacado de ThoughtWorks.

Ideas principales:
- El software debe evolucionar mediante refactorizaciones constantes.
- Los patrones de arquitectura deben responder a contextos reales.
- La documentación viva es más útil que los documentos rígidos.
- La arquitectura orientada a eventos y microservicios deben construirse con intención, no por moda.

Libros recomendados:
- Refactoring
- Patterns of Enterprise Application Architecture
- NoSQL Distilled

Temas ideales para investigar:
- Patrones arquitectónicos
- Refactorización estructural
- Microservicios vs monolitos
''';

      case 'Libros y autores: Kent Beck':
        return '''
Título: Kent Beck

Descripción:
Uno de los padres de XP (Extreme Programming) y creador de TDD. Enfocado en metodologías ágiles y desarrollo dirigido por pruebas.

Ideas principales:
- Las pruebas deben guiar el diseño del software.
- La simplicidad es una virtud absoluta en ingeniería.
- El feedback temprano y continuo reduce errores.
- La comunicación y colaboración son parte esencial del código.

Libros recomendados:
- Test-Driven Development: By Example
- Extreme Programming Explained

Temas ideales para investigar:
- TDD
- XP (Extreme Programming)
- Refactorización disciplinada
''';

      case 'Libros y autores: Gang of Four (GoF)':
        return '''
Título: Gang of Four (GoF)

Descripción:
Autores del libro que definió los patrones de diseño modernos, base fundamental del diseño orientado a objetos.

Ideas principales:
- Los patrones de diseño ayudan a resolver problemas comunes.
- El uso correcto de patrones reduce duplicidad y aumenta claridad.
- Los patrones no deben imponerse, sino surgir del diseño.

Libro recomendado:
- Design Patterns: Elements of Reusable Object-Oriented Software

Temas ideales para investigar:
- Patrones creacionales, estructurales y de comportamiento
- Buenas prácticas de diseño OO
- Identificación de patrones en proyectos reales
''';

      case 'Libros y autores: Eric Evans':
        return '''
Título: Eric Evans

Descripción:
Autor del libro que estableció el Diseño Orientado al Dominio (DDD). Enfocado en conectar el lenguaje del negocio con el diseño del software.

Ideas principales:
- El dominio del problema es más importante que la tecnología.
- El lenguaje ubicuo debe ser compartido por equipo y negocio.
- Los contextos delimitados evitan acoplamiento innecesario.
- La arquitectura refleja el modelo del dominio.

Libro recomendado:
- Domain-Driven Design: Tackling Complexity in the Heart of Software

Temas ideales para investigar:
- DDD táctico y estratégico
- Contextos delimitados
- Event Storming
''';

      case 'Libros y autores: Jez Humble':
        return '''
Título: Jez Humble

Descripción:
Experto en DevOps, integración continua, entrega continua y prácticas modernas de despliegue.

Ideas principales:
- La entrega continua reduce riesgos y acelera la salida al mercado.
- La automatización es esencial para la calidad.
- Los equipos deben integrar pruebas, despliegue y monitoreo como parte del desarrollo.

Libros recomendados:
- Continuous Delivery
- Accelerate

Temas ideales para investigar:
- CI/CD
- Infraestructura como código
- Métricas de alto desempeño en equipos
''';

      case 'Libros y autores: Steve McConnell':
        return '''
Título: Steve McConnell

Descripción:
Autor de libros clásicos sobre buenas prácticas, estimación y administración de proyectos de software.

Ideas principales:
- La calidad no es negociable; es una inversión.
- La estimación es una disciplina aprendible.
- El diseño debe ser flexible y seguro desde el inicio.

Libros recomendados:
- Code Complete
- Rapid Development

Temas ideales para investigar:
- Técnicas de diseño estructurado
- Mejores prácticas de desarrollo profesional
- Gestión y estimación de proyectos
''';

      case 'Libros y autores: The Pragmatic Programmers':
        return '''
Título: Andrew Hunt & David Thomas

Descripción:
Autores del influyente libro "The Pragmatic Programmer", centrado en la mentalidad profesional del desarrollador.

Ideas principales:
- La responsabilidad del software comienza en el desarrollador.
- La comunicación es parte crítica del código.
- La automatización evita errores repetitivos.
- Pensar de forma pragmática mejora productividad y calidad.

Libro recomendado:
- The Pragmatic Programmer

Temas ideales para investigar:
- Técnicas de productividad personal en desarrollo
- Automatización de tareas
- Manejo consciente del conocimiento técnico
''';

      case 'Videos de apoyo':
        return '''
Título: Videos de apoyo

Descripción: aqui tienes algunos videos que puedes  visitar si quieres mas Informacion:

Videos:
-https://youtu.be/VCzlFblmvSE?si=r-tm2BtpbWCuyLYQ

''';

      default:
        return 'Contenido en desarrollo para "$topic".';

    }
  }
}


// Pantalla de ejemplos con buscador
class ExamplesScreen extends StatefulWidget {
  @override
  _ExamplesScreenState createState() => _ExamplesScreenState();
}

class _ExamplesScreenState extends State<ExamplesScreen> {
  String searchQuery = '';

  final Map<String, List<Map<String, String>>> categorizedExamples = {
    'Fundamentales': [
      {
        'titulo': 'Ejemplo de mal código',
        'codigo': 'int suma(a, b) { return a+b; }'
      },
      {
        'titulo': 'Ejemplo con buenas prácticas',
        'codigo': 'int suma(int a, int b) {\n  return a + b;\n}'
      },
      {
        'titulo': 'Variables sin tipo (mala práctica)',
        'codigo': 'var x = 10;\nvar y = "20";\nprint(x + y); // Error en runtime'
      },
      {
        'titulo': 'Tipado explícito (buena práctica)',
        'codigo': 'int x = 10;\nint y = 20;\nprint(x + y);'
      },
      {
        'titulo': 'Uso incorrecto de tipos dinámicos',
        'codigo': 'dynamic n = "10";\nprint(n + 5); // Runtime error'
      },
      {
        'titulo': 'Tipado fuerte para evitar errores',
        'codigo': 'int n = 10;\nprint(n + 5);'
      },
    ],

    'Clean Code & Naming': [
      {
        'titulo': 'Mal Naming (mala práctica)',
        'codigo': 'void p(x){print(x*0.21);} // ¿Qué hace esta función?'
      },
      {
        'titulo': 'Buen Naming (Clean Code)',
        'codigo': 'void printTax(double subtotal) {\n  print(subtotal * 0.21);\n}'
      },
      {
        'titulo': 'Naming confuso',
        'codigo': 'bool f(String s){ return s.length > 5; } // ¿Qué evalúa?'
      },
      {
        'titulo': 'Naming claro y expresivo',
        'codigo': 'bool isValidUsername(String username){\n  return username.length > 5;\n}'
      },
      {
        'titulo': 'Nombre no expresivo',
        'codigo': 'void calc(u){ print(u * 9 / 5 + 32); } // ¿Convierte qué?'
      },
      {
        'titulo': 'Nombre claro y semántico',
        'codigo': 'void convertirCelsiusAFahrenheit(double celsius){\n  print(celsius * 9/5 + 32);\n}'
      },
    ],

    'Principios SOLID': [
      {
        'titulo': 'Mala práctica: SRP violado',
        'codigo':
        'class UserService {\n  void saveUser(){}\n  void sendEmail(){}\n  void exportPDF(){}\n}'
      },
      {
        'titulo': 'Buena práctica: Aplicando SRP',
        'codigo':
        'class UserRepository{}\nclass EmailService{}\nclass PdfExporter{}'
      },
      {
        'titulo': 'Violación de OCP (mala práctica)',
        'codigo':
        'class Payment {\n  void pay(String type){\n    if(type == "paypal"){}\n    if(type == "card"){}\n  }\n}'
      },
      {
        'titulo': 'Aplicación de OCP con polimorfismo',
        'codigo':
        'abstract class PaymentMethod{\n  void pay();\n}\nclass PayPal implements PaymentMethod{\n  void pay(){}\n}\nclass Card implements PaymentMethod{\n  void pay(){}\n}'
      },
      {
        'titulo': 'Violación de LSP',
        'codigo':
        'class Bird { void fly(){} }\nclass Penguin extends Bird { @override void fly(){} } // No debería'
      },
      {
        'titulo': 'Cumpliendo LSP',
        'codigo':
        'abstract class Bird{}\nclass FlyingBird extends Bird{ void fly(){} }\nclass Penguin extends Bird{}'
      },
    ],

    'Manejo de errores': [
      {
        'titulo': 'Mal manejo de errores',
        'codigo': 'int dividir(a,b){return a/b;} // Si b=0 explota'
      },
      {
        'titulo': 'Buen manejo con validación',
        'codigo':
        'int dividir(int a,int b){\n  if(b==0) throw Exception("División inválida");\n  return a ~/ b;\n}'
      },
      {
        'titulo': 'Ignorar excepciones (mala práctica)',
        'codigo':
        'try {\n  process();\n} catch (e) {\n  // vacío 😬\n}'
      },
      {
        'titulo': 'Captura de excepciones con logging',
        'codigo':
        'try {\n  process();\n} catch (e) {\n  print("Error en process(): $e");\n}'
      },
      {
        'titulo': 'Error sin contexto',
        'codigo':
        'throw Exception("Falló"); // No aporta información'
      },
      {
        'titulo': 'Error contextualizado',
        'codigo':
        'throw Exception("Error al cargar usuario: ID inválido");'
      },
    ],

    'DRY y Reutilización': [
      {
        'titulo': 'Código duplicado (rompe DRY)',
        'codigo': 'print("Hola Juan");\nprint("Hola Pedro");'
      },
      {
        'titulo': 'Aplicando DRY con función reutilizable',
        'codigo':
        'void saludar(String nombre){\n  print("Hola ?nombre");\n}\n\nsaludar("Juan");\nsaludar("Pedro");'
      },
      {
        'titulo': 'Lógica repetida',
        'codigo':
        'double total1 = price + (price * 0.18);\ndouble total2 = cost + (cost * 0.18);'
      },
      {
        'titulo': 'Uso de función reutilizable',
        'codigo':
        'double aplicarImpuesto(double valor){\n  return valor * 1.18;\n}\n\nfinal total1 = aplicarImpuesto(price);\nfinal total2 = aplicarImpuesto(cost);'
      },
      {
        'titulo': 'Condiciones repetidas',
        'codigo':
        'if(user == null) return;\n...\nif(user == null) return;'
      },
      {
        'titulo': 'Extracción en función reusable',
        'codigo':
        'bool isNull(o) => o == null;\n\nif(isNull(user)) return;'
      },
    ],

    'Asincronía': [
      {
        'titulo': 'Mal código asincrónico',
        'codigo':
        'Future cargar(){sleep(5); return Future.value(1);} // Bloquea el hilo'
      },
      {
        'titulo': 'Buen uso async/await',
        'codigo':
        'Future cargar() async {\n  await Future.delayed(Duration(seconds: 5));\n  return 1;\n}'
      },
      {
        'titulo': 'Uso incorrecto de Future',
        'codigo':
        'Future<int> load(){ return 5; } // No retorna Future válido'
      },
      {
        'titulo': 'Retorno correcto de Future',
        'codigo':
        'Future<int> load() async {\n  return 5;\n}'
      },
      {
        'titulo': 'Callback hell (mala práctica)',
        'codigo':
        'loadA().then((a){\n  loadB(a).then((b){\n    loadC(b).then((c){\n      print(c);\n    });\n  });\n});'
      },
      {
        'titulo': 'Uso correcto de async/await',
        'codigo':
        'final a = await loadA();\nfinal b = await loadB(a);\nfinal c = await loadC(b);\nprint(c);'
      },
    ],

    'Testing': [
      {
        'titulo': 'Mal test (sin objetivo)',
        'codigo': 'test("algo", (){}); // No valida nada'
      },
      {
        'titulo': 'Buen test unitario',
        'codigo': 'test("Suma correcta",(){\n  expect(suma(2,3),5);\n});'
      },
      {
        'titulo': 'Test dependiente del orden (mala práctica)',
        'codigo':
        'test("A", (){ counter++; });\ntest("B", (){ expect(counter, 1); });'
      },
      {
        'titulo': 'Test aislado e independiente',
        'codigo':
        'setUp(() => counter = 0);\n\ntest("Incrementa correctamente", (){\n  counter++;\n  expect(counter, 1);\n});'
      },
      {
        'titulo': 'Test lento (mala práctica)',
        'codigo':
        'test("prueba lenta", () async {\n  await Future.delayed(Duration(seconds: 5));\n});'
      },
      {
        'titulo': 'Test rápido y aislado',
        'codigo':
        'test("procesa valores", (){\n  final r = procesar(2);\n  expect(r, 4);\n});'
      },
    ],

    'Arquitectura limpia': [
      {
        'titulo': 'Arquitectura acoplada (mala práctica)',
        'codigo':
        'class UI {\n  void saveUser(){\n    Database().insertUser();\n  }\n}\n\nclass Database {\n  void insertUser(){}\n}'
      },
      {
        'titulo': 'Arquitectura limpia (buena práctica)',
        'codigo':
        'class UserRepository {\n  void save(User user){}\n}\n\nclass SaveUserUseCase {\n  final UserRepository repo;\n  SaveUserUseCase(this.repo);\n  void call(User user){ repo.save(user); }\n}'
      },
      {
        'titulo': 'Vista accediendo a la base de datos',
        'codigo':
        'class ProfilePage{\n  void load(){ Database().getUser(); }\n}'
      },
      {
        'titulo': 'Capa de dominio separada',
        'codigo':
        'class GetUserUseCase{\n  final UserRepository repo;\n  GetUserUseCase(this.repo);\n  User call(){ return repo.getUser(); }\n}'
      },
      {
        'titulo': 'Dependencia directa desde UI',
        'codigo':
        'button.onPressed = () => Api().fetch();'
      },
      {
        'titulo': 'Intermediación mediante capa de casos de uso',
        'codigo':
        'button.onPressed = () => FetchDataUseCase(repo).call();'
      },
    ],

    'CI/CD': [
      {
        'titulo': 'Pipeline incompleto',
        'codigo': '# build.yml\nsteps:\n  - run: echo "Solo compila"'
      },
      {
        'titulo': 'Pipeline CI/CD con pruebas',
        'codigo':
        '# build.yml\nsteps:\n  - run: flutter test\n  - run: flutter build apk\n  - run: echo "Deploy automático si pasa todo"'
      },
      {
        'titulo': 'Pipeline sin validaciones',
        'codigo': '# pipeline.yml\n- run: dart run'
      },
      {
        'titulo': 'Pipeline con análisis y pruebas',
        'codigo':
        '# pipeline.yml\n- run: dart analyze\n- run: dart test\n- run: dart run build_runner build'
      },
      {
        'titulo': 'Sin control de versiones del build',
        'codigo':
        '# deploy.yml\nsteps:\n  - run: flutter build apk'
      },
      {
        'titulo': 'Versión automática en CI',
        'codigo':
        '# deploy.yml\nsteps:\n  - run: dart pub global activate cider\n  - run: cider bump patch\n  - run: flutter build apk'
      },
    ],

    'Seguridad': [
      {
        'titulo': 'Mala práctica: contraseña en texto plano',
        'codigo': 'const apiKey = "12345"; // ❌ Nunca hagas esto'
      },
      {
        'titulo': 'Buena práctica: variable de entorno',
        'codigo':
        'final apiKey = Platform.environment["API_KEY"]; // ✅ Segura'
      },
      {
        'titulo': 'Tokens hardcodeados (mala práctica)',
        'codigo': 'final token = "eyJhbGciOi...";'
      },
      {
        'titulo': 'Uso de Secure Storage',
        'codigo':
        'final storage = FlutterSecureStorage();\nfinal token = await storage.read(key: "token");'
      },
      {
        'titulo': 'Uso de HTTP sin cifrado',
        'codigo': 'final url = "http://api.miapp.com";'
      },
      {
        'titulo': 'Forzar HTTPS',
        'codigo': 'final url = "https://api.miapp.com";'
      },
    ],

    'Patrones de diseño': [
      {
        'titulo': 'Uso incorrecto sin patrón',
        'codigo':
        'var db = Database();\nvar db2 = Database(); // Múltiples instancias innecesarias'
      },
      {
        'titulo': 'Aplicando patrón Singleton',
        'codigo':
        'class Database {\n  static final Database _instance = Database._();\n  Database._();\n  factory Database() => _instance;\n}'
      },
      {
        'titulo': 'Acoplamiento sin patrón Factory',
        'codigo':
        'var service = EmailService(); // Difícil de cambiar'
      },
      {
        'titulo': 'Aplicación del patrón Factory',
        'codigo':
        'class ServiceFactory{\n  static EmailService createEmailService(){\n    return EmailService();\n  }\n}'
      },
      {
        'titulo': 'Dependencia directa (sin Strategy)',
        'codigo':
        'class Auth{\n  void login(){ print("Google login"); }\n}'
      },
      {
        'titulo': 'Aplicando Strategy',
        'codigo':
        'abstract class LoginStrategy{ void login(); }\nclass GoogleLogin implements LoginStrategy{ void login(){} }\nclass Auth{\n  final LoginStrategy strategy;\n  Auth(this.strategy);\n  void login(){ strategy.login(); }\n}'
      },
    ],

    'Refactorización': [
      {
        'titulo': 'Código sin refactorizar',
        'codigo':
        'double calcularPrecio(double p){\n  return p - (p * 0.21);\n}'
      },
      {
        'titulo': 'Código refactorizado con constante y claridad',
        'codigo':
        'const double IVA = 0.21;\n\ndouble calcularPrecio(double precioBase){\n  return precioBase - (precioBase * IVA);\n}'
      },
      {
        'titulo': 'Función larga y difícil de leer',
        'codigo':
        'void calcular(){\n  // 40 líneas de lógica mezclada\n}'
      },
      {
        'titulo': 'Refactor en funciones pequeñas',
        'codigo':
        'void calcular(){\n  final datos = cargarDatos();\n  final validados = validar(datos);\n  procesar(validados);\n}'
      },
      {
        'titulo': 'Condicional compleja',
        'codigo':
        'if(a > 10 && b < 5 && c == true && nombre != ""){}'
      },
      {
        'titulo': 'Extracción a función con intención',
        'codigo':
        'bool esValido() => a > 10 && b < 5 && c && nombre.isNotEmpty;\n\nif(esValido()){}'
      },
    ],

    'Rendimiento': [
      {
        'titulo': 'Ineficiencia en loop',
        'codigo':
        'for (int i=0; i<items.length; i++){\n  print(items.length);\n}'
      },
      {
        'titulo': 'Optimización en loop',
        'codigo':
        'final total = items.length;\nfor (int i=0; i<total; i++){\n  print(total);\n}'
      },
      {
        'titulo': 'Uso innecesario de listas temporales',
        'codigo':
        'var temp = items.map((e) => e.toString()).toList();'
      },
      {
        'titulo': 'Uso eficiente con lazy evaluation',
        'codigo':
        'var iterator = items.map((e) => e.toString()); // No crea lista'
      },
      {
        'titulo': 'Creación de objetos en loop',
        'codigo':
        'for(int i=0;i<1000;i++){\n  final date = DateTime.now();\n}'
      },
      {
        'titulo': 'Reuse fuera del loop',
        'codigo':
        'final date = DateTime.now();\nfor(int i=0;i<1000;i++){\n  use(date);\n}'
      },
    ],

    'Documentación': [
      {
        'titulo': 'Sin documentación',
        'codigo': 'void procesar(){}'
      },
      {
        'titulo': 'Con documentación clara',
        'codigo':
        '/// Procesa los datos de entrada y los normaliza.\nvoid procesar(){}'
      },
      {
        'titulo': 'Comentario inútil',
        'codigo': '// incrementa x\nx++;'
      },
      {
        'titulo': 'Doc útil tipo DartDoc',
        'codigo':
        '/// Calcula el total aplicando impuesto.\n/// [precio] Precio base antes del impuesto.\ndouble total(double precio){ return precio * 1.21; }'
      },
      {
        'titulo': 'Documentación no útil',
        'codigo': '/// Hace cosas\nvoid procesar(){}'
      },
      {
        'titulo': 'Doc específica con parámetros',
        'codigo':
        '/// Calcula el total descontando [descuento].\n/// Retorna el precio final.\ndouble aplicarDescuento(double precio, double descuento){\n  return precio - descuento;\n}'
      },
    ],
    'Casos de uso': [
      {
        'titulo': 'Caso de uso sin separación de responsabilidades (mala práctica)',
        'codigo':
        'class UserController {\n'
            '  void register(String name, String email) {\n'
            '    if (!email.contains("@")) throw Exception("Email inválido");\n'
            '    Database().saveUser(name, email);\n'
            '    EmailService().sendWelcome(email);\n'
            '  }\n'
            '}\n'
            '\n'
            'class Database {\n'
            '  void saveUser(String name, String email){}\n'
            '}\n'
            'class EmailService{\n'
            '  void sendWelcome(String email){}\n'
            '}'
      },
      {
        'titulo': 'Aplicación correcta de caso de uso (Clean Architecture)',
        'codigo':
        '// Capa dominio\n'
            'class RegisterUserUseCase {\n'
            '  final UserRepository repo;\n'
            '  final EmailService emailService;\n'
            '\n'
            '  RegisterUserUseCase(this.repo, this.emailService);\n'
            '\n'
            '  void execute(String name, String email) {\n'
            '    if (!_isValidEmail(email)) {\n'
            '      throw Exception("Email inválido");\n'
            '    }\n'
            '    repo.saveUser(name, email);\n'
            '    emailService.sendWelcome(email);\n'
            '  }\n'
            '\n'
            '  bool _isValidEmail(String email) => email.contains("@");\n'
            '}\n'
            '\n'
            '// Capa infraestructura\n'
            'abstract class UserRepository {\n'
            '  void saveUser(String name, String email);\n'
            '}\n'
            '\n'
            'class UserRepositoryImpl implements UserRepository{\n'
            '  @override\n'
            '  void saveUser(String name, String email){}\n'
            '}\n'
            '\n'
            'class EmailService{\n'
            '  void sendWelcome(String email){}\n'
            '}\n'
            '\n'
            '// Capa UI\n'
            'final useCase = RegisterUserUseCase(UserRepositoryImpl(), EmailService());\n'
            'useCase.execute("Juan", "juan@mail.com");'
      },

      {
        'titulo': 'Caso de uso que mezcla lógica de negocio con UI (mala práctica)',
        'codigo':
        'void cargarProductos() async {\n'
            '  print("Mostrando loader...");\n'
            '  final data = await Api().getProducts();\n'
            '  productos = data.map((e) => Producto.fromJson(e)).toList();\n'
            '  print("Ocultando loader...");\n'
            '}'
      },
      {
        'titulo': 'Caso de uso reutilizable para cargar productos',
        'codigo':
        'class GetProductsUseCase {\n'
            '  final ProductRepository repo;\n'
            '  GetProductsUseCase(this.repo);\n'
            '\n'
            '  Future<List<Producto>> call() async {\n'
            '    final rawData = await repo.getProducts();\n'
            '    return rawData.map((e) => Producto.fromJson(e)).toList();\n'
            '  }\n'
            '}\n'
            '\n'
            '// UI\n'
            'final productos = await GetProductsUseCase(ProductRepositoryImpl())();'
      },

      {
        'titulo': 'Caso de uso mal diseñado (tiene más de una responsabilidad)',
        'codigo':
        'class PurchaseUseCase {\n'
            '  void buy(Product p) {\n'
            '    _validate(p);\n'
            '    _saveToDB(p);\n'
            '    _sendEmail(p);\n'
            '    _log("Compra realizada");\n'
            '  }\n'
            '  void _validate(Product p){}\n'
            '  void _saveToDB(Product p){}\n'
            '  void _sendEmail(Product p){}\n'
            '  void _log(String m){}\n'
            '}'
      },
      {
        'titulo': 'Caso de uso bien diseñado: una sola responsabilidad',
        'codigo':
        'class PurchaseUseCase {\n'
            '  final PurchaseRepository repo;\n'
            '  final NotificationService notifier;\n'
            '\n'
            '  PurchaseUseCase(this.repo, this.notifier);\n'
            '\n'
            '  void execute(Product p) {\n'
            '    if (!_valid(p)) throw Exception("Producto inválido");\n'
            '    repo.save(p);\n'
            '    notifier.sendPurchaseConfirmation(p);\n'
            '  }\n'
            '\n'
            '  bool _valid(Product p) => p.stock > 0;\n'
            '}\n'
            '\n'
            'abstract class PurchaseRepository { void save(Product p); }\n'
            'abstract class NotificationService { void sendPurchaseConfirmation(Product p); }'
      },
    ],

    'Casos de uso (UML)': [
      {
        'titulo': 'Diagrama UML: Registro de usuario',
        'codigo':
        'El actor "Usuario" interactúa con el sistema para registrarse.\n'
            '- Actor: Usuario\n'
            '- Caso de uso principal: Registrar Usuario\n'
            '- Casos incluidos: Validar Email, Guardar Datos\n'
            '- Flujo: El usuario ingresa sus datos → El sistema valida → Se registra el usuario.'
      },
      {
        'titulo': 'Diagrama UML: Iniciar sesión',
        'codigo':
        'Representa cómo un usuario accede a su cuenta.\n'
            '- Actor: Usuario\n'
            '- Caso de uso: Iniciar Sesión\n'
            '- Extiende: Recuperar Contraseña\n'
            '- Flujo: Usuario ingresa credenciales → Sistema verifica → Acceso concedido.'
      },
      {
        'titulo': 'Diagrama UML: Procesar Compra',
        'codigo':
        'El actor realiza un proceso de compra en un sistema.\n'
            '- Actor: Cliente\n'
            '- Caso de uso principal: Comprar Producto\n'
            '- Casos incluidos: Validar Stock, Calcular Total, Procesar Pago\n'
            '- Actores secundarios: Pasarela de Pago.'
      },
      {
        'titulo': 'Diagrama UML: Gestión de productos',
        'codigo':
        'Caso de uso para administración del catálogo.\n'
            '- Actor: Administrador\n'
            '- Casos de uso: Crear Producto, Editar Producto, Eliminar Producto\n'
            '- Extiende: Registrar Cambios (para auditoría).'
      },
      {
        'titulo': 'Diagrama UML: Generar Reporte',
        'codigo':
        'Diagrama que muestra la generación de reportes por parte del sistema.\n'
            '- Actor: Analista\n'
            '- Caso de uso principal: Generar Reporte\n'
            '- Incluye: Obtener Datos, Procesar Información, Exportar Archivo.'
      },
      {
        'titulo': 'Diagrama UML: Notificaciones automáticas',
        'codigo':
        'Representa envíos automáticos de mensajes.\n'
            '- Actor: Sistema (actor secundario), Usuario\n'
            '- Caso de uso: Enviar Notificación\n'
            '- Incluye: Consultar Preferencias del Usuario.\n'
            '- Extiende: Enviar Email, Enviar Push.'
      },
    ],
    'Buenas prácticas': [
      {
        'titulo': 'Responsabilidad Única',
        'codigo':
        'Cada clase, función o módulo debe tener solo una responsabilidad clara.\n'
            'Esto facilita las pruebas, el mantenimiento y reduce el acoplamiento.'
      },
      {
        'titulo': 'Nombres claros y significativos',
        'codigo':
        'Usar nombres que expliquen la intención. Un buen nombre evita comentarios innecesarios.\n'
            'Debe ser fácil entender qué hace algo sin buscar en otros archivos.'
      },
      {
        'titulo': 'Evitar duplicación (principio DRY)',
        'codigo':
        'Nunca repitas lógica o datos en varias partes del sistema.\n'
            'Extrae funciones o componentes reutilizables para centralizar el comportamiento.'
      },
      {
        'titulo': 'Preferir composición sobre herencia',
        'codigo':
        'La composición reduce el acoplamiento y permite modificar comportamientos\n'
            'sin afectar jerarquías enteras. La herencia debe ser el último recurso.'
      },
      {
        'titulo': 'Validar datos y manejar errores',
        'codigo':
        'Toda entrada externa debe validarse antes de procesarse.\n'
            'Un buen manejo de errores mejora la estabilidad del sistema y la experiencia del usuario.'
      },
      {
        'titulo': 'Escribir código legible antes que código “inteligente”',
        'codigo':
        'El código debe ser fácil de entender por otros desarrolladores.\n'
            'Evita trucos o construcciones demasiado sofisticadas que dificulten la lectura.'
      },
      {
        'titulo': 'Documentar solo lo necesario',
        'codigo':
        'Los comentarios deben explicar el “por qué”, no el “cómo”.\n'
            'Un exceso de documentación es tan malo como la ausencia de la misma.'
      },
      {
        'titulo': 'Mantener funciones cortas',
        'codigo':
        'Una función debe hacer una sola cosa y hacerla bien.\n'
            'Idealmente, no debería superar 20 líneas para facilitar pruebas y lectura.'
      },
      {
        'titulo': 'Evitar acoplamiento entre capas',
        'codigo':
        'Las capas de UI, dominio y datos deben estar bien separadas.\n'
            'El acoplamiento provoca errores en cascada y hace difícil reemplazar implementaciones.'
      },
      {
        'titulo': 'Escribir pruebas automatizadas',
        'codigo':
        'Las pruebas permiten detectar errores rápidamente y asegurar que el sistema\n'
            'se comporta como se espera incluso después de refactorizaciones.'
      },
    ],
    'Malas prácticas': [
      {
        'titulo': 'Clases con demasiadas responsabilidades',
        'codigo':
        'Una clase que hace muchas cosas es difícil de mantener, probar y extender.\n'
            'Este problema suele generar errores ocultos y obliga a modificar muchas partes del sistema\n'
            'cuando se requiere un cambio.'
      },
      {
        'titulo': 'Nombres ambiguos o poco descriptivos',
        'codigo':
        'Usar nombres como data, temp, obj o manager hace que sea difícil entender la intención del código.\n'
            'Esto aumenta el tiempo de lectura y reduce la claridad general del proyecto.'
      },
      {
        'titulo': 'Ignorar el manejo de errores',
        'codigo':
        'No validar los datos de entrada o no manejar situaciones inesperadas provoca fallos en producción.\n'
            'También dificulta la depuración y puede causar un mal funcionamiento silencioso.'
      },
      {
        'titulo': 'Duplicación de lógica',
        'codigo':
        'Tener la misma lógica en varios lugares aumenta la probabilidad de inconsistencias.\n'
            'Modificar un comportamiento obliga a buscar y actualizar múltiples ubicaciones.'
      },
      {
        'titulo': 'Funciones demasiado largas',
        'codigo':
        'Las funciones que hacen muchas cosas resultan difíciles de entender y probar.\n'
            'Además, tienen mayor probabilidad de contener errores y efectos secundarios ocultos.'
      },
      {
        'titulo': 'Dependencias innecesarias entre capas',
        'codigo':
        'Permitir que la UI llame directamente a la base de datos rompe la arquitectura.\n'
            'Esto hace el sistema rígido y difícil de escalar o modificar.'
      },
      {
        'titulo': 'Comentar en exceso o comentar cosas obvias',
        'codigo':
        'Los comentarios que explican lo evidente generan ruido visual y no aportan valor.\n'
            'La sobre-documentación también se vuelve desactualizada rápidamente.'
      },
      {
        'titulo': 'Usar variables globales sin necesidad',
        'codigo':
        'Las variables globales complican el control de estado y pueden generar efectos secundarios inesperados.\n'
            'Además, afectan la capacidad de realizar pruebas unitarias.'
      },
      {
        'titulo': 'Optimizar prematuramente',
        'codigo':
        'Intentar optimizar antes de entender el problema genera complejidad innecesaria.\n'
            'La optimización debe hacerse solo cuando hay evidencia real de problemas de rendimiento.'
      },
      {
        'titulo': 'Falta de pruebas automatizadas',
        'codigo':
        'Confiar únicamente en pruebas manuales es riesgoso.\n'
            'Esto incrementa la posibilidad de introducir errores al cambiar o refactorizar.'
      },
    ]

  };

  @override
  Widget build(BuildContext context) {
    final tabs = categorizedExamples.keys.toList();

    return DefaultTabController(
      length: tabs.length + 1, // +1 para incluir la pestaña de diagramas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ejemplos de buenas prácticas'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'Diagramas de flujo'),
              ...tabs.map((t) => Tab(text: t)),
            ],
          ),
        ),

        //  Campo de búsqueda persistente arriba de las pestañas
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Buscar ejemplo...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  //  Pestaña de diagramas
                  ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      ListTile(
                        title: const Text('Diagrama de flujo (ejemplo)'),
                        subtitle: const Text('Visualiza un diagrama fijo ya armado.'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UmlExample()),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Editor de diagramas de UML'),
                        subtitle: const Text('Crea y diseña tus propios diagramas.'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UmlEditor()),
                          );
                        },
                      ),
                    ],
                  ),

                  //  Resto de pestañas con filtro activo
                  ...tabs.map((category) {
                    final ejemplos = categorizedExamples[category]!
                        .where((e) =>
                    e['titulo']!.toLowerCase().contains(searchQuery) ||
                        e['codigo']!.toLowerCase().contains(searchQuery))
                        .toList();

                    if (ejemplos.isEmpty) {
                      return const Center(child: Text('Sin resultados.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: ejemplos.length,
                      itemBuilder: (context, index) {
                        final example = ejemplos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  example['titulo']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SelectableText(
                                  example['codigo']!,
                                  style: const TextStyle(fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int unlockedLevel = 0;
  int quizAttempts = 0;

  final QuizDAO quizDAO = QuizDAO();

  final Map<String, List<Map<String, Object>>> quizzes = {
    // NIVELES EXISTENTES
    'Nivel 1 – SOLID (SRP)': [
      {
        'pregunta': '¿Qué significa el principio "S" en SOLID?',
        'opciones': ['Single Responsibility', 'Secure Programming', 'Simple Refactoring'],
        'respuesta': 'Single Responsibility'
      },
      {
        'pregunta': '¿Qué busca el SRP?',
        'opciones': [
          'Que cada clase tenga una sola responsabilidad',
          'Que la clase tenga muchas funciones',
          'Que el código sea más largo'
        ],
        'respuesta': 'Que cada clase tenga una sola responsabilidad'
      },
      {
        'pregunta': '¿Qué ocurre si una clase tiene varias responsabilidades?',
        'opciones': [
          'Se vuelve difícil de mantener',
          'Se entiende mejor',
          'Es más eficiente'
        ],
        'respuesta': 'Se vuelve difícil de mantener'
      },
      {
        'pregunta': 'Según SRP, una clase debe tener:',
        'opciones': [
          'Una sola razón para cambiar',
          'Tantas como sea posible',
          'Responsabilidades múltiples'
        ],
        'respuesta': 'Una sola razón para cambiar'
      },
    ],

    'Nivel 2 – Git básico': [
      {
        'pregunta': '¿Qué es una buena práctica con Git?',
        'opciones': ['Usar ramas', 'Subir directo a main', 'No documentar'],
        'respuesta': 'Usar ramas'
      },
      {
        'pregunta': '¿Qué comando crea una nueva rama?',
        'opciones': ['git branch nombre', 'git push', 'git merge'],
        'respuesta': 'git branch nombre'
      },
      {
        'pregunta': '¿Qué comando se usa para combinar ramas?',
        'opciones': ['git merge', 'git commit', 'git init'],
        'respuesta': 'git merge'
      },
      {
        'pregunta': '¿Para qué sirve `git pull`?',
        'opciones': [
          'Traer cambios del repositorio remoto',
          'Eliminar una rama',
          'Crear un repositorio nuevo'
        ],
        'respuesta': 'Traer cambios del repositorio remoto'
      },
    ],

    'Nivel 3 – Clean Code': [
      {
        'pregunta': 'Un buen código debe ser:',
        'opciones': ['Legible', 'Confuso', 'Extenso'],
        'respuesta': 'Legible'
      },
      {
        'pregunta': 'Las variables deben tener nombres:',
        'opciones': ['Descriptivos', 'De una sola letra', 'Al azar'],
        'respuesta': 'Descriptivos'
      },
      {
        'pregunta': '¿Qué se recomienda evitar?',
        'opciones': ['Duplicar código', 'Nombrar bien', 'Comentar lo necesario'],
        'respuesta': 'Duplicar código'
      },
    ],

    'Nivel 4 – TDD': [
      {
        'pregunta': '¿Qué significa TDD?',
        'opciones': [
          'Test Driven Development',
          'Technical Design Document',
          'Task Driven Data'
        ],
        'respuesta': 'Test Driven Development'
      },
      {
        'pregunta': 'El ciclo TDD es:',
        'opciones': ['Red - Green - Refactor', 'Run - Watch - Repeat', 'Test - Deploy - Deliver'],
        'respuesta': 'Red - Green - Refactor'
      },
    ],

    'Nivel 5 – Patrones de diseño': [
      {
        'pregunta': '¿Qué patrón promueve la comunicación entre objetos?',
        'opciones': ['Observer', 'Singleton', 'Adapter'],
        'respuesta': 'Observer'
      },
      {
        'pregunta': '¿Cuál patrón asegura solo una instancia?',
        'opciones': ['Singleton', 'Factory', 'Builder'],
        'respuesta': 'Singleton'
      },
    ],

    //  PLANIFICACIÓN
    'Nivel 6 – Planificación y gestión': [
      {
        'pregunta': '¿Por qué es importante definir requisitos antes de desarrollar?',
        'opciones': [
          'Para evitar retrabajo y malentendidos',
          'Para escribir más código',
          'Para ahorrar tiempo de pruebas'
        ],
        'respuesta': 'Para evitar retrabajo y malentendidos'
      },
      {
        'pregunta': '¿Qué herramienta ayuda a planificar tareas en equipo?',
        'opciones': ['Trello', 'Photoshop', 'Notepad'],
        'respuesta': 'Trello'
      },
      {
        'pregunta': '¿Qué es un hito en un proyecto?',
        'opciones': [
          'Un punto clave o logro dentro del cronograma',
          'Un error en el código',
          'Una tarea opcional'
        ],
        'respuesta': 'Un punto clave o logro dentro del cronograma'
      },
      {
        'pregunta': '¿Qué se logra al gestionar riesgos correctamente?',
        'opciones': [
          'Reducir el impacto de imprevistos',
          'Evitar tener requisitos',
          'Aumentar la complejidad'
        ],
        'respuesta': 'Reducir el impacto de imprevistos'
      },
    ],

    //  DISEÑO
    'Nivel 7 – Diseño y arquitectura': [
      {
        'pregunta': '¿Qué caracteriza a una arquitectura modular?',
        'opciones': [
          'Divide el sistema en partes independientes y reutilizables',
          'Usa una sola clase para todo',
          'Evita la separación de responsabilidades'
        ],
        'respuesta': 'Divide el sistema en partes independientes y reutilizables'
      },
      {
        'pregunta': '¿Qué patrón se usa para separar interfaz y lógica?',
        'opciones': ['MVC', 'Singleton', 'Decorator'],
        'respuesta': 'MVC'
      },
      {
        'pregunta': '¿Qué beneficio tiene un buen diseño de interfaz de usuario?',
        'opciones': [
          'Mejora la experiencia del usuario',
          'Hace el sistema más complejo',
          'Reduce la legibilidad del código'
        ],
        'respuesta': 'Mejora la experiencia del usuario'
      },
      {
        'pregunta': '¿Por qué considerar la seguridad desde el diseño?',
        'opciones': [
          'Evita vulnerabilidades futuras',
          'Para aumentar el tamaño del sistema',
          'Para hacerlo más lento'
        ],
        'respuesta': 'Evita vulnerabilidades futuras'
      },
    ],

    //  CODIFICACIÓN
    'Nivel 8 – Buenas prácticas de código': [
      {
        'pregunta': '¿Qué busca el principio DRY?',
        'opciones': [
          'Evitar repetir código innecesariamente',
          'Duplicar funcionalidades',
          'Reducir la legibilidad'
        ],
        'respuesta': 'Evitar repetir código innecesariamente'
      },
      {
        'pregunta': '¿Qué significa KISS?',
        'opciones': [
          'Keep It Simple, Stupid',
          'Keep It Super Short',
          'Key In Simple Syntax'
        ],
        'respuesta': 'Keep It Simple, Stupid'
      },
      {
        'pregunta': '¿Qué es una revisión de código (code review)?',
        'opciones': [
          'Evaluar código entre compañeros para mejorar calidad',
          'Borrar el código antiguo',
          'Ejecutar pruebas automáticas'
        ],
        'respuesta': 'Evaluar código entre compañeros para mejorar calidad'
      },
      {
        'pregunta': '¿Qué herramienta se usa para integración continua?',
        'opciones': ['GitHub Actions', 'Paint', 'Excel'],
        'respuesta': 'GitHub Actions'
      },
    ],

    //  PRUEBAS
    'Nivel 9 – Pruebas y QA': [
      {
        'pregunta': '¿Qué son las pruebas unitarias?',
        'opciones': [
          'Verifican el funcionamiento de componentes individuales',
          'Evalúan el diseño visual',
          'Simulan todo el sistema'
        ],
        'respuesta': 'Verifican el funcionamiento de componentes individuales'
      },
      {
        'pregunta': '¿Qué mide una prueba de rendimiento?',
        'opciones': [
          'La velocidad y capacidad del sistema',
          'El diseño de la interfaz',
          'La cantidad de usuarios registrados'
        ],
        'respuesta': 'La velocidad y capacidad del sistema'
      },
      {
        'pregunta': '¿Qué se busca con las pruebas de seguridad?',
        'opciones': [
          'Detectar vulnerabilidades',
          'Optimizar gráficos',
          'Reducir comentarios en el código'
        ],
        'respuesta': 'Detectar vulnerabilidades'
      },
      {
        'pregunta': '¿Qué ventaja tiene automatizar las pruebas?',
        'opciones': [
          'Ahorra tiempo y reduce errores humanos',
          'Hace las pruebas más lentas',
          'Evita la documentación'
        ],
        'respuesta': 'Ahorra tiempo y reduce errores humanos'
      },
    ],

    //  MEJORA CONTINUA
    'Nivel 10 – Mejora continua y equipo': [
      {
        'pregunta': '¿Qué se busca en una retrospectiva de equipo?',
        'opciones': [
          'Analizar lo que funcionó y mejorar lo que no',
          'Asignar castigos',
          'Ignorar errores pasados'
        ],
        'respuesta': 'Analizar lo que funcionó y mejorar lo que no'
      },
      {
        'pregunta': '¿Qué son los KPIs?',
        'opciones': [
          'Indicadores clave de rendimiento',
          'Errores del sistema',
          'Tipos de patrones de diseño'
        ],
        'respuesta': 'Indicadores clave de rendimiento'
      },
      {
        'pregunta': '¿Qué promueve la cultura DevOps?',
        'opciones': [
          'Colaboración entre desarrollo y operaciones',
          'Separación estricta de equipos',
          'Menos comunicación'
        ],
        'respuesta': 'Colaboración entre desarrollo y operaciones'
      },
      {
        'pregunta': '¿Por qué es importante mantenerse actualizado?',
        'opciones': [
          'Para adaptarse a nuevas tecnologías y buenas prácticas',
          'Para complicar los procesos',
          'Para evitar aprender cosas nuevas'
        ],
        'respuesta': 'Para adaptarse a nuevas tecnologías y buenas prácticas'
      },
    ],
    // ️ CONTROL DE VERSIONES AVANZADO
    'Nivel 11 – Git avanzado': [
      {
        'pregunta': '¿Qué comando se usa para combinar commits en uno solo?',
        'opciones': ['git rebase -i', 'git push', 'git log'],
        'respuesta': 'git rebase -i'
      },
      {
        'pregunta': '¿Qué hace `git stash`?',
        'opciones': [
          'Guarda temporalmente cambios sin confirmar',
          'Elimina commits antiguos',
          'Fusiona ramas automáticamente'
        ],
        'respuesta': 'Guarda temporalmente cambios sin confirmar'
      },
      {
        'pregunta': '¿Para qué sirve un pull request?',
        'opciones': [
          'Revisar y fusionar cambios de una rama a otra',
          'Borrar ramas remotas',
          'Cambiar el autor de un commit'
        ],
        'respuesta': 'Revisar y fusionar cambios de una rama a otra'
      },
      {
        'pregunta': '¿Qué comando deshace el último commit sin perder cambios?',
        'opciones': ['git reset --soft HEAD~1', 'git revert', 'git rm'],
        'respuesta': 'git reset --soft HEAD~1'
      },
    ],

//  PRINCIPIOS CLEAN ARCHITECTURE
    'Nivel 12 – Clean Architecture': [
      {
        'pregunta': '¿Qué busca la arquitectura limpia?',
        'opciones': [
          'Separar responsabilidades por capas',
          'Combinar todo en una clase',
          'Depender directamente de la UI'
        ],
        'respuesta': 'Separar responsabilidades por capas'
      },
      {
        'pregunta': '¿Cuál capa debe depender de las demás en Clean Architecture?',
        'opciones': ['Ninguna, las dependencias van hacia el dominio', 'Infraestructura', 'Presentación'],
        'respuesta': 'Ninguna, las dependencias van hacia el dominio'
      },
      {
        'pregunta': '¿Qué representa el dominio?',
        'opciones': [
          'Las reglas de negocio puras',
          'La base de datos',
          'El framework'
        ],
        'respuesta': 'Las reglas de negocio puras'
      },
      {
        'pregunta': '¿Qué capa maneja la lógica de interfaz?',
        'opciones': ['Presentación', 'Dominio', 'Infraestructura'],
        'respuesta': 'Presentación'
      },
    ],

//  REFACTORIZACIÓN
    'Nivel 13 – Refactorización': [
      {
        'pregunta': '¿Qué significa refactorizar?',
        'opciones': [
          'Mejorar el código sin cambiar su comportamiento',
          'Añadir nuevas funciones',
          'Eliminar pruebas'
        ],
        'respuesta': 'Mejorar el código sin cambiar su comportamiento'
      },
      {
        'pregunta': '¿Por qué refactorizar periódicamente?',
        'opciones': [
          'Para mantener el código limpio y entendible',
          'Para romper compatibilidad',
          'Para aumentar la complejidad'
        ],
        'respuesta': 'Para mantener el código limpio y entendible'
      },
      {
        'pregunta': '¿Qué ayuda a detectar zonas que deben refactorizarse?',
        'opciones': ['Code smells', 'Tests exitosos', 'Commits pequeños'],
        'respuesta': 'Code smells'
      },
      {
        'pregunta': '¿Qué patrón ayuda a reducir código duplicado?',
        'opciones': ['Template Method', 'Singleton', 'Observer'],
        'respuesta': 'Template Method'
      },
    ],

//  CI/CD AVANZADO
    'Nivel 14 – Integración y despliegue continuo': [
      {
        'pregunta': '¿Qué significa CI/CD?',
        'opciones': [
          'Integración Continua / Despliegue Continuo',
          'Código Interno / Control de Dependencias',
          'Control Interno / Código Distribuido'
        ],
        'respuesta': 'Integración Continua / Despliegue Continuo'
      },
      {
        'pregunta': '¿Qué ventaja tiene automatizar los pipelines?',
        'opciones': [
          'Evita errores humanos y acelera entregas',
          'Hace más lento el proceso',
          'Impide los tests automáticos'
        ],
        'respuesta': 'Evita errores humanos y acelera entregas'
      },
      {
        'pregunta': '¿Qué herramienta puede ejecutar pipelines?',
        'opciones': ['Jenkins', 'Word', 'Photoshop'],
        'respuesta': 'Jenkins'
      },
      {
        'pregunta': '¿Qué significa “build fallido”?',
        'opciones': [
          'Que una prueba o paso del pipeline falló',
          'Que el código es perfecto',
          'Que el sistema terminó correctamente'
        ],
        'respuesta': 'Que una prueba o paso del pipeline falló'
      },
    ],

//  SEGURIDAD EN EL CÓDIGO
    'Nivel 15 – Seguridad y buenas prácticas': [
      {
        'pregunta': '¿Qué práctica ayuda a proteger contraseñas?',
        'opciones': ['Encriptarlas', 'Guardarlas en texto plano', 'Compartirlas en repositorio'],
        'respuesta': 'Encriptarlas'
      },
      {
        'pregunta': '¿Qué es OWASP?',
        'opciones': [
          'Una organización que promueve seguridad en software',
          'Un tipo de base de datos',
          'Un lenguaje de programación'
        ],
        'respuesta': 'Una organización que promueve seguridad en software'
      },
      {
        'pregunta': '¿Qué es una inyección SQL?',
        'opciones': [
          'Un ataque que manipula consultas a la base de datos',
          'Un error de compilación',
          'Una técnica de test'
        ],
        'respuesta': 'Un ataque que manipula consultas a la base de datos'
      },
      {
        'pregunta': '¿Qué ayuda a evitar XSS?',
        'opciones': ['Escapar el contenido HTML', 'Usar nombres largos', 'Desactivar HTTPS'],
        'respuesta': 'Escapar el contenido HTML'
      },
    ],

//  RENDIMIENTO
    'Nivel 16 – Optimización y rendimiento': [
      {
        'pregunta': '¿Qué se busca al optimizar código?',
        'opciones': [
          'Reducir el consumo de recursos y mejorar la velocidad',
          'Aumentar la complejidad',
          'Duplicar datos'
        ],
        'respuesta': 'Reducir el consumo de recursos y mejorar la velocidad'
      },
      {
        'pregunta': '¿Qué técnica ayuda a mejorar rendimiento?',
        'opciones': ['Caching', 'Duplicación', 'Polling constante'],
        'respuesta': 'Caching'
      },
      {
        'pregunta': '¿Qué herramienta mide rendimiento de código?',
        'opciones': ['Profiler', 'Debugger', 'Console.log'],
        'respuesta': 'Profiler'
      },
      {
        'pregunta': '¿Por qué evitar loops innecesarios?',
        'opciones': [
          'Porque degradan el rendimiento',
          'Porque son visualmente feos',
          'Porque no compilan'
        ],
        'respuesta': 'Porque degradan el rendimiento'
      },
    ],

//  DOCUMENTACIÓN
    'Nivel 17 – Documentación y mantenimiento': [
      {
        'pregunta': '¿Qué objetivo tiene documentar el código?',
        'opciones': [
          'Facilitar comprensión y mantenimiento',
          'Hacerlo más largo',
          'Evitar comentarios útiles'
        ],
        'respuesta': 'Facilitar comprensión y mantenimiento'
      },
      {
        'pregunta': '¿Qué herramienta se usa para documentar APIs?',
        'opciones': ['Swagger', 'Paint', 'Excel'],
        'respuesta': 'Swagger'
      },
      {
        'pregunta': '¿Qué tipo de comentario describe el propósito de una función?',
        'opciones': ['Comentario de documentación', 'Comentario temporal', 'TODO'],
        'respuesta': 'Comentario de documentación'
      },
      {
        'pregunta': '¿Qué mejora un README bien estructurado?',
        'opciones': [
          'La comprensión del proyecto',
          'El tiempo de compilación',
          'La seguridad'
        ],
        'respuesta': 'La comprensión del proyecto'
      },
    ],

//  AGILE Y SCRUM
    'Nivel 18 – Metodologías ágiles': [
      {
        'pregunta': '¿Qué busca Agile?',
        'opciones': [
          'Entregas rápidas y adaptables al cambio',
          'Documentación excesiva',
          'Planificación rígida'
        ],
        'respuesta': 'Entregas rápidas y adaptables al cambio'
      },
      {
        'pregunta': '¿Qué rol lidera al equipo Scrum?',
        'opciones': ['Scrum Master', 'CEO', 'Product Owner'],
        'respuesta': 'Scrum Master'
      },
      {
        'pregunta': '¿Qué es un sprint?',
        'opciones': [
          'Un ciclo corto de desarrollo con metas específicas',
          'Un bug crítico',
          'Un branch de Git'
        ],
        'respuesta': 'Un ciclo corto de desarrollo con metas específicas'
      },
      {
        'pregunta': '¿Qué valor promueve Agile?',
        'opciones': [
          'Colaboración sobre procesos rígidos',
          'Documentación sobre resultados',
          'Jerarquía sobre trabajo en equipo'
        ],
        'respuesta': 'Colaboración sobre procesos rígidos'
      },
    ],

//  DEVOPS
    'Nivel 19 – DevOps y automatización': [
      {
        'pregunta': '¿Qué une DevOps?',
        'opciones': ['Desarrollo y operaciones', 'Diseño y marketing', 'QA y soporte'],
        'respuesta': 'Desarrollo y operaciones'
      },
      {
        'pregunta': '¿Qué práctica fomenta DevOps?',
        'opciones': [
          'Integración continua y entrega continua',
          'Desconexión de equipos',
          'Actualizaciones manuales'
        ],
        'respuesta': 'Integración continua y entrega continua'
      },
      {
        'pregunta': '¿Qué herramienta puede usarse en DevOps?',
        'opciones': ['Docker', 'Word', 'Illustrator'],
        'respuesta': 'Docker'
      },
      {
        'pregunta': '¿Cuál es un beneficio de DevOps?',
        'opciones': [
          'Entrega más rápida de valor al cliente',
          'Procesos más lentos',
          'Menos comunicación'
        ],
        'respuesta': 'Entrega más rápida de valor al cliente'
      },
    ],

//  MANTENIBILIDAD Y ESCALABILIDAD
    'Nivel 20 – Escalabilidad y mantenimiento': [
      {
        'pregunta': '¿Qué es un sistema escalable?',
        'opciones': [
          'Aquel que soporta más carga sin degradarse',
          'Uno que depende de una sola máquina',
          'Uno que no puede crecer'
        ],
        'respuesta': 'Aquel que soporta más carga sin degradarse'
      },
      {
        'pregunta': '¿Qué ayuda a la escalabilidad horizontal?',
        'opciones': ['Agregar más servidores', 'Reducir memoria', 'Eliminar logs'],
        'respuesta': 'Agregar más servidores'
      },
      {
        'pregunta': '¿Qué mejora la mantenibilidad del código?',
        'opciones': [
          'Diseño modular y buenas prácticas',
          'Duplicar funciones',
          'Ocultar lógica en métodos largos'
        ],
        'respuesta': 'Diseño modular y buenas prácticas'
      },
      {
        'pregunta': '¿Qué técnica ayuda a detectar cuellos de botella?',
        'opciones': ['Monitorización', 'Refactorización aleatoria', 'Logging excesivo'],
        'respuesta': 'Monitorización'
      },
    ],

    'Nivel 21 – SOLID (OCP)': [
      {
        'pregunta': '¿Qué establece el principio OCP?',
        'opciones': [
          'Las clases deben estar abiertas a extensión y cerradas a modificación',
          'Las clases deben reescribirse cada vez',
          'Las clases deben tener múltiples responsabilidades'
        ],
        'respuesta': 'Las clases deben estar abiertas a extensión y cerradas a modificación'
      },
      {
        'pregunta': '¿Cómo se logra cumplir OCP?',
        'opciones': [
          'Usando interfaces y abstracciones',
          'Modificando siempre la clase base',
          'Evitando herencia'
        ],
        'respuesta': 'Usando interfaces y abstracciones'
      },
      {
        'pregunta': '¿Cuál es un beneficio de OCP?',
        'opciones': [
          'Agregar funcionalidades sin romper el código existente',
          'Hacer el sistema más rígido',
          'Aumentar dependencias'
        ],
        'respuesta': 'Agregar funcionalidades sin romper el código existente'
      },
      {
        'pregunta': '¿Qué indica una violación de OCP?',
        'opciones': [
          'Modificar una clase cada vez que aparece un nuevo requisito',
          'Tener dependencias invertidas',
          'Usar interfaces'
        ],
        'respuesta': 'Modificar una clase cada vez que aparece un nuevo requisito'
      }
   ],
    'Nivel 22 – SOLID (LSP)': [
      {
        'pregunta': '¿Qué exige LSP?',
        'opciones': [
          'Que las clases hijas puedan sustituir a las clases padre',
          'Que no exista herencia',
          'Que todo método sea estático'
        ],
        'respuesta': 'Que las clases hijas puedan sustituir a las clases padre'
      },
      {
        'pregunta': '¿Qué rompe LSP?',
        'opciones': [
          'Cambiar el comportamiento esperado de una clase base',
          'Usar interfaces',
          'Implementar polimorfismo'
        ],
        'respuesta': 'Cambiar el comportamiento esperado de una clase base'
      },
      {
        'pregunta': '¿Por qué es importante LSP?',
        'opciones': [
          'Para asegurar comportamiento predecible',
          'Para aumentar acoplamiento',
          'Para eliminar clases base'
        ],
        "respuesta": "Para asegurar comportamiento predecible"
      },
      {
        'pregunta': '¿Cuál es un síntoma de violación de LSP?',
        'opciones': [
          'Subclases que lanzan excepciones inesperadas',
          'Métodos pequeños',
          'Nombres descriptivos'
        ],
        'respuesta': 'Subclases que lanzan excepciones inesperadas'
      }
    ],
    'Nivel 23 – SOLID (ISP)': [
      {
        'pregunta': '¿Qué indica ISP?',
        'opciones': [
          'Las interfaces deben ser específicas y pequeñas',
          'Las interfaces deben tener muchos métodos',
          'Las clases no deben usar interfaces'
        ],
        'respuesta': 'Las interfaces deben ser específicas y pequeñas'
      },
      {
        'pregunta': '¿Qué problema evita ISP?',
        'opciones': [
          'Que una clase implemente métodos que no necesita',
          'Tener código limpio',
          'Tener clases pequeñas'
        ],
        'respuesta': 'Que una clase implemente métodos que no necesita'
      },
      {
        'pregunta': '¿Qué es una mala práctica según ISP?',
        'opciones': [
          'Interfaces muy grandes',
          'Interfaces con un solo método',
          'Interfaces segmentadas'
        ],
        'respuesta': 'Interfaces muy grandes'
      },
      {
        'pregunta': '¿Qué mejora ISP?',
        'opciones': [
          'Cohesión y desac acoplamiento',
          'Complejidad del sistema',
          'Número de dependencias'
        ],
        'respuesta': 'Cohesión y desac acoplamiento'
      }
    ],

    'Nivel 24 – SOLID (DIP)': [
      {
        'pregunta': '¿Qué propone DIP?',
        'opciones': [
          'Depender de abstracciones, no de implementaciones',
          'Depender siempre del código concreto',
          'Eliminar interfaces'
        ],
        'respuesta': 'Depender de abstracciones, no de implementaciones'
      },
      {
        'pregunta': '¿Qué beneficio aporta DIP?',
        'opciones': [
          'Reduce el acoplamiento',
          'Aumenta el acoplamiento',
          'Evita pruebas'
        ],
        'respuesta': 'Reduce el acoplamiento'
      },
      {
        'pregunta': '¿Qué patrón ayuda a DIP?',
        'opciones': [
          'Inyección de dependencias',
          'Singleton',
          'Adapter'
        ],
        'respuesta': 'Inyección de dependencias'
      },
      {
        'pregunta': '¿Qué rompe el DIP?',
        'opciones': [
          'Dependencias directas a clases concretas',
          'Usar abstracciones',
          'Usar interfaces'
        ],
        'respuesta': 'Dependencias directas a clases concretas'
      }
    ],

    'Nivel 25 – Versionado Semántico': [
      {
        'pregunta': '¿Qué significan los números en versionado semántico (MAJOR.MINOR.PATCH)?',
        'opciones': [
          'Cambios incompatibles, nuevas funciones, correcciones',
          'Ramificaciones, merges, conflictos',
          'Usuarios, errores, dependencias'
        ],
        'respuesta': 'Cambios incompatibles, nuevas funciones, correcciones'
      },
      {
        'pregunta': '¿Cuándo se incrementa MAJOR?',
        'opciones': [
          'Cuando se realizan cambios incompatibles',
          'Cuando se cambia documentación',
          'Cuando se arregla un bug pequeño'
        ],
        'respuesta': 'Cuando se realizan cambios incompatibles'
      },
      {
        'pregunta': '¿Cuándo se incrementa MINOR?',
        'opciones': [
          'Al agregar nuevas funcionalidades compatibles',
          'Al reescribir todo',
          'Al eliminar archivos'
        ],
        'respuesta': 'Al agregar nuevas funcionalidades compatibles'
      },
      {
        'pregunta': '¿Qué representa PATCH?',
        'opciones': [
          'Correcciones de errores',
          'Nuevas APIs',
          'Cambios mayores'
        ],
        'respuesta': 'Correcciones de errores'
      }
    ],

    'Nivel 26 – Arquitectura de Microservicios': [
      {
        'pregunta': '¿Qué caracteriza a los microservicios?',
        'opciones': [
          'Servicios pequeños, independientes y desplegables por separado',
          'Un solo servicio grande',
          'Dependencias fuertes entre módulos'
        ],
        'respuesta': 'Servicios pequeños, independientes y desplegables por separado'
      },
      {
        'pregunta': '¿Qué patrón se usa para comunicar microservicios?',
        'opciones': [
          'Mensajería asíncrona',
          'Llamadas internas a clases',
          'Memoria compartida'
        ],
        'respuesta': 'Mensajería asíncrona'
      },
      {
        'pregunta': '¿Cuál es una ventaja de microservicios?',
        'opciones': [
          'Escalabilidad independiente',
          'Mayor dependencia entre módulos',
          'Mantenimiento más difícil'
        ],
        'respuesta': 'Escalabilidad independiente'
      },
      {
        'pregunta': '¿Qué herramienta es común en microservicios?',
        'opciones': [
          'Kubernetes',
          'Excel',
          'PowerPoint'
        ],
        'respuesta': 'Kubernetes'
      }
    ],

    'Nivel 27 – DDD (Domain-Driven Design)': [
      {
        'pregunta': '¿Qué es el dominio?',
        'opciones': [
          'El problema central del negocio',
          'La base de datos',
          'La interfaz'
        ],
        'respuesta': 'El problema central del negocio'
      },
      {
        'pregunta': '¿Qué es un Bounded Context?',
        'opciones': [
          'Un límite funcional claro dentro del dominio',
          'Una tabla en la base de datos',
          'Un patrón de UI'
        ],
        'respuesta': 'Un límite funcional claro dentro del dominio'
      },
      {
        'pregunta': '¿Qué es un Value Object?',
        'opciones': [
          'Objeto sin identidad, definido por sus atributos',
          'Una entidad única',
          'Una tabla relacional'
        ],
        'respuesta': 'Objeto sin identidad, definido por sus atributos'
      },
      {
        'pregunta': '¿Qué promueve DDD?',
        'opciones': [
          'Lenguaje ubicuo',
          'Código duplicado',
          'Dependencias circulares'
        ],
        'respuesta': 'Lenguaje ubicuo'
      }
    ],

    'Nivel 28 – Bases de datos (buenas prácticas)': [
      {
        'pregunta': '¿Qué es normalizar una base de datos?',
        'opciones': [
          'Reducir redundancia de datos',
          'Crear más tablas innecesarias',
          'Duplicar información'
        ],
        'respuesta': 'Reducir redundancia de datos'
      },
      {
        'pregunta': '¿Qué es un índice?',
        'opciones': [
          'Una estructura que acelera búsquedas',
          'Un backup',
          'Un trigger'
        ],
        'respuesta': 'Una estructura que acelera búsquedas'
      },
      {
        'pregunta': '¿Por qué usar llaves primarias?',
        'opciones': [
          'Para identificar registros de manera única',
          'Para duplicar filas',
          'Para hacer consultas más lentas'
        ],
        'respuesta': 'Para identificar registros de manera única'
      },
      {
        'pregunta': '¿Qué evita SQL parametrizado?',
        'opciones': [
          'Inyección SQL',
          'Compilación',
          'Caching'
        ],
        'respuesta': 'Inyección SQL'
      }
    ],

    'Nivel 29 – API REST (buenas prácticas)': [
      {
        'pregunta': '¿Qué formato es estándar en APIs REST?',
        'opciones': [
          'JSON',
          'MP3',
          'PDF'
        ],
        'respuesta': 'JSON'
      },
      {
        'pregunta': '¿Qué representa el código 201?',
        'opciones': [
          'Recurso creado',
          'Error del servidor',
          'No autorizado'
        ],
        'respuesta': 'Recurso creado'
      },
      {
        'pregunta': '¿Qué método se usa para obtener datos?',
        'opciones': [
          'GET',
          'POST',
          'DELETE'
        ],
        'respuesta': 'GET'
      },
      {
        'pregunta': '¿Qué se recomienda en endpoints REST?',
        'opciones': [
          'Usar nombres de recursos en plural',
          'Usar verbs en los paths',
          'Usar rutas muy largas'
        ],
        'respuesta': 'Usar nombres de recursos en plural'
      }
    ],

    'Nivel 30 – Testing avanzado': [
      {
        'pregunta': '¿Qué son las pruebas de integración?',
        'opciones': [
          'Verifican interacción entre módulos',
          'Evalúan funcionalidad individual',
          'Miden rendimiento'
        ],
        'respuesta': 'Verifican interacción entre módulos'
      },
      {
        'pregunta': '¿Qué es mocking?',
        'opciones': [
          'Simular dependencias',
          'Crear copias de la base de datos',
          'Repetir pruebas'
        ],
        'respuesta': 'Simular dependencias'
      },
      {
        'pregunta': '¿Qué son pruebas E2E?',
        'opciones': [
          'Pruebas de flujo completo',
          'Pruebas de botones',
          'Pruebas del servidor'
        ],
        'respuesta': 'Pruebas de flujo completo'
      },
      {
        'pregunta': '¿Qué se mide en cobertura de código?',
        'opciones': [
          'Porcentaje del código ejecutado por pruebas',
          'Uso de CPU',
          'Cantidad de usuarios'
        ],
        'respuesta': 'Porcentaje del código ejecutado por pruebas'
      }
    ],

    'Nivel 31 – Casos de uso (conceptos básicos)': [
      {
        'pregunta': '¿Qué es un caso de uso?',
        'opciones': [
          'Una descripción de cómo un usuario interactúa con el sistema',
          'Un diagrama de base de datos',
          'Un test automatizado'
        ],
        'respuesta': 'Una descripción de cómo un usuario interactúa con el sistema'
      },
      {
        'pregunta': '¿Cuál es el objetivo de un caso de uso?',
        'opciones': [
          'Definir requerimientos funcionales',
          'Diseñar la arquitectura',
          'Crear una base de datos'
        ],
        'respuesta': 'Definir requerimientos funcionales'
      },
      {
        'pregunta': '¿Quién ejecuta un caso de uso?',
        'opciones': [
          'Un actor externo',
          'El servidor',
          'El sistema operativo'
        ],
        'respuesta': 'Un actor externo'
      },
      {
        'pregunta': '¿Qué define siempre un caso de uso?',
        'opciones': [
          'Un flujo principal y flujos alternos',
          'El diagrama ER',
          'El código fuente'
        ],
        'respuesta': 'Un flujo principal y flujos alternos'
      }
    ],

    'Nivel 32 – Identificación de actores': [
      {
        'pregunta': '¿Qué es un actor en un caso de uso?',
        'opciones': [
          'Un rol que interactúa con el sistema',
          'Un archivo del servidor',
          'Un componente UI'
        ],
        'respuesta': 'Un rol que interactúa con el sistema'
      },
      {
        'pregunta': '¿Cuál de estos es un actor?',
        'opciones': [
          'Administrador del sistema',
          'Base de datos',
          'Middleware'
        ],
        'respuesta': 'Administrador del sistema'
      },
      {
        'pregunta': '¿Qué NO se considera un actor?',
        'opciones': [
          'Una clase interna',
          'Un cliente externo',
          'Un sistema de pagos externo'
        ],
        'respuesta': 'Una clase interna'
      },
      {
        'pregunta': '¿Qué caracteriza a un actor?',
        'opciones': [
          'Tiene objetivos respecto al sistema',
          'Debe tener cuenta registrada',
          'Debe ser siempre un usuario humano'
        ],
        'respuesta': 'Tiene objetivos respecto al sistema'
      }
    ],

    'Nivel 33 – Flujo principal y alternos': [
      {
        'pregunta': '¿Qué describe el flujo principal?',
        'opciones': [
          'El camino ideal sin errores',
          'Los errores posibles',
          'Los casos excepcionales'
        ],
        'respuesta': 'El camino ideal sin errores'
      },
      {
        'pregunta': '¿Qué representan los flujos alternos?',
        'opciones': [
          'Variaciones controladas del proceso',
          'El caso ideal',
          'Requerimientos no funcionales'
        ],
        'respuesta': 'Variaciones controladas del proceso'
      },
      {
        'pregunta': '¿Qué es un flujo de excepción?',
        'opciones': [
          'Un escenario donde algo falla',
          'Una mejora opcional del flujo',
          'Un requisito adicional'
        ],
        'respuesta': 'Un escenario donde algo falla'
      },
      {
        'pregunta': '¿Qué debe evitarse al documentar flujos?',
        'opciones': [
          'Describir detalles técnicos innecesarios',
          'Usar verbos en infinitivo',
          'Separar actores'
        ],
        'respuesta': 'Describir detalles técnicos innecesarios'
      }
    ],

    'Nivel 34 – Errores comunes en casos de uso': [
      {
        'pregunta': '¿Cuál es un error común al definir casos de uso?',
        'opciones': [
          'Describir la interfaz gráfica',
          'Definir actores',
          'Definir flujos'
        ],
        'respuesta': 'Describir la interfaz gráfica'
      },
      {
        'pregunta': '¿Qué error genera confusión en un caso de uso?',
        'opciones': [
          'Usar actores incorrectos',
          'Usar pasos numerados',
          'Usar lenguaje claro'
        ],
        'respuesta': 'Usar actores incorrectos'
      },
      {
        'pregunta': '¿Qué NO debe incluirse en un caso de uso?',
        'opciones': [
          'Código o detalles técnicos',
          'Objetivos del sistema',
          'Condiciones de éxito'
        ],
        'respuesta': 'Código o detalles técnicos'
      },
      {
        'pregunta': '¿Qué problema causa no definir las precondiciones?',
        'opciones': [
          'Flujos ambiguos',
          'Casos de uso más cortos',
          'Más documentación'
        ],
        'respuesta': 'Flujos ambiguos'
      }
    ],

    'Nivel 35 – Validaciones en casos de uso': [
      {
        'pregunta': '¿Qué es una precondición?',
        'opciones': [
          'Algo que debe cumplirse antes de iniciar el caso de uso',
          'Un paso final',
          'Un flujo alterno'
        ],
        'respuesta': 'Algo que debe cumplirse antes de iniciar el caso de uso'
      },
      {
        'pregunta': '¿Qué es una postcondición?',
        'opciones': [
          'El estado esperado del sistema tras finalizar el caso',
          'Una excepción',
          'Una regla del negocio secundaria'
        ],
        'respuesta': 'El estado esperado del sistema tras finalizar el caso'
      },
      {
        'pregunta': '¿Qué debe validarse en un flujo de excepción?',
        'opciones': [
          'Acciones del sistema en caso de fallo',
          'Nuevo requerimiento',
          'Estilos visuales'
        ],
        'respuesta': 'Acciones del sistema en caso de fallo'
      },
      {
        'pregunta': '¿Qué se valida en un actor?',
        'opciones': [
          'Que tenga un objetivo funcional',
          'Que sea un usuario registrado',
          'Que sea interno al sistema'
        ],
        'respuesta': 'Que tenga un objetivo funcional'
      }
    ],

    'Nivel 36 – Requisitos derivados': [
      {
        'pregunta': '¿Qué permite obtener un caso de uso detallado?',
        'opciones': [
          'Requisitos funcionales adicionales',
          'Código reutilizable',
          'Esquemas de la base de datos'
        ],
        'respuesta': 'Requisitos funcionales adicionales'
      },
      {
        'pregunta': '¿Qué deriva directamente del flujo del caso de uso?',
        'opciones': [
          'Historias de usuario',
          'El diseño UI',
          'La arquitectura'
        ],
        'respuesta': 'Historias de usuario'
      },
      {
        'pregunta': '¿Qué puede aparecer al analizar excepciones?',
        'opciones': [
          'Nuevas reglas del negocio',
          'Nuevos colores',
          'Nuevas pantallas decorativas'
        ],
        'respuesta': 'Nuevas reglas del negocio'
      },
      {
        'pregunta': '¿Qué se documenta al identificar restricciones?',
        'opciones': [
          'Requisitos no funcionales',
          'Código fuente',
          'Logs del sistema'
        ],
        'respuesta': 'Requisitos no funcionales'
      }
    ],

    'Nivel 37 – Casos de uso y UI/UX': [
      {
        'pregunta': '¿Cómo se relacionan los casos de uso con las pantallas?',
        'opciones': [
          'Los casos de uso justifican la existencia de pantallas',
          'Los casos de uso describen botones exactos',
          'Los casos de uso reemplazan a los mockups'
        ],
        'respuesta': 'Los casos de uso justifican la existencia de pantallas'
      },
      {
        'pregunta': '¿Qué NO debe hacer un caso de uso?',
        'opciones': [
          'Describir la interfaz visual',
          'Describir intenciones del usuario',
          'Describir respuestas del sistema'
        ],
        'respuesta': 'Describir la interfaz visual'
      },
      {
        'pregunta': '¿Qué relación tienen historias de usuario y casos de uso?',
        'opciones': [
          'Las historias pueden derivar de casos de uso',
          'Son equivalentes',
          'No se relacionan'
        ],
        'respuesta': 'Las historias pueden derivar de casos de uso'
      },
      {
        'pregunta': '¿Qué produce una mala relación entre UI y casos de uso?',
        'opciones': [
          'Flujos confusos',
          'Arquitecturas más limpias',
          'Más modularidad'
        ],
        'respuesta': 'Flujos confusos'
      }
    ],

    'Nivel 38 – Casos de uso en APIs': [
      {
        'pregunta': '¿Cómo ayuda un caso de uso al diseñar una API?',
        'opciones': [
          'Define qué recursos y endpoints serán necesarios',
          'Define el modelo de base de datos',
          'Elige la tecnología'
        ],
        'respuesta': 'Define qué recursos y endpoints serán necesarios'
      },
      {
        'pregunta': '¿Qué corresponde documentar para un caso de uso API?',
        'opciones': [
          'Entradas y salidas del endpoint',
          'Estilos del frontend',
          'Logs del servidor'
        ],
        'respuesta': 'Entradas y salidas del endpoint'
      },
      {
        'pregunta': '¿Qué ocurre si un caso de uso está incompleto?',
        'opciones': [
          'Endpoints mal diseñados',
          'Más seguridad',
          'Menos tráfico de red'
        ],
        'respuesta': 'Endpoints mal diseñados'
      },
      {
        'pregunta': '¿Qué debe incluir un caso de uso con servicios externos?',
        'opciones': [
          'Flujos de error del proveedor externo',
          'Diseño de UI',
          'Mockups'
        ],
        'respuesta': 'Flujos de error del proveedor externo'
      }
    ],

    'Nivel 39 – Métricas y calidad': [
      {
        'pregunta': '¿Qué mide la calidad de un caso de uso?',
        'opciones': [
          'Claridad y completitud',
          'Cantidad de pantallas',
          'Número de endpoints'
        ],
        'respuesta': 'Claridad y completitud'
      },
      {
        'pregunta': '¿Qué indica un caso de uso demasiado largo?',
        'opciones': [
          'Existe más de un flujo independiente',
          'Está bien detallado',
          'Faltan excepciones'
        ],
        'respuesta': 'Existe más de un flujo independiente'
      },
      {
        'pregunta': '¿Qué representa un caso de uso redundante?',
        'opciones': [
          'Mal análisis del dominio',
          'Buena documentación',
          'Más modularidad'
        ],
        'respuesta': 'Mal análisis del dominio'
      },
      {
        'pregunta': '¿Qué mejora dividir casos de uso correctamente?',
        'opciones': [
          'Trazabilidad y mantenimiento',
          'Tamaño del frontend',
          'Número de queries SQL'
        ],
        'respuesta': 'Trazabilidad y mantenimiento'
      }
    ],

    'Nivel 40 – Casos de uso avanzados (sistemas complejos)': [
      {
        'pregunta': '¿Qué incorpora un caso de uso avanzado?',
        'opciones': [
          'Interacciones con múltiples sistemas',
          'Detalles de la base de datos',
          'Pantallas exactas'
        ],
        'respuesta': 'Interacciones con múltiples sistemas'
      },
      {
        'pregunta': '¿Qué debe documentarse cuando hay colas o mensajería?',
        'opciones': [
          'Pasos asincrónicos',
          'Estilos CSS',
          'Permisos de usuario'
        ],
        'respuesta': 'Pasos asincrónicos'
      },
      {
        'pregunta': '¿Qué se vuelve crucial en un caso de uso distribuido?',
        'opciones': [
          'Escenarios de falla',
          'Decorar la interfaz',
          'Reducir endpoints'
        ],
        'respuesta': 'Escenarios de falla'
      },
      {
        'pregunta': '¿Qué permite un caso de uso bien modelado en sistemas grandes?',
        'opciones': [
          'Coordinación entre equipos',
          'Eliminar pruebas',
          'Evitar microservicios'
        ],
        'respuesta': 'Coordinación entre equipos'
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _loadProgress(); // 🔹 Cargar progreso desde SQL
  }

  Future<void> _loadProgress() async {
    int count = await quizDAO.getUnlockedLevels();
    int attempts = await quizDAO.getAttempts();

    setState(() {
      unlockedLevel = count;
      quizAttempts = attempts;
    });
  }


  void _startQuiz(String nivel, int nivelIndex) async {
    // 🔥 Registrar intento SIEMPRE
    await quizDAO.registerAttempt();
    quizAttempts++;

    // Ver si se desbloquea el minijuego
    if (quizAttempts >= 10) {
      await quizDAO.saveProgress(unlockedLevel);
      setState(() {});
    }

    bool aprobado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelQuizScreen(
          nivel: nivel,
          preguntas: quizzes[nivel]!,
        ),
      ),
    );

    if (aprobado && nivelIndex == unlockedLevel && nivelIndex < quizzes.length - 1) {
      await quizDAO.saveProgress(unlockedLevel);
      setState(() => unlockedLevel++);
    }
  }


  @override
  Widget build(BuildContext context) {
    final niveles = quizzes.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text('🧠 Quiz de Buenas Prácticas')),
      body: ListView(
        children: [
          // -------------------------
          // 🔹 LISTA DE NIVELES NORMALES
          // -------------------------
          ...List.generate(niveles.length, (index) {
            final nivel = niveles[index];
            final bloqueado = index > unlockedLevel;

            return Card(
              margin: EdgeInsets.all(8),
              color: bloqueado ? Colors.blue[200] : Colors.blueAccent,
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.black),
                title: Text(
                  nivel,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  bloqueado ? '🔒 Bloqueado' : '✅ Disponible',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: bloqueado ? null : () => _startQuiz(nivel, index),
              ),
            );
          }),

          // ---------------------------------------
          // 🎮 MINIJUEGO PONG → 10 INTENTOS
          // ---------------------------------------
          Card(
            margin: EdgeInsets.all(8),
            color: quizAttempts < 10 ? Colors.grey[400] : Colors.greenAccent,
            child: ListTile(
              leading: Icon(Icons.sports_tennis, color: Colors.black),
              title: Text(
                '🎮 Minijuego Ping Pong',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                quizAttempts < 10
                    ? '🔒 Se desbloquea al hacer 10 quizzes'
                    : '🎉 Disponible',
                style: TextStyle(color: Colors.black),
              ),
              onTap: quizAttempts < 10
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PongGameScreen()),
                );
              },
            ),
          ),

          // ---------------------------------------
          // 🏃 MINIJUEGO RUNNER → 20 INTENTOS
          // ---------------------------------------
          Card(
            margin: EdgeInsets.all(8),
            color: quizAttempts < 20 ? Colors.grey[400] : Colors.orangeAccent,
            child: ListTile(
              leading: Icon(Icons.directions_run, color: Colors.black),
              title: Text(
                '🏃 Minijuego Runner',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                quizAttempts < 20
                    ? '🔒 Se desbloquea al hacer 20 quizzes'
                    : '🎉 Disponible',
                style: TextStyle(color: Colors.black),
              ),
              onTap: quizAttempts < 20
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RunGameScreen()),
                );
              },
            ),
          ),

// ---------------------------------------
// 🎯 NUEVO MINIJUEGO → 30 INTENTOS
// ---------------------------------------
          Card(
            margin: EdgeInsets.all(8),
            color: quizAttempts < 30 ? Colors.grey[400] : Colors.purpleAccent,
            child: ListTile(
              leading: Icon(Icons.videogame_asset, color: Colors.black),
              title: Text(
                ' ▯ Minijuego Bloks ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                quizAttempts < 30
                    ? '🔒 Se desbloquea al hacer 30 quizzes'
                    : '🎉 Disponible',
                style: TextStyle(color: Colors.black),
              ),
              onTap: quizAttempts < 30
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AvoidBlocksGame()),
                );
              },
            ),
          ),

          Card(
            margin: EdgeInsets.all(8),
            color: quizAttempts < 40 ? Colors.grey[400] : Colors.purpleAccent,
            child: ListTile(
              leading: Icon(Icons.star, color: Colors.black),
              title: Text(
                '⭐ Minijuego Estrellas',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                quizAttempts < 40
                    ? '🔒 Se desbloquea al hacer 40 quizzes'
                    : '🎉 Disponible',
                style: TextStyle(color: Colors.black),
              ),
              onTap: quizAttempts < 40
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StarCollectorGame()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LevelQuizScreen extends StatefulWidget {
  final String nivel;
  final List<Map<String, Object>> preguntas;

  LevelQuizScreen({required this.nivel, required this.preguntas});

  @override
  _LevelQuizScreenState createState() => _LevelQuizScreenState();
}

class _LevelQuizScreenState extends State<LevelQuizScreen> {
  int correctas = 0;
  int indexPregunta = 0;
  late List<String> opcionesMezcladas;

  @override
  void initState() {
    super.initState();
    _mezclarOpciones();
  }

  void _mezclarOpciones() {
    opcionesMezcladas = List<String>.from(
        widget.preguntas[indexPregunta]['opciones'] as List<String>
    );
    opcionesMezcladas.shuffle(Random());
  }

  void _responder(String seleccion) {
    final correcta = widget.preguntas[indexPregunta]['respuesta'] as String;

    if (seleccion == correcta) correctas++;

    if (indexPregunta < widget.preguntas.length - 1) {
      setState(() {
        indexPregunta++;
        _mezclarOpciones();
      });
    } else {
      bool aprobado = correctas >= (widget.preguntas.length / 2).ceil();

      Navigator.pop(context, aprobado);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            aprobado
                ? '✅ Aprobaste con $correctas/${widget.preguntas.length}'
                : '❌ No aprobaste. Intenta de nuevo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = widget.preguntas[indexPregunta];

    return Scaffold(
      appBar: AppBar(title: Text(widget.nivel)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pregunta['pregunta'] as String,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...opcionesMezcladas.map((opcion) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => _responder(opcion),
                  child: Text(opcion),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class PongGameScreen extends StatefulWidget {
  @override
  _PongGameScreenState createState() => _PongGameScreenState();
}

class _PongGameScreenState extends State<PongGameScreen>
    with SingleTickerProviderStateMixin {

  // --- Variables del juego ---
  double ballX = 0;
  double ballY = 0;
  double ballSpeedX = 0.015;
  double ballSpeedY = 0.015;

  double paddleX = 0;
  double paddleWidth = 0.3;
  double paddleVisualScale = 0.5; // 50% del tamaño real


  late AnimationController controller;

  int score = 0;
  bool showMessage = false;
  String messageText = "";
  bool isFinalMessage = false; // ⬅️ Para saber si el mensaje lleva título o no

  bool finalMessageShown = false; // ⬅️ No mostrar más mensajes después del final

  final List<String> goodPractices = [
    "Divide el código en funciones pequeñas.",
    "Nombrar variables claramente mejora la comprensión.",
    "Evita duplicar código (principio DRY).",
    "Realiza pruebas unitarias durante el desarrollo.",
    "Prefiere simplicidad sobre complejidad innecesaria.",
    "Refactoriza cuando el código crezca.",
    "Escribe comentarios solo cuando realmente ayudan.",
    "Usa control de versiones (Git).",
    "Documenta las decisiones importantes.",
    "Desarrolla funciones con una única responsabilidad.",
  ];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateGame);

    controller.repeat();
  }

  void _updateGame() {
    if (showMessage) return; // ⛔ Pausa del juego

    setState(() {
      ballX += ballSpeedX;
      ballY += ballSpeedY;

      // Rebotes laterales
      if (ballX <= -1 || ballX >= 1) {
        ballSpeedX = -ballSpeedX;
      }

      // Rebote superior
      if (ballY <= -1) {
        ballSpeedY = -ballSpeedY;
      }

      // Colisión con la paleta
      if (ballY >= 0.92) {
        if (ballX >= paddleX - paddleWidth && ballX <= paddleX + paddleWidth) {
          score++;
          ballSpeedY = -ballSpeedY;

          ballSpeedX *= 1.05;
          ballSpeedY *= 1.05;

          // ---- MENSAJES CADA 5 PUNTOS ----
          if (!finalMessageShown && score < 30 && score % 5 == 0) {
            isFinalMessage = false; // No es el final
            messageText = goodPractices[Random().nextInt(goodPractices.length)];

            showMessage = true;
            controller.stop();
          }

          // ---- MENSAJE FINAL AL LLEGAR A 30 ----
          if (score == 30 && !finalMessageShown) {
            finalMessageShown = true;
            isFinalMessage = true; // ⬅️ Este NO lleva título

            messageText = """
¡Felicidades! Alcanzaste 30 puntos 🎉

Este juego fue creado usando:
• AnimationController para animaciones.
• Detección de colisiones.
• Lógica de dificultad progresiva.
• Widgets personalizados para pelota y paleta.
• Pausa automática para mostrar mensajes.

¡Sigue jugando mientras quieras!
""";

            showMessage = true;
            controller.stop();
          }

        } else {
          // Reinicio al perder
          score = 0;
          ballX = 0;
          ballY = 0;
          ballSpeedX = 0.015;
          ballSpeedY = 0.015;
        }
      }
    });
  }

  void _closeMessage() {
    setState(() => showMessage = false);
    controller.repeat(); // ▶️ Reanudar juego
  }

  void _movePaddle(DragUpdateDetails details) {
    if (showMessage) return;

    setState(() {
      paddleX += details.delta.dx / MediaQuery.of(context).size.width * 2;
      paddleX = paddleX.clamp(-1.0, 1.0);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _movePaddle,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Pelota
            Align(
              alignment: Alignment(ballX, ballY),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Paleta
            Align(
              alignment: Alignment(paddleX, 0.95),
              child: Container(
                width: MediaQuery.of(context).size.width * paddleWidth * paddleVisualScale,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),


            // Score
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                "Puntos: $score",
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            // MENSAJE EMERGENTE
            if (showMessage)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TÍTULO SOLO PARA MENSAJES NORMALES
                      if (!isFinalMessage)
                        const Text(
                          "Consejos de programación",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      if (!isFinalMessage)
                        const SizedBox(height: 10),

                      // CONTENIDO DEL MENSAJE
                      Text(
                        messageText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: _closeMessage,
                        child: const Text("Cerrar"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class RunGameScreen extends StatefulWidget {
  @override
  _RunGameScreenState createState() => _RunGameScreenState();
}

class _RunGameScreenState extends State<RunGameScreen>
    with SingleTickerProviderStateMixin {

  // ──────────────────────────────
  // VARIABLES DEL JUEGO
  // ──────────────────────────────
  int jumpCount = 0;
  final int maxJumps = 2;

  double playerY = 0;         // Posición vertical del jugador
  double velocity = 0;        // Velocidad de salto
  final double gravity = -0.0010;

  double obstacleX = 1.2;     // Obstáculo entrando desde la derecha
  double obstacleSpeed = 0.01;

  int score = 0;

  bool isJumping = false;
  bool showMessage = false;
  bool isFinalMessage = false;
  bool finalMessageShown = false;

  late AnimationController controller;

  String messageText = "";

  final List<String> goodPractices = [
    "Escribe código legible primero, optimiza después.",
    "Divide responsabilidades en clases pequeñas.",
    "Aplica KISS: mantenlo simple.",
    "Haz revisiones de código con tu equipo.",
    "Controla errores con try/catch.",
    "Configura linters y formateadores automáticos.",
    "Comenta la intención, no lo obvio.",
    "Prefiere composición sobre herencia.",
    "Documenta tu arquitectura.",
    "Prueba código crítico desde temprano.",
  ];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateGame);

    controller.repeat();
  }

  // ──────────────────────────────
  // ACTUALIZACIÓN DE FÍSICAS
  // ──────────────────────────────
  void _updateGame() {
    if (showMessage) return;

    setState(() {
      // Movimiento de salto
      velocity += gravity;
      playerY += velocity;

      if (playerY < 0) {
        playerY = 0;
        velocity = 0;
        isJumping = false;
        jumpCount = 0;
      }


      // Movimiento del obstáculo
      obstacleX -= obstacleSpeed;

      if (obstacleX < -1.2) {
        // Regresa el obstáculo y aumenta punto
        obstacleX = 1.2;
        score++;

        obstacleSpeed *= 1.05;

        // Mensaje cada 5 puntos
        if (!finalMessageShown && score < 30 && score % 5 == 0) {
          isFinalMessage = false;
          messageText = goodPractices[Random().nextInt(goodPractices.length)];

          showMessage = true;
          controller.stop();
        }

        // Mensaje final
        if (score == 30 && !finalMessageShown) {
          finalMessageShown = true;
          isFinalMessage = true;

          messageText = """
¡Llegaste a 30 puntos! 🎉

Este juego funciona con:
• Física simple (gravedad + salto)
• Movimiento continuo de obstáculos
• Colisión por bounding boxes
• Dificultad que aumenta con la velocidad
• AnimationController para actualizar el juego
• Pausa automática con mensajes emergentes

¡Bien hecho!
""";

          showMessage = true;
          controller.stop();
        }
      }

      // Detectar colisión
      if (_isCollision()) {
        _restartGame();
      }
    });
  }

  bool _isCollision() {
    double playerLeft = -0.8;
    double playerRight = -0.6;
    double playerBottom = playerY;
    double playerTop = playerY + 0.3;

    double obsLeft = obstacleX - 0.1;
    double obsRight = obstacleX + 0.1;
    double obsBottom = 0;
    double obsTop = 0.3;

    bool xOverlap = playerRight > obsLeft && playerLeft < obsRight;
    bool yOverlap = playerBottom < obsTop && playerTop > obsBottom;

    return xOverlap && yOverlap;
  }


  void _restartGame() {
    score = 0;
    playerY = 0;
    velocity = 0;
    obstacleX = 1.2;
    obstacleSpeed = 0.01;
  }

  void _jump() {
    if (showMessage) return;

    if (jumpCount < maxJumps) {
      velocity = 0.045;   // fuerza del salto
      isJumping = true;
      jumpCount++;        // ← registra un salto
    }
  }


  void _closeMessage() {
    setState(() {
      showMessage = false;
    });
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ──────────────────────────────
  // UI DEL JUEGO
  // ──────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _jump,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [

            // Jugador (cuadrado)
            Align(
              alignment: Alignment(-0.7, 1 - playerY),
              child: Container(
                width: 40,
                height: 40,
                color: Colors.cyanAccent,
              ),
            ),

            // Obstáculo
            Align(
              alignment: Alignment(obstacleX, 1),
              child: Container(
                width: 35,
                height: 40,
                color: Colors.redAccent,
              ),
            ),

            // Score
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                "Puntos: $score",
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            // MENSAJE
            if (showMessage)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isFinalMessage)
                        const Text(
                          "Consejo de programación",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      if (!isFinalMessage)
                        const SizedBox(height: 10),

                      Text(
                        messageText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: _closeMessage,
                        child: const Text("Cerrar"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class AvoidBlocksGame extends StatefulWidget {
  @override
  _AvoidBlocksGameState createState() => _AvoidBlocksGameState();
}

class _AvoidBlocksGameState extends State<AvoidBlocksGame>
    with SingleTickerProviderStateMixin {

  // ─────────────────────────────────────
  // JUGADOR
  // ─────────────────────────────────────
  double playerX = 0;     // -1 a 1
  final double playerWidth = 0.15;

  // ─────────────────────────────────────
  // OBSTÁCULOS
  // ─────────────────────────────────────
  List<Block> blocks = [];
  double blockSpeed = 0.01;
  Random rng = Random();

  // ─────────────────────────────────────
  // PUNTOS Y MENSAJES
  // ─────────────────────────────────────
  int score = 0;
  bool showMessage = false;
  bool isFinalMessage = false;
  bool finalUnlocked = false;
  String messageText = "";

  final List<String> tips = [
    "Divide tus clases en archivos separados.",
    "Evita nombres genéricos como data o manager.",
    "Usa const cuando sea posible.",
    "Prefiere composición antes que herencia.",
    "Evita métodos muy largos.",
    "No ignores warnings del análisis.",
    "Separar lógica de UI mejora mantenimiento.",
    "Haz commits pequeños y descriptivos.",
    "Usa Widgets puros siempre que puedas.",
    "Compara objetos por valor, no por referencia.",
  ];

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 16),
    )..addListener(_updateGame);

    controller.repeat();
  }

  // ─────────────────────────────────────
  // LÓGICA DEL JUEGO
  // ─────────────────────────────────────
  void _updateGame() {
    if (showMessage) return;

    setState(() {
      /// Crear obstáculos si hay pocos
      if (blocks.length < 3) {
        blocks.add(Block(
          x: rng.nextDouble() * 2 - 1,
          y: -1.2,
          width: 0.2,
          height: 0.08,
        ));
      }

      /// Mover obstáculos
      for (var b in blocks) {
        b.y += blockSpeed;
      }

      /// Si salen por abajo → reiniciar y sumar punto
      for (var b in blocks) {
        if (b.y > 1.2) {
          b.y = -1.2;
          b.x = rng.nextDouble() * 2 - 1;

          score++;

          // Aumentar velocidad con el tiempo
          blockSpeed += 0.0004;

          if (!finalUnlocked && score < 30 && score % 5 == 0) {
            messageText = tips[rng.nextInt(tips.length)];
            isFinalMessage = false;
            showMessage = true;
            controller.stop();
          }

          if (score == 30 && !finalUnlocked) {
            finalUnlocked = true;
            isFinalMessage = true;
            messageText = """
🎉 ¡Llegaste a 30 puntos!

Este juego utiliza:
• Obstáculos dinámicos
• Movimiento horizontal libre
• Detección de colisiones por bounding box
• Velocidad progresiva
• Pausas con mensajes automáticos
• AnimationController como bucle de juego

¡Gran trabajo!
            """;
            showMessage = true;
            controller.stop();
          }
        }
      }

      /// COLISIÓN
      for (var b in blocks) {
        if (_collision(b)) {
          _restart();
        }
      }
    });
  }

  // ─────────────────────────────────────
  // DETECCIÓN DE COLISIÓN
  // ─────────────────────────────────────
  bool _collision(Block b) {
    double playerLeft = playerX - playerWidth;
    double playerRight = playerX + playerWidth;

    double blockLeft = b.x - b.width;
    double blockRight = b.x + b.width;

    bool horizontal = playerRight > blockLeft && playerLeft < blockRight;
    bool vertical = (b.y + b.height) > 0.8 && (b.y - b.height) < 1;

    return horizontal && vertical;
  }

  // ─────────────────────────────────────
  // REINICIAR
  // ─────────────────────────────────────
  void _restart() {
    blocks.clear();
    blockSpeed = 0.01;

    score = 0;
    finalUnlocked = false;

    playerX = 0;
  }

  void _movePlayer(DragUpdateDetails d) {
    if (showMessage) return;

    playerX += d.delta.dx / MediaQuery.of(context).size.width * 2;

    playerX = playerX.clamp(-1.0, 1.0);
  }

  void _closeMessage() {
    showMessage = false;
    controller.repeat();
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────
  // UI
  // ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _movePlayer,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [

            // Jugador
            Align(
              alignment: Alignment(playerX, 0.9),
              child: Container(
                width: MediaQuery.of(context).size.width * playerWidth,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

            // Obstáculos
            ...blocks.map((b) {
              return Align(
                alignment: Alignment(b.x, b.y),
                child: Container(
                  width: MediaQuery.of(context).size.width * b.width,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            }).toList(),

            // Score
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                "Puntos: $score",
                style: TextStyle(color: Colors.white, fontSize: 26),
              ),
            ),

            // MENSAJE EMERGENTE
            if (showMessage)
              Center(
                child: Container(
                  padding: EdgeInsets.all(18),
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isFinalMessage)
                        Text(
                          "Consejo de programación",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      SizedBox(height: 10),

                      Text(
                        messageText,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      SizedBox(height: 14),

                      ElevatedButton(
                        onPressed: _closeMessage,
                        child: Text("Cerrar"),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Block {
  double x;
  double y;
  double width;
  double height;

  Block({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}


class StarCollectorGame extends StatefulWidget {
  @override
  _StarCollectorGameState createState() => _StarCollectorGameState();
}

class _StarCollectorGameState extends State<StarCollectorGame>
    with SingleTickerProviderStateMixin {

  // ───────────────────────────────────────────────
  // JUGADOR
  // ───────────────────────────────────────────────
  double playerX = 0;
  double playerY = 0.7;
  final double playerSize = 0.10;

  // ───────────────────────────────────────────────
  // OBJETOS (estrellas y bombas)
  // ───────────────────────────────────────────────
  List<FallingObject> stars = [];
  List<FallingObject> bombs = [];

  double fallingSpeed = 0.01;
  Random rng = Random();

  // ───────────────────────────────────────────────
  // SISTEMA DE MENSAJES Y PUNTOS
  // ───────────────────────────────────────────────
  int score = 0;
  bool showMessage = false;
  bool isFinalMessage = false;
  bool finalShown = false;
  String messageText = "";

  final List<String> tips = [
    "Usa variables finales cuando no cambian.",
    "Evita condicionales demasiado profundos.",
    "Divide el widget en componentes más pequeños.",
    "Evita reconstrucciones innecesarias.",
    "Mantén tus funciones cortas y precisas.",
    "Usa listas inmutables cuando sea posible.",
    "Desacopla la lógica de la UI.",
    "Documenta decisiones importantes.",
    "Nombra variables con claridad.",
    "Refactoriza antes de que el código crezca demasiado.",
  ];

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 16),
    )..addListener(_updateGame);

    controller.repeat();
  }

  // ───────────────────────────────────────────────
  // ACTUALIZACIÓN DEL JUEGO
  // ───────────────────────────────────────────────
  void _updateGame() {
    if (showMessage) return;

    setState(() {
      // Generar estrellas
      if (stars.length < 5) {
        stars.add(FallingObject(
          x: rng.nextDouble() * 2 - 1,
          y: -1.2,
          size: 0.08,
          isBomb: false,
        ));
      }

      // Generar bombas
      if (bombs.length < 3) {
        bombs.add(FallingObject(
          x: rng.nextDouble() * 2 - 1,
          y: -1.2,
          size: 0.09,
          isBomb: true,
        ));
      }

      // Mover estrellas
      for (var s in stars) s.y += fallingSpeed;

      // Mover bombas
      for (var b in bombs) b.y += fallingSpeed * 1.1;

      // Estrellas que pasan → desaparecen
      for (var s in stars) {
        if (s.y > 1.2) {
          s.y = -1.2;
          s.x = rng.nextDouble() * 2 - 1;
        }
      }

      // Bombas que pasan → desaparecen
      for (var b in bombs) {
        if (b.y > 1.2) {
          b.y = -1.2;
          b.x = rng.nextDouble() * 2 - 1;
        }
      }

      // COLISIÓN CON ESTRELLA
      stars.removeWhere((s) {
        if (_collision(s)) {
          score++;
          fallingSpeed += 0.001; // Aumento progresivo

          if (!finalShown && score < 30 && score % 5 == 0) {
            messageText = tips[rng.nextInt(tips.length)];
            showMessage = true;
            isFinalMessage = false;
            controller.stop();
          }

          if (score == 30 && !finalShown) {
            finalShown = true;
            isFinalMessage = true;
            messageText = """
🎉 ¡Felicitaciones, llegaste a 30 puntos!

Este juego se programó con:
• Objetos dinámicos cayendo
• Detección de colisión basada en distancia
• Velocidad progresiva
• Pausas controladas con AnimationController
• Eventos de recolección y evasión

¡Gran trabajo!
            """;
            showMessage = true;
            controller.stop();
          }

          return true;
        }
        return false;
      });

      // COLISIÓN CON BOMBA → reinicio
      for (var b in bombs) {
        if (_collision(b)) {
          _restart();
        }
      }
    });
  }

  // ───────────────────────────────────────────────
  // DETECCIÓN DE COLISIÓN (por distancia)
  // ───────────────────────────────────────────────
  bool _collision(FallingObject obj) {
    double dx = (playerX - obj.x).abs();
    double dy = (playerY - obj.y).abs();

    // hitbox reducido
    return dx < (playerSize * 0.6 + obj.size * 0.6) &&
        dy < (playerSize * 0.6 + obj.size * 0.6);
  }


  // ───────────────────────────────────────────────
  // REINICIAR JUEGO
  // ───────────────────────────────────────────────
  void _restart() {
    stars.clear();
    bombs.clear();
    score = 0;
    fallingSpeed = 0.01;
    finalShown = false;

    playerX = 0;
    playerY = 0.7;
  }

  // ───────────────────────────────────────────────
  // MOVER JUGADOR
  // ───────────────────────────────────────────────
  void _movePlayer(DragUpdateDetails d) {
    if (showMessage) return;

    playerX += d.delta.dx / MediaQuery.of(context).size.width * 2;
    playerY += d.delta.dy / MediaQuery.of(context).size.height * 2;

    playerX = playerX.clamp(-1.0, 1.0);
    playerY = playerY.clamp(-1.0, 1.0);
  }

  void _closeMessage() {
    showMessage = false;
    controller.repeat();
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────
  // UI DEL JUEGO
  // ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _movePlayer,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [

            // JUGADOR
            Align(
              alignment: Alignment(playerX, playerY),
              child: Container(
                width: MediaQuery.of(context).size.width * playerSize,
                height: MediaQuery.of(context).size.width * playerSize,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ESTRELLAS
            ...stars.map((s) {
              return Align(
                alignment: Alignment(s.x, s.y),
                child: Icon(Icons.star, color: Colors.amber, size: 32),
              );
            }).toList(),

            // BOMBAS
            ...bombs.map((b) {
              return Align(
                alignment: Alignment(b.x, b.y),
                child: Icon(Icons.brightness_1, color: Colors.red, size: 28),
              );
            }).toList(),

            // SCORE
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                "Puntos: $score",
                style: TextStyle(color: Colors.white, fontSize: 26),
              ),
            ),

            // MENSAJE EMERGENTE
            if (showMessage)
              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isFinalMessage)
                        Text(
                          "Consejo de programación",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      SizedBox(height: 10),

                      Text(
                        messageText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),

                      SizedBox(height: 14),

                      ElevatedButton(
                        onPressed: _closeMessage,
                        child: Text("Cerrar"),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────
// MODELO DE OBJETO QUE CAE
// ───────────────────────────────────────────────
class FallingObject {
  double x;
  double y;
  double size;
  bool isBomb;

  FallingObject({
    required this.x,
    required this.y,
    required this.size,
    required this.isBomb,
  });
}