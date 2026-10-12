import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const DashboardCard(
      {super.key,
      required this.title,
      required this.value,
      required this.icon});
  @override
  Widget build(BuildContext c) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Icon(icon, size: 34, color: Theme.of(c).colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(c).textTheme.headlineSmall)
                ]))
          ])));
}
