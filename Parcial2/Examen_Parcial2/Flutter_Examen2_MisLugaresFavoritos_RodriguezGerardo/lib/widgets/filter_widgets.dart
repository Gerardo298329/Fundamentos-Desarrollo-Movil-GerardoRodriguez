import 'package:flutter/material.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/core/categories.dart';
import 'package:flutter_examen2_mislugaresfavoritos_rodriguezgerardo/services/places_controller.dart';

/// Campo de búsqueda por nombre conectado al controlador compartido.
class PlaceSearchField extends StatefulWidget {
  const PlaceSearchField({super.key});

  @override
  State<PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<PlaceSearchField> {
  final _text = TextEditingController(
    text: PlacesController.instance.query,
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _text,
      onChanged: PlacesController.instance.setQuery,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _text,
          builder: (_, value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _text.clear();
              PlacesController.instance.setQuery('');
            },
          ),
        ),
      ),
    );
  }
}

/// Barra horizontal de chips para filtrar por categoría.
class CategoryFilterBar extends StatefulWidget {
  const CategoryFilterBar({super.key});

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar> {
  // Categorías por página
  static const int _perPage = 4;

  final PageController _pageController = PageController();
  int _page = 0;

  late final List<List<PlaceCategory>> _pages = [
    for (var i = 0; i < kCategories.length; i += _perPage)
      kCategories.sublist(
        i,
        i + _perPage > kCategories.length ? kCategories.length : i + _perPage,
      ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = PlacesController.instance;
    final scheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final expanded = controller.filtersExpanded;
        final active = controller.category;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado: al tocarlo se repliega o despliega el filtro.
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: controller.toggleFilters,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_list, size: 18, color: scheme.primary),
                    const SizedBox(width: 6),
                    // Con el filtro replegado, muestra la categoría activa.
                    Text(
                      active == null ? 'Filtros' : 'Filtros · $active',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // El contenido se recorta con animación; el estado de la página
            // se conserva mientras está replegado.
            ClipRect(
              child: AnimatedAlign(
                alignment: Alignment.topCenter,
                heightFactor: expanded ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 50,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (_, index) {
                          final items = _pages[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _FilterTile(
                                    label: 'Todas',
                                    icon: Icons.apps,
                                    color: scheme.primary,
                                    selected: controller.category == null,
                                    onTap: () => controller.setCategory(null),
                                  ),
                                ),
                                for (final c in items)
                                  Expanded(
                                    child: _FilterTile(
                                      label: c.name,
                                      icon: c.icon,
                                      color: c.color,
                                      selected: controller.category == c.name,
                                      onTap: () => controller.setCategory(
                                        controller.category == c.name
                                            ? null
                                            : c.name,
                                      ),
                                    ),
                                  ),
                                // Relleno para mantener el ancho en páginas incompletas.
                                for (var i = items.length; i < _perPage; i++)
                                  const Expanded(child: SizedBox()),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _pages.length; i++)
                        // Cursor de mano al pasar sobre el indicador (web y escritorio).
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _pageController.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              ),
                              // Área táctil amplia alrededor de cada punto.
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 6,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: _page == i ? 30 : 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _page == i
                                        ? scheme.primary
                                        : scheme.outlineVariant,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Botón de filtro con icono sobre el texto.
class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(14);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.18)
            : scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(height: 3),
                // Reduce el texto solo si no cabe (por ejemplo "Naturaleza").
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
