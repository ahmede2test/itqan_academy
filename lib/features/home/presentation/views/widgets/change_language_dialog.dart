import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/core/utils/locale_cubit.dart';
import 'package:itqan_academy/generated/l10n.dart';

void showChangeLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(S.of(context).changeLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text(
              "العربية",
              style: TextStyle(
                fontFamily: 'cairo',
              ),
            ),
            onTap: () {
              context.read<LocaleCubit>().changeLocale('ar');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("English",
                style: TextStyle(
                  fontFamily: 'cairo',
                )),
            onTap: () {
              context.read<LocaleCubit>().changeLocale('en');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
