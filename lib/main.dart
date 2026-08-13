// DO NOT TRUNCATE - full file below
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CyberpunkApp());
}

class CyberpunkApp extends StatelessWidget {
  const CyberpunkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Courier New as the app-wide font (platform fallback applies if not available)
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SBR BioForge - Cyberpunk AI',
      theme: ThemeData(
        // cyberpunk-styled base: dark background is set on Scaffold directly per requirement
        fontFamily: 'Courier New',
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dropdown, values '1'..'5'
  String _selectedPromptKey = '1';

  // Controller for user input
  final TextEditingController userInputController = TextEditingController();

  // Displayed AI response (or error)
  String aiResponse = '';

  // Loading state
  bool isLoading = false;

  // Error flag for bright red terminal display
  bool hasError = false;

  // Hard-coded prompts placeholders mapped 1-5
  final Map<String, String> systemPrompts = {
    '1': '<HEALTH_PREDICTOR_PROMPT>',
    '2': '<DIGITAL_LEGACY_PROMPT>',
    '3': '<ECO_TRACKER_PROMPT>',
    '4': '<SKILLS_COACH_PROMPT>',
    '5': '<TECH_SHIELD_PROMPT>',
  };

  // Fixed model and temperature per HARD-LOCKED CONFIG
  static const String _model = 'llama-3.3-70b-versatile';
  static const double _temperature = 0.3;

  // HTTP endpoint per instruction
  static const String _apiUrl = 'https://groq.com';

  @override
  void dispose() {
    userInputController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final String userInput = userInputController.text.trim();

    // Basic UX guard
    if (userInput.isEmpty) {
      setState(() {
        aiResponse = 'Please enter a prompt before sending.';
        hasError = true;
      });
      return;
    }

    final String systemPrompt = systemPrompts[_selectedPromptKey] ?? '';

    setState(() {
      isLoading = true;
      hasError = false;
      aiResponse = 'Sending request...';
    });

    try {
      // Build request body exactly as required, including frozen model & temperature
      final Map<String, dynamic> body = {
        'model': _model,
        'temperature': _temperature,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userInput},
        ],
      };

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Strict RESPONSE PARSING: use the exact path required
      // jsonDecode(response.body)['choices'][0]['message']['content']
      String parsed = '';

      // Validate success status; still attempt parse even if non-200 to produce helpful info
      try {
        final decoded = jsonDecode(response.body);
        // IMPORTANT: Directly follow the requested extraction path
        parsed = decoded['choices'][0]['message']['content']?.toString() ?? '';
      } catch (parseError) {
        // If parsing failed, throw to outer catch so error is shown in bright red
        throw FormatException(
            'Failed to parse response at required path: jsonDecode(response.body)[\'choices\'][0][\'message\'][\'content\'].\nParse error: $parseError\nRaw response body: ${response.body}');
      }

      setState(() {
        aiResponse = parsed.isEmpty
            ? 'Received empty content at choices[0].message.content. Raw response: ${response.body}'
            : parsed;
        hasError = false;
      });
    } catch (e, st) {
      // ERROR MANAGEMENT: display the error message inside the terminal box in bright red
      setState(() {
        aiResponse = 'Error: ${e.toString()}';
        hasError = true;
      });
      // You may also log stack trace to console for debugging
      // ignore: avoid_print
      print('Request error: $e\n$st');
    } finally {
      // Small delay removed; finalize loading state
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC0C0C0)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPromptKey,
          dropdownColor: const Color(0xFF0B0B0B),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Courier New',
          ),
          items: const [
            DropdownMenuItem(value: '1', child: Text('1 — Health Predictor')),
            DropdownMenuItem(value: '2', child: Text('2 — Digital Legacy')),
            DropdownMenuItem(value: '3', child: Text('3 — Eco-Tracker')),
            DropdownMenuItem(value: '4', child: Text('4 — Skills Coach')),
            DropdownMenuItem(value: '5', child: Text('5 — Tech Shield')),
          ],
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _selectedPromptKey = val;
            });
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFD0D0D0),
        fontFamily: 'Courier New',
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFC0C0C0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFC0C0C0), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF020202),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildInputArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDropdown(),
        const SizedBox(height: 12),
        TextField(
          controller: userInputController,
          maxLines: 5,
          style: const TextStyle(fontFamily: 'Courier New', color: Colors.white),
          decoration: _inputDecoration('Enter prompt for selected system (1-5)'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  side: const BorderSide(color: Color(0xFFC0C0C0)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontFamily: 'Courier New'),
                ),
                onPressed: isLoading ? null : _sendRequest,
                child: isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send'),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F0F0F),
                side: const BorderSide(color: Color(0xFFC0C0C0)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                textStyle: const TextStyle(fontFamily: 'Courier New'),
              ),
              onPressed: () {
                setState(() {
                  userInputController.clear();
                  aiResponse = '';
                  hasError = false;
                });
              },
              child: const Text('Clear'),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTerminalBox() {
    return Container(
      constraints: const BoxConstraints(minHeight: 160, maxHeight: 400),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border.all(color: const Color(0xFFC0C0C0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          aiResponse.isEmpty ? '(terminal output will appear here)' : aiResponse,
          style: TextStyle(
            fontFamily: 'Courier New',
            fontSize: 14,
            color: hasError ? const Color(0xFFFF0000) : const Color(0xFFB8F4FF),
            height: 1.25,
          ),
        ),
      ),
    );
  }

  Widget _buildSystemPromptPreview() {
    final preview = systemPrompts[_selectedPromptKey] ?? '';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        border: Border.all(color: const Color(0xFFC0C0C0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SelectableText(
        preview.isEmpty ? '(no system prompt available)' : preview,
        style: const TextStyle(
          fontFamily: 'Courier New',
          fontSize: 12,
          color: Color(0xFFBFBFBF),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold with cyberpunk theme background color per requirement
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070707),
        title: const Text(
          'SBR BioForge — Cyberpunk AI Terminal',
          style: TextStyle(fontFamily: 'Courier New'),
        ),
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            // Top: input area
            _buildInputArea(),
            const SizedBox(height: 12),
            // Middle: prompt preview & terminal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'System Prompt (mapped):',
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      color: Color(0xFFBFBFBF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildSystemPromptPreview(),
                  const SizedBox(height: 12),
                  const Text(
                    'Terminal Output:',
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      color: Color(0xFFBFBFBF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(child: _buildTerminalBox()),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Footer: attribution / small helper
            const Text(
              'Model locked to llama-3.3-70b-versatile • temperature=0.3 • endpoint=https://groq.com',
              style: TextStyle(
                fontFamily: 'Courier New',
                color: Color(0xFF8A8A8A),
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }
}
