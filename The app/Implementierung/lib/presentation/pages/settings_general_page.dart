/// Simple settings page, mainly for connectivity settings
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/settings_provider.dart';
import '../../models/setting.dart';

@RoutePage()
class SettingsGeneralPage extends StatelessWidget {
  const SettingsGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Text(
          "Some settings may require a restart of the application to take effect"),
      _SettingsForm(),
    ]);
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm();

  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final allSettingIds = ref.watch(settingIdsProvider).toList();
    return Column(children: [
      Form(
          key: _formKey,
          child: Table(
            children: allSettingIds
                .map((settingId) =>
                    _createTableRow(settingId: settingId, ref: ref))
                .toList(),
          )),
      ElevatedButton(
        onPressed: () {
          // Validate returns true if the form is valid, or false otherwise.
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
          }
        },
        child: const Text('Save'),
      ),
    ]);
  }

  TableRow _createTableRow(
      {required String settingId, required WidgetRef ref}) {
    final settingAsync = ref.watch(settingsProvider(settingId));

    return settingAsync.when(
        data: (setting) => TableRow(children: [
              Text(setting!.title),
              switch (setting) {
                SettingString() => TextFormField(
                    initialValue: setting.dynamicValue.toString(),
                    obscureText: setting.secret,
                    decoration: const InputDecoration(hintText: 'Edit value'),
                    onSaved: (newValue) {
                      ref
                          .read(settingsProvider(settingId).notifier)
                          .setData(newValue);
                    },
                  ),
                SettingInteger() => TextFormField(
                    initialValue: setting.dynamicValue.toString(),
                    keyboardType: TextInputType.number,
                    obscureText:
                        setting.secret, // Mask input if it's a secret setting
                    decoration: const InputDecoration(hintText: 'Edit value'),
                    onSaved: (newValue) {
                      final parsedValue =
                          newValue != null ? int.tryParse(newValue) : null;
                      if (parsedValue != null) {
                        ref
                            .read(settingsProvider(settingId).notifier)
                            .setData(parsedValue);
                      }
                    },
                  )
              }
            ]),
        error: (e, st) => TableRow(children: [
              Text("Setting $settingId could not be loaded: $e"),
              Container()
            ]),
        loading: () => TableRow(
            children: [const CircularProgressIndicator(), Container()]));
  }
}
