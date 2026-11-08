import 'package:flutter/material.dart';
import 'package:ecosolar/screens/auth.dart';
import 'package:ecosolar/screens/onboarding.dart';
import 'package:ecosolar/screens/wizard.dart';
import 'package:ecosolar/screens/shell.dart';
import 'package:ecosolar/screens/home.dart';
import 'package:ecosolar/screens/plant.dart';
import 'package:ecosolar/screens/plant2.dart';
import 'package:ecosolar/screens/plant3.dart';
import 'package:ecosolar/screens/revenue.dart';
import 'package:ecosolar/screens/revenue2.dart';
import 'package:ecosolar/screens/market.dart';
import 'package:ecosolar/screens/market2.dart';
import 'package:ecosolar/screens/profile.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (_) => const LoginScreen(), // SCR-C-01
  '/onboarding/kyc': (_) => const KycScreen(), // SCR-C-02
  '/onboarding/organization': (_) => const OrgScreen(), // SCR-C-03
  '/onboarding/consents': (_) => const ConsentsScreen(), // SCR-C-04
  '/onboarding/profile': (_) => const WizardScreen(), // SCR-C-05
  '/home': (_) => const MainShell(), // tabs: SCR-C-10, 20, 30, 40, 50, 60
  '/plant/design': (_) => const DesignScreen(), // SCR-C-31
  '/plant/battery': (_) => const BatteryScreen(), // SCR-C-32
  '/plant/channels': (_) => const ChannelsScreen(), // SCR-C-33
  '/plant/contract': (_) => const ContractScreen(), // SCR-C-34
  '/plant/case': (_) => const CaseScreen(), // SCR-C-35
  '/plant/monitoring': (_) => const MonitoringScreen(), // SCR-C-36
  '/plant/reconciliation': (_) => const ReconScreen(), // SCR-C-37
  '/plant/maintenance': (_) => const MaintenanceScreen(), // SCR-C-38
  '/revenue/invoices': (_) => const InvoicesScreen(), // SCR-C-41
  '/revenue/advance': (_) => const AdvanceScreen(), // SCR-C-42
  '/finance/simulator': (_) => const SimulatorScreen(), // SCR-C-43
  '/wallet': (_) => const WalletScreen(), // SCR-C-44
  '/revenue/loan': (_) => const LoanScreen(), // SCR-C-45
  '/market/equipment': (_) => const EquipmentScreen(), // SCR-C-51
  '/market/installers': (_) => const InstallersScreen(), // SCR-C-52
  '/market/finance': (_) => const FinanceScreen(), // SCR-C-53
  '/market/roof-host': (_) => const RoofHostScreen(), // SCR-C-54
  '/site/co-owners': (_) => const CoOwnersScreen(), // SCR-C-55
  '/market/vpp': (_) => const VppScreen(), // SCR-C-56
  '/plant/channel-review': (_) => const ChannelReviewScreen(), // SCR-C-61
  '/notifications': (_) => const NotificationsScreen(), // SCR-C-62
  '/support': (_) => const SupportScreen(), // SCR-C-63
};
