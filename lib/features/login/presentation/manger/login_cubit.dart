import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/features/login/data/models/login_model.dart';
import 'package:itqan_academy/core/utils/cash_helper.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  static LoginCubit get(context) {
    return BlocProvider.of(context);
  }

  Future<void> login({required String email, required String password}) async {
    try {
      emit(LoginLoading());

      // 🔄 Supabase Authentication Call
      final AuthResponse response = await Supabase.instance.client.auth
          .signInWithPassword(
            email: email,
            password: password,
          )
          .timeout(const Duration(seconds: 20));

      // Check for successful authentication (user object is present)
      if (response.user != null) {
        // 🚀 CRITICAL: SAVE SESSION in shared_preferences
        await CashHelper.setData('isLoggedIn', true);
        await CashHelper.setData('token', response.session?.accessToken);

        emit(LoginSuccess(
          loginModel: LoginModel.fromSupabase(response),
        ));
      } else {
        emit(LoginFailure(
            errMessage:
                'Authentication failed. Please check your credentials.'));
      }
    } on AuthException catch (e) {
      emit(LoginFailure(errMessage: e.message));
    } on TimeoutException catch (_) {
      emit(LoginFailure(errMessage: 'Connection timeout. Please try again.'));
    } catch (e) {
      emit(LoginFailure(errMessage: e.toString()));
    }
  }
}
