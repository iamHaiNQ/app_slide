import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lap26_3/model/Slide.dart';
import 'package:lap26_3/widget/slide_widget.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Slide> slides = [];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    loadSlides();
  }

  Future<void> loadSlides() async {
    try {
      String jsonString = await rootBundle.loadString('assets/testImageRange.json');
      List<dynamic> jsonData = jsonDecode(jsonString);
      setState(() {
        slides = jsonData.map((json) => Slide.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error loading slides: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextSlide() {
    if (_pageController.hasClients &&
        _pageController.page! < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void returnSlide() {
    if (_pageController.hasClients && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: slides.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    return SlideWidget(
                      slide: slides[index],
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: ElevatedButton(
                    onPressed: returnSlide,
                    child: const Text('Return Slide'),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: nextSlide,
                    child: const Text('Next Slide'),
                  ),
                ),
              ],
            ),
    );
  }
}
