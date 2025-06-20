import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant.dart';

class PlantService {
  static const String _plantsKey = 'user_plants';

  static Future<List<Plant>> getPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final plantsJson = prefs.getStringList(_plantsKey) ?? [];
    
    return plantsJson.map((plantJson) {
      final Map<String, dynamic> plantMap = json.decode(plantJson);
      return Plant.fromJson(plantMap);
    }).toList();
  }

  static Future<void> savePlant(Plant plant) async {
    final plants = await getPlants();
    final existingIndex = plants.indexWhere((p) => p.id == plant.id);
    
    if (existingIndex >= 0) {
      plants[existingIndex] = plant;
    } else {
      plants.add(plant);
    }
    
    await _savePlants(plants);
  }

  static Future<void> deletePlant(String plantId) async {
    final plants = await getPlants();
    plants.removeWhere((plant) => plant.id == plantId);
    await _savePlants(plants);
  }

  static Future<void> _savePlants(List<Plant> plants) async {
    final prefs = await SharedPreferences.getInstance();
    final plantsJson = plants.map((plant) => json.encode(plant.toJson())).toList();
    await prefs.setStringList(_plantsKey, plantsJson);
  }

  static Future<List<String>> getSupportedPlants() async {
    try {
      // In a real app, you would load from assets
      // For now, return a hardcoded list
      return [
        'Apple', 'Banana', 'Cherry', 'Corn', 'Grape', 'Peach', 'Pepper', 'Potato', 
        'Strawberry', 'Tomato', 'Rose', 'Sunflower', 'Tulip', 'Lily', 'Orchid', 
        'Mint', 'Basil', 'Rosemary', 'Thyme', 'Parsley', 'Aloe Vera', 'Snake Plant', 
        'Peace Lily', 'Rubber Plant', 'Fiddle Leaf Fig', 'Monstera', 'Pothos', 
        'Philodendron', 'Spider Plant', 'ZZ Plant'
      ];
    } catch (e) {
      return [];
    }
  }

  static Map<String, String> getPlantCareGuide(String plantName) {
    // Simplified care guide - in a real app, this would come from a database
    final guides = {
      'Tomato': {
        'watering': 'Water deeply 1-2 times per week. Soil should be moist but not waterlogged.',
        'sunlight': 'Requires 6-8 hours of direct sunlight daily.',
        'temperature': 'Optimal temperature range: 65-75°F (18-24°C).',
        'soil': 'Well-draining, fertile soil with pH 6.0-6.8.',
        'fertilizing': 'Feed with balanced fertilizer every 2-3 weeks during growing season.',
        'pruning': 'Remove suckers and lower leaves regularly. Prune diseased or damaged parts.',
        'common_issues': 'Watch for blight, aphids, and whiteflies. Ensure good air circulation.',
      },
      'Rose': {
        'watering': 'Water at soil level to avoid wetting leaves. Deep watering 2-3 times per week.',
        'sunlight': 'Needs at least 6 hours of morning sunlight.',
        'temperature': 'Hardy in zones 3-9, depending on variety.',
        'soil': 'Rich, well-draining soil with pH 6.0-7.0.',
        'fertilizing': 'Feed with rose fertilizer in spring and mid-summer.',
        'pruning': 'Prune in late winter/early spring. Remove dead, diseased, or weak canes.',
        'common_issues': 'Prone to black spot, powdery mildew, and aphids.',
      },
      'Basil': {
        'watering': 'Keep soil consistently moist but not waterlogged.',
        'sunlight': 'Requires 6-8 hours of direct sunlight.',
        'temperature': 'Prefers warm temperatures above 60°F (15°C).',
        'soil': 'Well-draining, fertile soil with pH 6.0-7.0.',
        'fertilizing': 'Light feeding every 2-3 weeks with balanced fertilizer.',
        'pruning': 'Pinch flowers to encourage leaf growth. Harvest regularly.',
        'common_issues': 'Watch for aphids, spider mites, and fungal diseases.',
      },
    };

    return guides[plantName] ?? {
      'watering': 'Water when top inch of soil is dry.',
      'sunlight': 'Provide bright, indirect light.',
      'temperature': 'Maintain moderate temperatures.',
      'soil': 'Use well-draining potting mix.',
      'fertilizing': 'Feed monthly during growing season.',
      'pruning': 'Remove dead or damaged parts as needed.',
      'common_issues': 'Monitor for pests and diseases regularly.',
    };
  }
}