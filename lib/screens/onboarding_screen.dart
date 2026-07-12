import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/grove_card.dart';
import '../widgets/oak_tree.dart';

/// SCREEN 1 — ONBOARDING. Welcome -> profile & baseline biometrics ->
/// seedling planted. Fields are pre-filled with demo defaults so a live
/// walkthrough takes seconds.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();

  static const _departments = [
    'Department of Public Works',
    'Police Department',
    'Administration',
    'Fire Department',
  ];

  // Demo-friendly defaults (Alex Johnson, City of Rockford).
  final _name = TextEditingController(text: 'Alex Johnson');
  final _employer = TextEditingController(text: 'City of Rockford');
  final _heightFt = TextEditingController(text: '5');
  final _heightIn = TextEditingController(text: '10');
  final _weight = TextEditingController(text: '196');
  final _systolic = TextEditingController(text: '128');
  final _diastolic = TextEditingController(text: '84');
  final _restingHr = TextEditingController(text: '74');
  String _department = _departments.first;

  UserProfile? _pendingProfile;

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in [
      _name,
      _employer,
      _heightFt,
      _heightIn,
      _weight,
      _systolic,
      _diastolic,
      _restingHr
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _goTo(int page) {
    _pageCtrl.animateToPage(page,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic);
  }

  /// Builds the profile from the form (forgiving parsing with sensible
  /// fallbacks — this is a prototype, not a clinical intake form).
  void _submitForm() {
    final ft = int.tryParse(_heightFt.text) ?? 5;
    final inches = int.tryParse(_heightIn.text) ?? 10;
    _pendingProfile = UserProfile(
      name: _name.text.trim().isEmpty ? 'Alex Johnson' : _name.text.trim(),
      department: _department,
      employer:
          _employer.text.trim().isEmpty ? 'City of Rockford' : _employer.text.trim(),
      heightInches: (ft * 12 + inches).toDouble(),
      weightLbs: double.tryParse(_weight.text) ?? 196,
      systolic: int.tryParse(_systolic.text) ?? 128,
      diastolic: int.tryParse(_diastolic.text) ?? 84,
      restingHeartRate: int.tryParse(_restingHr.text) ?? 74,
      joinedAt: DateTime.now(),
    );
    setState(() {});
    _goTo(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _welcomePage(),
            _formPage(),
            _plantedPage(),
          ],
        ),
      ),
    );
  }

  // ---- page 1: brand welcome ----
  Widget _welcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          const Text(
            'In Partnership With',
            style: TextStyle(
                fontSize: 11,
                color: GroveColors.textMuted,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Image.asset('assets/images/cor_logo_transparent.png', height: 54),
          const SizedBox(height: 20),
          const SizedBox(
              height: 150, width: 150, child: OakTreeView(growth: 0.9, sway: true)),
          const SizedBox(height: 18),
          Text('GROVE',
              style: groveSerif(size: 42, letterSpacing: 10)),
          const SizedBox(height: 10),
          const Text(
            'Grow your health.\nGrow your community.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, color: GroveColors.green, height: 1.5),
          ),
          const SizedBox(height: 16),
          // Path to Wellness integration banner (V2.0)
          const GroveCard(
            color: GroveColors.goldSoft,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.savings, color: GroveColors.forest, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Grove tracks your Path to Wellness points automatically — earn your premium discount while growing your tree.',
                    style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: GroveColors.forest),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _goTo(1),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }

  // ---- page 2: profile + baseline biometrics ----
  Widget _formPage() {
    InputDecoration deco(String label, {String? suffix}) => InputDecoration(
          labelText: label,
          suffixText: suffix,
          filled: true,
          fillColor: GroveColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Text('Plant your tree', style: groveSerif(size: 28)),
        const SizedBox(height: 6),
        const Text(
          'Tell us who you are and where you\'re starting from. Your baseline is how Grove measures your growth.',
          style: TextStyle(color: GroveColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 22),
        TextField(controller: _name, decoration: deco('Full name')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _department,
          decoration: deco('Department'),
          items: _departments
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (v) => setState(() => _department = v ?? _department),
        ),
        const SizedBox(height: 12),
        TextField(controller: _employer, decoration: deco('Employer')),
        const SizedBox(height: 24),
        Text('Baseline biometrics', style: groveSerif(size: 19)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: _heightFt,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: deco('Height', suffix: 'ft'))),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
                  controller: _heightIn,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: deco('', suffix: 'in'))),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
                  controller: _weight,
                  keyboardType: TextInputType.number,
                  decoration: deco('Weight', suffix: 'lb'))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: _systolic,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: deco('BP systolic'))),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
                  controller: _diastolic,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: deco('BP diastolic'))),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
                  controller: _restingHr,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: deco('Resting HR'))),
        ]),
        const SizedBox(height: 26),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('Plant My Seedling'),
        ),
        TextButton(
          onPressed: () => _goTo(0),
          child: const Text('Back',
              style: TextStyle(color: GroveColors.textMuted)),
        ),
      ],
    );
  }

  // ---- page 3: the freshly planted seedling ----
  Widget _plantedPage() {
    final firstName = _pendingProfile?.firstName ?? 'friend';
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          Text('Welcome, $firstName', style: groveSerif(size: 30)),
          const SizedBox(height: 8),
          const Text(
            'Your oak has been planted.',
            style: TextStyle(fontSize: 15, color: GroveColors.green),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            height: 240,
            width: 220,
            child: OakTreeView(
              growth: 0.07,
              animateFrom: 0.0,
              duration: Duration(milliseconds: 2000),
              sway: true,
            ),
          ),
          const SizedBox(height: 20),
          const GroveCard(
            child: Text(
              'Every activity you log helps it grow — through Seedling, Sapling, Young Tree, and Mature Tree, all the way to a Full Oak.\n\nWe\'ve imported a sample week of activity so you can explore your grove right away.',
              style: TextStyle(
                  fontSize: 13, color: GroveColors.textMuted, height: 1.5),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final p = _pendingProfile;
                if (p != null) {
                  context.read<AppState>().completeOnboarding(p);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GroveColors.gold,
                foregroundColor: GroveColors.forest,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              child: const Text('Enter My Grove'),
            ),
          ),
        ],
      ),
    );
  }
}
