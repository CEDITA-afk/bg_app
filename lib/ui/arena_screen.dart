import 'package:flutter/material.dart';
import 'widgets/monster_widget.dart';
import 'widgets/log_widget.dart';
import 'widgets/wizard_widget.dart';

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            const MonsterWidget(),
            const LogWidget(),
            Expanded(
              child: PageView( // Permette di scorrere tra i vari maghi
                children: [
                  const WizardZoneWidget(wizardIndex: 0),
                  // Se hai più maghi, verranno aggiunti qui
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}