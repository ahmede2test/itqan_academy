

import '../../../../courses/data/models/PostModel.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostSuccess extends PostState {
  final List<PostModel> posts;
  PostSuccess(this.posts);
}

class PostError extends PostState {
  final String message;
  PostError(this.message);
}
