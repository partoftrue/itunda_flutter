import 'package:flutter/material.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final services = [
      {'icon': Icons.home, 'label': '홈'},
      {'icon': Icons.people, 'label': '동네생활'},
      {'icon': Icons.storefront, 'label': '동네마켓'},
      {'icon': Icons.fastfood, 'label': '이츠'},
      {'icon': Icons.shopping_bag, 'label': '쇼핑'},
      {'icon': Icons.chat_bubble, 'label': '동네톡'},
      {'icon': Icons.work, 'label': '동네알바'},
      // Add more services as needed
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 서비스'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.85,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return GestureDetector(
              onTap: () {
                // TODO: Navigate to the corresponding service screen
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                    child: Icon(
                      service['icon'] as IconData,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service['label'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
