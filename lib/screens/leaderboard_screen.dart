import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'ui_shell.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const int _demoCo2SavedGrams = 248600;
  static const int _demoCompletedRides = 132;
  static const int _demoDistanceKm = 2260;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadAppCarbonOverview();
    });
  }

  static const List<_LeaderboardCategory> _categories = [
    _LeaderboardCategory(
      tabLabel: 'Top Drivers',
      entries: [
        _LeaderboardEntry(
          name: 'Avery Turner',
          university: 'Wasatch Front',
          badge: 'Road Captain',
          metric: '184 trips completed',
          icon: Icons.directions_car_filled,
          profilePhotoUrl:
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
        ),
        _LeaderboardEntry(
          name: 'Sofia Kim',
          university: 'Northern Utah',
          badge: 'Route Connector',
          metric: '161 trips completed',
          icon: Icons.route,
          profilePhotoUrl:
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
        ),
      ],
    ),
    _LeaderboardCategory(
      tabLabel: 'Top Rated',
      entries: [
        _LeaderboardEntry(
          name: 'Ethan Brooks',
          university: 'Southwest',
          badge: '5-Star Rider',
          metric: '4.98 avg rating',
          icon: Icons.star_rounded,
          profilePhotoUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        ),
        _LeaderboardEntry(
          name: 'Mia Patel',
          university: 'Mountain West',
          badge: 'Trust Favorite',
          metric: '4.96 avg rating',
          icon: Icons.workspace_premium,
          profilePhotoUrl:
              'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400',
        ),
      ],
    ),
    _LeaderboardCategory(
      tabLabel: 'Eco Leaders',
      entries: [
        _LeaderboardEntry(
          name: 'Noah Lee',
          university: 'Salt Lake Region',
          badge: 'Green Commuter',
          metric: '428 kg CO2 saved',
          icon: Icons.eco,
          profilePhotoUrl:
              'https://images.unsplash.com/photo-1504593811423-6dd665756598?w=400',
        ),
        _LeaderboardEntry(
          name: 'Grace Allen',
          university: 'High Country',
          badge: 'Planet Partner',
          metric: '401 kg CO2 saved',
          icon: Icons.nature_people,
          profilePhotoUrl:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
        ),
      ],
    ),
    _LeaderboardCategory(
      tabLabel: 'Event Champs',
      entries: [
        _LeaderboardEntry(
          name: 'Liam Carter',
          university: 'Utah County',
          badge: 'Event Run Hero',
          metric: '67 event carpools',
          icon: Icons.celebration,
          profilePhotoUrl:
              'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=400',
        ),
        _LeaderboardEntry(
          name: 'Ella Wright',
          university: 'Arizona Metro',
          badge: 'Events Pro',
          metric: '59 event carpools',
          icon: Icons.event_available,
          profilePhotoUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final overview = context.watch<AppState>().appCarbonOverview;
    final hasRealData =
        overview != null &&
        (overview.totalCo2SavedGrams > 0 ||
            overview.completedRides > 0 ||
            overview.totalDistanceKm > 0);
    final co2SavedGrams = hasRealData
        ? overview.totalCo2SavedGrams
        : _demoCo2SavedGrams;
    final completedRides = hasRealData
        ? overview.completedRides
        : _demoCompletedRides;
    final totalDistanceKm = hasRealData
        ? overview.totalDistanceKm
        : _demoDistanceKm;
    final totalKg = (co2SavedGrams / 1000).toStringAsFixed(1);

    return DefaultTabController(
      length: _categories.length,
      child: UiShell(
        title: 'Leaderboard',
        child: Column(
          children: [
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(Icons.eco, size: 28),
                title: const Text('Overall Carbon Savings'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalKg kg CO2 saved across $completedRides completed rides '
                        'and $totalDistanceKm km carpooled.',
                      ),
                      if (!hasRealData)
                        Text(
                          'Demo estimate shown until real trip data is available.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _categories
                  .map((category) => Tab(text: category.tabLabel))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                children: _categories
                    .map(
                      (category) => ListView.separated(
                        itemCount: category.entries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = category.entries[index];
                          return _LeaderboardTile(
                            rank: index + 1,
                            entry: entry,
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.rank, required this.entry});

  final int rank;
  final _LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final imageProvider = entry.profilePhotoUrl.isEmpty
        ? null
        : NetworkImage(entry.profilePhotoUrl);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundImage: imageProvider,
          child: imageProvider == null ? const Icon(Icons.person) : null,
        ),
        title: Text('#$rank ${entry.name}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Home base: ${entry.university}'),
              Text('Badge: ${entry.badge}'),
              Text('Metric: ${entry.metric}'),
            ],
          ),
        ),
        trailing: Icon(entry.icon),
      ),
    );
  }
}

class _LeaderboardCategory {
  const _LeaderboardCategory({required this.tabLabel, required this.entries});

  final String tabLabel;
  final List<_LeaderboardEntry> entries;
}

class _LeaderboardEntry {
  const _LeaderboardEntry({
    required this.name,
    required this.university,
    required this.badge,
    required this.metric,
    required this.icon,
    required this.profilePhotoUrl,
  });

  final String name;
  final String university;
  final String badge;
  final String metric;
  final IconData icon;
  final String profilePhotoUrl;
}
