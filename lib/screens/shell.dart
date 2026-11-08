import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ecosolar/core/theme.dart';
import 'package:ecosolar/widgets/ui.dart';
import 'package:ecosolar/screens/home.dart';
import 'package:ecosolar/screens/consumption.dart';
import 'package:ecosolar/screens/plant.dart';
import 'package:ecosolar/screens/revenue.dart';
import 'package:ecosolar/screens/market.dart';
import 'package:ecosolar/screens/profile.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  static final tab = ValueNotifier<int>(0);
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const tabs = [
    (Icons.home_outlined, 'خانه'),
    (Icons.thermostat_outlined, 'مصرف'),
    (Icons.solar_power_outlined, 'نیروگاه'),
    (Icons.account_balance_wallet_outlined, 'درآمد'),
    (Icons.storefront_outlined, 'بازارگاه'),
    (Icons.person_outline, 'پروفایل'),
  ];
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: MainShell.tab,
        builder: (_, i, __) => PopScope(
          canPop: i == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) MainShell.tab.value = 0;
          },
          child: Scaffold(
            extendBody: true,
            body: IndexedStack(index: i, children: const [HomeTab(), ConsumptionTab(), PlantTab(), RevenueTab(), MarketTab(), ProfileTab()]),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      height: 66,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.86),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: C.line),
                        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 30, offset: Offset(0, 10))],
                      ),
                      child: Row(children: [
                        for (var k = 0; k < tabs.length; k++)
                          Expanded(
                            flex: k == i ? 2 : 1,
                            child: GestureDetector(
                              onTap: () => MainShell.tab.value = k,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                height: 48,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(color: k == i ? C.black : Colors.transparent, borderRadius: BorderRadius.circular(24)),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(tabs[k].$1, color: k == i ? Colors.white : C.ink, size: 23),
                                  if (k == i) ...[
                                    const SizedBox(width: 6),
                                    Flexible(child: Text(tabs[k].$2, overflow: TextOverflow.fade, softWrap: false, style: ts(12.5, w: FontWeight.w700, c: Colors.white))),
                                  ],
                                ]),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Scrollable tab body with header (title + bell) and room for the floating nav bar
class TabBody extends StatelessWidget {
  final Widget header;
  final List<Widget> children;
  const TabBody({super.key, required this.header, required this.children});
  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [header, gap16, for (final w in children) Padding(padding: const EdgeInsets.only(bottom: 16), child: w)],
        ),
      );
}
