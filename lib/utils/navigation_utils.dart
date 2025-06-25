import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../screens/plant_chat_screen.dart';

class NavigationUtils {
  /// Opens the plant chat screen with the given plant
  static void openPlantChat(BuildContext context, Plant plant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantChatScreen(plant: plant),
      ),
    );
  }

  /// Opens the general plant chat with a generic plant object
  static void openGeneralPlantChat(BuildContext context) {
    final generalPlant = Plant(
      id: 'general_chat',
      name: 'General Plant Care',
      plantType: 'General',
      imagePaths: [],
      dateAdded: DateTime.now(),
    );
    
    openPlantChat(context, generalPlant);
  }
}