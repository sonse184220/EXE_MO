import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CreateCommunityPostModel {
  final String communityPostTitle;
  final String communityPostContent;
  final List<File>? communityPostImageFiles; // Nullable now
  final String communityGroupId;
  final String communityPostStatus;

  CreateCommunityPostModel({
    required this.communityPostTitle,
    required this.communityPostContent,
    required this.communityPostImageFiles,
    required this.communityGroupId,
    required this.communityPostStatus,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> data = {
      'communityPostTitle': communityPostTitle,
      'communityPostContent': communityPostContent,
      'communityGroupId': communityGroupId,
      'communityPostStatus': communityPostStatus,
    };

    if (communityPostImageFiles != null && communityPostImageFiles!.isNotEmpty) {
      final List<MultipartFile> files = [];
      for (final file in communityPostImageFiles!) {
        final filePath = file.path;
        final fileName = filePath.split('/').last;
        final mimeType = lookupMimeType(filePath);

        MediaType? mediaType;
        if (mimeType != null) {
          final parts = mimeType.split('/');
          mediaType = MediaType(parts[0], parts[1]);
        }

        files.add(
          await MultipartFile.fromFile(
            filePath,
            filename: fileName,
            contentType: mediaType,
          ),
        );
      }
      data['communityPostImageFiles'] = files;
    } else {
      // explicitly send the field with null
      data['communityPostImageFiles'] = null;
    }

    return FormData.fromMap(data);
  }
}
