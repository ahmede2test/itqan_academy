import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'cash_helper.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(Locale(CashHelper.getData('language') ?? 'ar'));

  void changeLocale(String languageCode) {
    CashHelper.setData('language',  languageCode);
    emit(Locale(languageCode));
  }
}
