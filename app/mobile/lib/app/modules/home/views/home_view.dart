import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Center(
        child: Obx(() => Text(
          'Count: ${controller.count}',
          style: const TextStyle(fontSize: 20),
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        tooltip: 'Increment count',
        child: const Icon(
          Icons.add,
          semanticLabel: 'Add one',
        ),
      ),
    );
  }
}
