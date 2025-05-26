import 'dart:io';

import 'package:dio/dio.dart';

class CreateCommunityPostModel {
  final String communityPostTitle;
  final String communityPostContent;
  final File? communityPostImageFile;
  final String communityGroupId;

  CreateCommunityPostModel({
    required this.communityPostTitle,
    required this.communityPostContent,
    required this.communityPostImageFile,
    required this.communityGroupId,
  });

  /// Converts this model into `FormData` for Dio
  Future<FormData> toFormData() async {
    final Map<String, dynamic> data = {
      'communityPostTitle': communityPostTitle,
      'communityPostContent': communityPostContent,
      'communityGroupId': communityGroupId,
    };

    if (communityPostImageFile != null) {
      final fileName = communityPostImageFile!.path.split('/').last;
      data['communityPostImageFile'] = await MultipartFile.fromFile(
        communityPostImageFile!.path,
        filename: fileName,
      );
    }

    return FormData.fromMap(data);
  }
}