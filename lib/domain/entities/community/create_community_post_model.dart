import 'dart:io';

// import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CreateCommunityPostModel {
  final String communityPostTitle;
  final String communityPostContent;
  final File? communityPostImageFile;
  final String communityGroupId;
  final String communityPostStatus;

  CreateCommunityPostModel({
    required this.communityPostTitle,
    required this.communityPostContent,
    required this.communityPostImageFile,
    required this.communityGroupId,
    required this.communityPostStatus,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> data = {
      'communityPostTitle': communityPostTitle,
      'communityPostContent': communityPostContent,
      'communityGroupId': communityGroupId,
      'communityPostStatus': communityPostStatus, // Must be 'Active' or 'Inactive'
    };

    if (communityPostImageFile != null) {
      final filePath = communityPostImageFile!.path;
      final fileName = filePath.split('/').last;
      final mimeType = lookupMimeType(filePath);

      MediaType? mediaType;
      if (mimeType != null) {
        final parts = mimeType.split('/');
        mediaType = MediaType(parts[0], parts[1]);
      }

      data['communityPostImageFile'] = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: mediaType,
      );
    }

    return FormData.fromMap(data);
  }

  // Future<FormData> toFormData() async {
  //   return FormData.fromMap({
  //     'communityPostTitle': communityPostTitle,
  //     'communityPostContent': communityPostContent,
  //     'communityGroupId': communityGroupId,
  //     'communityPostStatus': communityPostStatus,
  //     'communityPostImageFile': communityPostImageFile != null
  //         ? await MultipartFile.fromFile(
  //       communityPostImageFile!.path,
  //       filename: communityPostImageFile!.path.split('/').last,
  //     )
  //         : null,
  //   });
  // }

  /// Converts this model into `FormData` for Dio
  // Future<FormData> toFormData() async {
  //   final Map<String, dynamic> data = {
  //     'communityPostTitle': communityPostTitle,
  //     'communityPostContent': communityPostContent,
  //     'communityGroupId': communityGroupId,
  //     'communityPostStatus': communityPostStatus,
  //   };
  //
  //   if (communityPostImageFile != null) {
  //     final fileName = communityPostImageFile!.path.split('/').last;
  //
  //     // Determine MIME type from file extension
  //     final extension = fileName.toLowerCase().split('.').last;
  //     String mimeType;
  //     switch (extension) {
  //       case 'png':
  //         mimeType = 'image/png';
  //         break;
  //       case 'jpg':
  //       case 'jpeg':
  //         mimeType = 'image/jpeg';
  //         break;
  //       case 'gif':
  //         mimeType = 'image/gif';
  //         break;
  //       case 'webp':
  //         mimeType = 'image/webp';
  //         break;
  //       default:
  //         mimeType = 'image/png'; // Default fallback
  //     }
  //
  //     data['communityPostImageFile'] = await MultipartFile.fromFile(
  //       communityPostImageFile!.path,
  //       filename: fileName,
  //       contentType: MediaType.parse(mimeType),
  //     );
  //   }
  //
  //   // if (communityPostImageFile != null) {
  //   //   final fileName = communityPostImageFile!.path.split('/').last;
  //   //
  //   //   // Determine MIME type from file extension
  //   //   final extension = fileName.toLowerCase().split('.').last;
  //   //   String mimeType;
  //   //   switch (extension) {
  //   //     case 'png':
  //   //       mimeType = 'image/png';
  //   //       break;
  //   //     case 'jpg':
  //   //     case 'jpeg':
  //   //       mimeType = 'image/jpeg';
  //   //       break;
  //   //     case 'gif':
  //   //       mimeType = 'image/gif';
  //   //       break;
  //   //     case 'webp':
  //   //       mimeType = 'image/webp';
  //   //       break;
  //   //     default:
  //   //       mimeType = 'image/png'; // Default fallback
  //   //   }
  //   //
  //   //   data['communityPostImageFile'] = await MultipartFile.fromFile(
  //   //     communityPostImageFile!.path,
  //   //     filename: fileName,
  //   //     contentType: MediaType.parse(mimeType),
  //   //   );}
  //
  //   // if (communityPostImageFile != null) {
  //   //   final fileName = communityPostImageFile!.path.split('/').last;
  //   //   data['communityPostImageFile'] = await MultipartFile.fromFile(
  //   //     communityPostImageFile!.path,
  //   //     filename: fileName,
  //   //     // contentType: MediaType("image", "png"),
  //   //   );
  //   // }
  //   print("Sending form data...");
  //   print("Title: $communityPostTitle");
  //   print("Content: $communityPostContent");
  //   print("Status: $communityPostStatus");
  //   print("Group ID: $communityGroupId");
  //   print("Image: ${communityPostImageFile?.path}");
  //   print("File size: ${await communityPostImageFile!.length()}");
  //   // if (communityPostImageFile != null) {
  //   //   final extension = fileName.toLowerCase().split('.').last;
  //   //   print("Image MIME type: image/$extension");
  //   // }
  //
  //   return FormData.fromMap(data);
  // }
}