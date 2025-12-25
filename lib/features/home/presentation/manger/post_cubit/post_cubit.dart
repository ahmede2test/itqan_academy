import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itqan_academy/core/utils/cash_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../courses/data/models/PostModel.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  // استخدام client الخاص بسوبابيس مباشرة
  final _supabase = Supabase.instance.client;

  PostCubit() : super(PostInitial());

  static PostCubit get(context) => BlocProvider.of(context);

  Future<void> getPosts() async {
    // 1. Try to load from cache first
    final cachedData = CashHelper.getData('cached_posts');
    if (cachedData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<PostModel> cachedPosts =
            decoded.map((e) => PostModel.fromJson(e)).toList();
        emit(PostSuccess(cachedPosts));
      } catch (e) {
        emit(PostError(e.toString()));
      }
    } else {
      emit(PostLoading());
    }

    // 2. Fetch fresh data from Supabase
    try {
      final response = await _supabase
          .from('academy_news')
          .select('id, created_at, title, content, image_url, category, author')
          .order('created_at', ascending: false)
          .limit(10);

      final List<PostModel> posts =
          (response as List).map((e) => PostModel.fromJson(e)).toList();

      // Update cache
      CashHelper.setData('cached_posts', jsonEncode(response));

      emit(PostSuccess(posts));
      debugPrint("PostCubit: Fetched ${posts.length} fresh posts.");
    } catch (e) {
      if (state is! PostSuccess) {
        emit(PostError("حدث خطأ في جلب الأخبار: ${e.toString()}"));
      }
      debugPrint("PostCubit: Fetch error: $e");
    }
  }
}
