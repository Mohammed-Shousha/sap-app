import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sap/screens/start.dart';
import 'package:sap/utils/constants.dart';
import 'package:sap/utils/palette.dart';
import 'package:sap/widgets/gradient_scaffold.dart';
import 'package:sap/widgets/custom_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: Constants.welcomeData.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Welcome to SAP'),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(
          child: TabBarView(
            physics: const BouncingScrollPhysics(),
            controller: _controller,
            children: [
              for (final data in Constants.welcomeData)
                WelcomeWidget(
                  message: data['message'],
                  image: data['image'],
                  subMessage: data['subMessage'],
                  isLastPage: data['isLastPage'] ?? false,
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TabPageSelector(
          controller: _controller,
          color: Colors.grey,
          selectedColor: Palette.primary,
          borderStyle: BorderStyle.none,
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class WelcomeWidget extends StatelessWidget {
  final String message;
  final String image;
  final String subMessage;
  final bool isLastPage;

  const WelcomeWidget({
    super.key,
    required this.message,
    required this.image,
    required this.subMessage,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          image,
          width: 300,
          height: 300,
        ),
        const SizedBox(height: 20),
        Text(
          message,
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          subMessage,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        if (isLastPage)
          CustomButton(
            text: 'Get Started',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const StartScreen(),
                ),
              );
            },
          ),
      ],
    );
  }
}
