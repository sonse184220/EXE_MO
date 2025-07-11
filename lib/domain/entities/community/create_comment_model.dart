import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CreateCommentModel {
  final String postId;
  final String? replyToCommentId;
  final String content;
  final List<File>? images;

  CreateCommentModel({
    required this.postId,
    this.replyToCommentId,
    required this.content,
    this.images,
  });

  Future<FormData> toFormData() async {
    final formData = FormData.fromMap({
      'postId': postId,
      if (replyToCommentId != null) 'replyToCommentId': replyToCommentId,
      'content': content,
    });

    if (images != null && images!.isNotEmpty) {
      for (final file in images!) {
        final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              file.path,
              contentType: MediaType.parse(mimeType),
            ),
          ),
        );
      }
    }

    return formData;
  }
}
