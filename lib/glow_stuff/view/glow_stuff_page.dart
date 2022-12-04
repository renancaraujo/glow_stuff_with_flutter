import 'package:flutter/material.dart';
import 'package:glow_stuff_with_flutter/glow_stuff/glow_stuff.dart';

class GlowStuffPage extends StatelessWidget {
  const GlowStuffPage({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(builder: (_) => const GlowStuffPage());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GlowStuffView(),
    );
  }
}

class GlowStuffView extends StatelessWidget {
  const GlowStuffView({super.key});

  @override
  Widget build(BuildContext context) {
    return HorizontalDeviationProvider(
      child: ColoredBox(
        color: const Color(0xFF000000),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                height: 250,
              ),
            ),
            const SliverToBoxAdapter(
              child: ApplyGlow(
                density: 0.9,
                child: TextEditableExample(),
              ),
            ),
            const SliverToBoxAdapter(
              child: ApplyGlow(
                density: 0.40,
                weight: 0.2,
                child: LongTextExample(),
              ),
            ),
            const SliverToBoxAdapter(
              child: ApplyGlow(
                density: 0.9,
                weight: 0.2,
                child: ImageExample(),
              ),
            ),
            const SliverToBoxAdapter(
              child: ApplyGlow(
                density: 0.9999,
                child: RiveExample(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
