import 'package:flutter/material.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/places_controller.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/widgets/filter_widgets.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/widgets/place_card.dart';

class PlacesListScreen extends StatelessWidget {
  const PlacesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PlacesController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis lugares')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: PlaceSearchField(),
          ),
          const CategoryFilterBar(),
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => _buildBody(context, controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlacesController controller) {
    if (controller.loading && controller.all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null && controller.all.isEmpty) {
      return _Message(
        icon: Icons.wifi_off,
        text: controller.error!,
        actionLabel: 'Reintentar',
        onAction: controller.load,
      );
    }

    final places = controller.filtered;

    if (places.isEmpty) {
      return _Message(
        icon: Icons.location_off_outlined,
        text: controller.all.isEmpty
            ? 'Aún no tienes lugares guardados.\nToca «Nuevo lugar» para agregar el primero.'
            : 'No se encontraron lugares con ese criterio.',
      );
    }

    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: places.length,
        itemBuilder: (_, i) => PlaceCard(place: places[i]),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}