import 'package:flutter/material.dart';
import 'package:sap/screens/start.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _incrementCounter() {
    setState(() {
      (_controller.index == 3 - 1)
          ? _controller.index = 0
          : _controller.index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to our App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: const [
                WelcomeScreen(
                  message: 'Welcome to our app!',
                  color: Colors.blueGrey,
                ),
                WelcomeScreen(
                  message: 'Learn more about us!',
                  color: Colors.orange,
                ),
                WelcomeScreen(
                  message: 'Get started now!',
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TabPageSelector(
            controller: _controller,
            color: Colors.grey,
            selectedColor: Colors.green,
            borderStyle: BorderStyle.none,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _controller.index == 2
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StartScreen(),
                      ))
                  : _incrementCounter();
            },
            child: Text(_controller.index == 2 ? 'Get started' : 'Next'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final String message;
  final Color color;

  const WelcomeScreen({
    Key? key,
    required this.message,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
}
