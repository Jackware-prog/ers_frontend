import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Shared Emergency Configuration Map
final Map<String, Map<String, dynamic>> emergencyConfig = {
  // Natural Disasters
  'Fire': {'icon': FontAwesomeIcons.fire},
  'Flood': {'icon': FontAwesomeIcons.water},
  'Landslide': {'icon': FontAwesomeIcons.mountain},
  'Earthquake': {'icon': FontAwesomeIcons.houseCrack},
  'Tornado': {'icon': FontAwesomeIcons.wind},
  'Drought': {'icon': FontAwesomeIcons.sun},
  'Storm': {'icon': FontAwesomeIcons.cloudShowersHeavy},
  'Tsunami': {'icon': FontAwesomeIcons.waterLadder},

  // Public Safety Emergencies
  'Road Accident': {'icon': FontAwesomeIcons.carBurst},
  'Crime': {'icon': FontAwesomeIcons.gavel},
  'Terrorism Threat': {'icon': FontAwesomeIcons.shieldHalved},
  'Human Stampede': {'icon': FontAwesomeIcons.personRunning},

  // Health-Related Emergencies
  'Medical Emergency': {'icon': FontAwesomeIcons.kitMedical},
  'Food Poisoning': {'icon': FontAwesomeIcons.utensils},
  'Disease Outbreak': {'icon': FontAwesomeIcons.virus},
  'Drug Overdose': {'icon': FontAwesomeIcons.pills},

  // Industrial and Man-Made Disasters
  'Building Collapse': {'icon': FontAwesomeIcons.buildingCircleExclamation},
  'Industrial Accident': {'icon': FontAwesomeIcons.industry},
  'Fire Hazard': {'icon': FontAwesomeIcons.fireExtinguisher},
  'Explosion': {'icon': FontAwesomeIcons.bomb},
  'Hazardous Materials': {'icon': FontAwesomeIcons.skullCrossbones},

  // Environmental and Wildlife-Related Emergencies
  'Human-Wildlife Conflict': {'icon': FontAwesomeIcons.paw},
  'Forest Fire': {'icon': FontAwesomeIcons.tree},
  'Toxic Algae Bloom': {'icon': FontAwesomeIcons.waterLadder},

  // Water-Related Emergencies
  'Drowning': {'icon': FontAwesomeIcons.personSwimming},
  'Dam Failure': {'icon': FontAwesomeIcons.dropletSlash},

  // Search and Rescue Operations
  'Missing Person': {'icon': FontAwesomeIcons.personCircleExclamation},
  'Mountain Rescue': {'icon': FontAwesomeIcons.mountainCity},
  'Jungle Rescue': {'icon': FontAwesomeIcons.leaf},

  // Rare but Notable Emergencies
  'Aircraft Incident': {'icon': FontAwesomeIcons.plane},
  'Train Derailment': {'icon': FontAwesomeIcons.train},
  'Maritime Emergency': {'icon': FontAwesomeIcons.anchor},
  'Oil Rig Accident': {'icon': FontAwesomeIcons.oilWell},

  // Environmental and Air Quality
  'Haze and Air Pollution': {'icon': FontAwesomeIcons.smog},

  // Default
  'Default': {'icon': FontAwesomeIcons.circleInfo},
};
