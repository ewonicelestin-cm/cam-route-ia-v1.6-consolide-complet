import '../models/app_data.dart';

class AiRoadAnalysis {
  final String level;
  final int score;
  final String explanation;
  final List<String> recommendations;

  const AiRoadAnalysis({
    required this.level,
    required this.score,
    required this.explanation,
    required this.recommendations,
  });
}

class AiService {
  const AiService();

  AiRoadAnalysis analyzeRoads(List<RoadObservation> roads) {
    if (roads.isEmpty) {
      return const AiRoadAnalysis(
        level: 'Données insuffisantes',
        score: 0,
        explanation: 'Aucune observation routière enregistrée. L’analyse IA ne fabrique pas de données.',
        recommendations: ['Effectuer des observations terrain sur les axes étudiés.'],
      );
    }

    final bad = roads.where((r) => r.condition.toLowerCase() == 'mauvais').length;
    final medium = roads.where((r) => r.condition.toLowerCase() == 'moyen').length;
    final score = ((bad * 100 + medium * 50) / roads.length).round();

    final level = score >= 60 ? 'Vigilance élevée' : score >= 30 ? 'Vigilance modérée' : 'Vigilance faible';
    final recommendations = <String>[];
    if (bad > 0) recommendations.add('Prioriser la vérification des segments signalés comme mauvais.');
    if (medium > 0) recommendations.add('Contrôler l’évolution des segments classés moyens.');
    recommendations.add('Confirmer toute décision avec une inspection terrain récente.');

    return AiRoadAnalysis(
      level: level,
      score: score,
      explanation: '$bad observation(s) mauvaise(s), $medium moyenne(s), sur ${roads.length} observation(s).',
      recommendations: recommendations,
    );
  }

  String summarizeNetwork(List<NetworkMeasurement> measurements) {
    if (measurements.isEmpty) return 'Aucune mesure réseau enregistrée.';
    final known = measurements.where((m) => m.signalStrength != null).length;
    return '${measurements.length} observation(s) réseau enregistrée(s). $known mesure(s) de signal réellement renseignée(s).';
  }
}
