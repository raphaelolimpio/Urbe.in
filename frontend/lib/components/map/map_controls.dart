import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onResetNorth;
  final VoidCallback onRecenter;

  const MapControls({
    super.key,
    required this.onResetNorth,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MapButton(
          icon: Icons.explore,
          tooltip: "Resetar Norte",
          onPressed: onResetNorth,
        ),
        const SizedBox(height: 8),

        _MapButton(
          icon: Icons.my_location,
          tooltip: "Voltar para o Imóvel",
          onPressed: onRecenter,
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _MapButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
