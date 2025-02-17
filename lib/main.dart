import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mammoth_controller/models/pattern.dart' as models;

import 'package:mammoth_controller/pattern_selector.dart';
import 'package:mammoth_controller/config_page.dart';
import 'package:mammoth_controller/widgets/connection_status_bar.dart';


var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 96, 59, 181),
  brightness: Brightness.light,
);

var kDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 96, 59, 181),
  brightness: Brightness.dark,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
    runApp(const MammothController());
  });
}

class MammothController extends StatefulWidget {
  const MammothController({super.key});

  @override
  State<MammothController> createState() => _MammothControllerState();
}

class _MammothControllerState extends State<MammothController> {
  ThemeMode _themeMode = ThemeMode.system;
  List<models.Pattern> _patterns = [];

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await ConfigPage.getThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colossal Collective Mammoth Controller',
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kColorScheme.primaryContainer,
          foregroundColor: kColorScheme.onPrimaryContainer,
          elevation: 2,
        ),
        cardTheme: const CardTheme().copyWith(
          color: kColorScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primaryContainer,
            foregroundColor: kColorScheme.onPrimaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: kColorScheme.onSecondaryContainer,
            fontSize: 20,
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
        cardTheme: const CardTheme().copyWith(
          color: kDarkColorScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkColorScheme.primaryContainer,
            foregroundColor: kDarkColorScheme.onPrimaryContainer,
          ),
        ),
      ),
      themeMode: _themeMode,
      home: HomePage(
        onThemeChanged: _updateThemeMode,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onThemeChanged,
  });

  final void Function(ThemeMode) onThemeChanged;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<models.Pattern> _patterns = [];
  String _baseUrl = ConfigPage.defaultBaseUrl;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final url = await ConfigPage.getBaseUrl();
    setState(() {
      _baseUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_patterns.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fetch patterns to begin using the app'),
            duration: Duration(seconds: 4),
          ),
        );
      });

      return Scaffold(
        appBar: AppBar(
          title: const Text('Mammoth Controller Home'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No patterns loaded',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please fetch patterns from the config page to begin',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final patterns = await Navigator.push<List<models.Pattern>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfigPage(
                        currentPatterns: _patterns,
                        onPatternsUpdated: _updatePatterns,
                        onThemeChanged: widget.onThemeChanged,
                      ),
                    ),
                  );
                  if (patterns != null) {
                    setState(() {
                      _patterns = patterns;
                    });
                  }
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Config'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mammoth Controller'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final patterns = await Navigator.push<List<models.Pattern>>(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfigPage(
                    currentPatterns: _patterns,
                    onPatternsUpdated: _updatePatterns,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
              if (patterns != null) {
                setState(() {
                  _patterns = patterns;
                });
              }
              _loadBaseUrl();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PatternSelector(patterns: _patterns),
          ),
          ConnectionStatusBar(baseUrl: _baseUrl),
        ],
      ),
    );
  }

  void _updatePatterns(List<models.Pattern> patterns) {
    setState(() {
      _patterns = patterns;
    });
  }
}