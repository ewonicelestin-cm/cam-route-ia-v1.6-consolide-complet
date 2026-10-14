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

class PredictiveAlert {
  final String title;
  final String description;
  final String source;
  final String uncertainty;
  final DateTime timestamp;
  final Duration validityWindow;

  const PredictiveAlert({
    required this.title,
    required this.description,
    required this.source,
    required this.uncertainty,
    required this.timestamp,
    required this.validityWindow,
  });
}

class AiService {
  const AiService();

  AiRoadAnalysis analyzeRoads(List<RoadObservation> roads) {
    if (roads.isEmpty) {
      return const AiRoadAnalysis(
        level: 'Données insuffisantes',
        score: 0,
        explanation:
            'Aucune observation routière enregistrée. L’analyse IA ne fabrique pas de données.',
        recommendations: [
          'Effectuer des observations terrain sur les axes étudiés.'
        ],
      );
    }

    final bad =
        roads.where((r) => r.condition.toLowerCase() == 'mauvais').length;
    final medium =
        roads.where((r) => r.condition.toLowerCase() == 'moyen').length;
    final score = ((bad * 100 + medium * 50) / roads.length).round();

    final level = score >= 60
        ? 'Vigilance élevée'
        : score >= 30
            ? 'Vigilance modérée'
            : 'Vigilance faible';
    final recommendations = <String>[];
    if (bad > 0) {
      recommendations.add(
          'Prioriser la vérification des segments signalés comme mauvais.');
    }
    if (medium > 0) {
      recommendations.add('Contrôler l’évolution des segments classés moyens.');
    }
    recommendations
        .add('Confirmer toute décision avec une inspection terrain récente.');

    return AiRoadAnalysis(
      level: level,
      score: score,
      explanation:
          '$bad observation(s) mauvaise(s), $medium moyenne(s), sur ${roads.length} observation(s).',
      recommendations: recommendations,
    );
  }

  List<PredictiveAlert> generatePredictiveAlerts({
    required List<RoadObservation> roads,
    required List<NetworkMeasurement> networks,
    required List<CommunityIncident> incidents,
  }) {
    final alerts = <PredictiveAlert>[];
    final now = DateTime.now();

    final severeIncidents = incidents
        .where((i) =>
            i.type.contains('Inondation') || i.type.contains('Route coupée'))
        .toList();
    if (severeIncidents.isNotEmpty) {
      alerts.add(PredictiveAlert(
        title: 'Risque élevé d’impraticabilité routière',
        description:
            '${severeIncidents.length} signalement(s) récents d’inondation ou de route coupée. Risque de blocage majeur.',
        source: 'Signalements communautaires enregistrés',
        uncertainty: 'Modérée (Basée sur ${severeIncidents.length} observation(s) terrain)',
        timestamp: now,
        validityWindow: const Duration(hours: 6),
      ));
    }

    final badRoads =
        roads.where((r) => r.condition.toLowerCase() == 'mauvais').toList();
    if (badRoads.isNotEmpty) {
      alerts.add(PredictiveAlert(
        title: 'Vigilance sur axes dégradés / latérite',
        description:
            '${badRoads.length} tronçon(s) en mauvais état répertorié(s). Ralentissement fort recommandé.',
        source: 'Relevés d’observations routières locales',
        uncertainty: 'Faible (Confirmé par données terrain)',
        timestamp: now,
        validityWindow: const Duration(hours: 24),
      ));
    }

    if (alerts.isEmpty) {
      alerts.add(PredictiveAlert(
        title: 'Conditions de route nominales',
        description:
            'Aucune alerte majeure signalée sur les tronçons renseignés.',
        source: 'Synthèse des données terrain & réseau',
        uncertainty: 'Dépendante du nombre de relevés locaux',
        timestamp: now,
        validityWindow: const Duration(hours: 12),
      ));
    }

    return alerts;
  }

  String summarizeNetwork(List<NetworkMeasurement> measurements) {
    if (measurements.isEmpty) return 'Aucune mesure réseau enregistrée.';
    final known = measurements.where((m) => m.signalStrength != null).length;
    return '${measurements.length} observation(s) réseau enregistrée(s). $known mesure(s) de signal réellement renseignée(s).';
  }
}
