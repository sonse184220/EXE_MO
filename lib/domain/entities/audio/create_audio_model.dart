// // import 'dart:io';
// // import 'package:dio/dio.dart';
// // import 'package:http_parser/http_parser.dart';
// // import 'package:mime/mime.dart';
// //
// // class CreateAudioModel {
// //   final String? audioTitle;
// //   final String? audioStatus;
// //   final File? audioFile;
// //   final File? audioThumbnailFile;
// //   final bool? audioIsPremium;
// //   final String? subAudioCategoryId;
// //
// //   CreateAudioModel({
// //     this.audioTitle,
// //     this.audioStatus,
// //     this.audioFile,
// //     this.audioThumbnailFile,
// //     this.audioIsPremium,
// //     this.subAudioCategoryId,
// //   });
// //
// //   factory CreateAudioModel.fromJson(Map<String, dynamic> json) {
// //     return CreateAudioModel(
// //       audioTitle: json['audioTitle'] as String?,
// //       audioStatus: json['audioStatus'] as String?,
// //       audioFile: json['audioFile'] != null ? File(json['audioFile']) : null,
// //       audioThumbnailFile: json['audioThumbnailFile'] != null
// //           ? File(json['audioThumbnailFile'])
// //           : null,
// //       audioIsPremium: json['audioIsPremium'] as bool?,
// //       subAudioCategoryId: json['subAudioCategoryId'] as String?,
// //     );
// //   }
// //
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'audioTitle': audioTitle,
// //       'audioStatus': audioStatus,
// //       'audioIsPremium': audioIsPremium,
// //       'subAudioCategoryId': subAudioCategoryId,
// //       'audioFile': audioFile?.path,
// //       'audioThumbnailFile': audioThumbnailFile?.path,
// //     };
// //   }
// //
// //   Future<FormData> toFormData() async {
// //     final Map<String, dynamic> data = {
// //       if (audioTitle != null) 'audioTitle': audioTitle,
// //       if (audioStatus != null) 'audioStatus': audioStatus,
// //       if (audioIsPremium != null) 'audioIsPremium': audioIsPremium,
// //       if (subAudioCategoryId != null) 'subAudioCategoryId': subAudioCategoryId,
// //     };
// //
// //     // Handle audio file (can be audio or video)
// //     if (audioFile != null) {
// //       final filePath = audioFile!.path;
// //       final fileName = filePath.split('/').last;
// //       final mimeType = lookupMimeType(filePath);
// //
// //       MediaType? mediaType;
// //       if (mimeType != null) {
// //         final parts = mimeType.split('/');
// //         mediaType = MediaType(parts[0], parts[1]);
// //       }
// //
// //       data['audioFile'] = await MultipartFile.fromFile(
// //         filePath,
// //         filename: fileName,
// //         contentType: mediaType,
// //       );
// //     }
// //
// //     // Handle thumbnail file (should be image)
// //     if (audioThumbnailFile != null) {
// //       final thumbnailPath = audioThumbnailFile!.path;
// //       final thumbnailName = thumbnailPath.split('/').last;
// //       final thumbnailMimeType = lookupMimeType(thumbnailPath);
// //
// //       MediaType? thumbnailMediaType;
// //       if (thumbnailMimeType != null) {
// //         final parts = thumbnailMimeType.split('/');
// //         thumbnailMediaType = MediaType(parts[0], parts[1]);
// //       }
// //
// //       data['audioThumbnailFile'] = await MultipartFile.fromFile(
// //         thumbnailPath,
// //         filename: thumbnailName,
// //         contentType: thumbnailMediaType,
// //       );
// //     }
// //
// //     return FormData.fromMap(data);
// //   }
// // }
//
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart';
//
// class CreateAudioModel {
//   final String? audioTitle;
//   final String? audioStatus;
//   final File? audioFile;
//   final File? audioThumbnailFile;
//   final bool? audioIsPremium;
//   final String? subAudioCategoryId;
//
//   CreateAudioModel({
//     this.audioTitle,
//     this.audioStatus,
//     this.audioFile,
//     this.audioThumbnailFile,
//     this.audioIsPremium,
//     this.subAudioCategoryId,
//   });
//
//   factory CreateAudioModel.fromJson(Map<String, dynamic> json) {
//     return CreateAudioModel(
//       audioTitle: json['audioTitle'] as String?,
//       audioStatus: json['audioStatus'] as String?,
//       audioFile: json['audioFile'] != null ? File(json['audioFile']) : null,
//       audioThumbnailFile: json['audioThumbnailFile'] != null
//           ? File(json['audioThumbnailFile'])
//           : null,
//       audioIsPremium: json['audioIsPremium'] as bool?,
//       subAudioCategoryId: json['subAudioCategoryId'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'audioTitle': audioTitle,
//       'audioStatus': audioStatus,
//       'audioIsPremium': audioIsPremium,
//       'subAudioCategoryId': subAudioCategoryId,
//       'audioFile': audioFile?.path,
//       'audioThumbnailFile': audioThumbnailFile?.path,
//     };
//   }
//
//   Future<FormData> toFormData() async {
//     final Map<String, dynamic> data = {
//       if (audioTitle != null) 'audioTitle': audioTitle,
//       if (audioStatus != null) 'audioStatus': audioStatus,
//       if (audioIsPremium != null) 'audioIsPremium': audioIsPremium,
//       if (subAudioCategoryId != null) 'subAudioCategoryId': subAudioCategoryId,
//     };
//
//     // Handle audio file (can be audio or video)
//     if (audioFile != null) {
//       final filePath = audioFile!.path;
//       final fileName = filePath.split('/').last;
//       final extension = fileName.toLowerCase().split('.').last;
//
//       // Determine the correct MIME type based on file extension
//       String mimeType;
//       if (['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'].contains(extension)) {
//         // Audio files - but ensure proper MIME type detection
//         final detectedMimeType = lookupMimeType(filePath);
//         mimeType = detectedMimeType ?? 'audio/$extension';
//       } else if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(extension)) {
//         // Video files
//         final detectedMimeType = lookupMimeType(filePath);
//         mimeType = detectedMimeType ?? 'video/$extension';
//       } else {
//         // Fallback - let mime package detect
//         mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
//       }
//
//       final parts = mimeType.split('/');
//       final mediaType = MediaType(parts[0], parts[1]);
//
//       data['audioFile'] = await MultipartFile.fromFile(
//         filePath,
//         filename: fileName,
//         contentType: mediaType,
//       );
//
//       // Debug print to verify MIME type
//       print('Audio file MIME type: $mimeType');
//     }
//
//     // Handle thumbnail file (should be image)
//     if (audioThumbnailFile != null) {
//       final thumbnailPath = audioThumbnailFile!.path;
//       final thumbnailName = thumbnailPath.split('/').last;
//       final extension = thumbnailName.toLowerCase().split('.').last;
//
//       // Ensure proper image MIME type
//       String mimeType;
//       switch (extension) {
//         case 'jpg':
//         case 'jpeg':
//           mimeType = 'image/jpeg';
//           break;
//         case 'png':
//           mimeType = 'image/png';
//           break;
//         case 'gif':
//           mimeType = 'image/gif';
//           break;
//         case 'webp':
//           mimeType = 'image/webp';
//           break;
//         case 'bmp':
//           mimeType = 'image/bmp';
//           break;
//         default:
//           mimeType = lookupMimeType(thumbnailPath) ?? 'image/jpeg';
//       }
//
//       final parts = mimeType.split('/');
//       final mediaType = MediaType(parts[0], parts[1]);
//
//       data['audioThumbnailFile'] = await MultipartFile.fromFile(
//         thumbnailPath,
//         filename: thumbnailName,
//         contentType: mediaType,
//       );
//
//       // Debug print to verify MIME type
//       print('Thumbnail file MIME type: $mimeType');
//     }
//
//     // Debug prints for form data
//     print('Form data being sent:');
//     print('Title: $audioTitle');
//     print('Status: $audioStatus');
//     print('IsPremium: $audioIsPremium');
//     print('SubCategoryId: $subAudioCategoryId');
//     if (audioFile != null) {
//       print('Audio file: ${audioFile!.path}');
//       print('Audio file size: ${await audioFile!.length()} bytes');
//     }
//     if (audioThumbnailFile != null) {
//       print('Thumbnail file: ${audioThumbnailFile!.path}');
//       print('Thumbnail file size: ${await audioThumbnailFile!.length()} bytes');
//     }
//
//     return FormData.fromMap(data);
//   }
// }

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CreateAudioModel {
  final String? audioTitle;
  final String? audioStatus;
  final File? audioFile;
  final File? audioThumbnailFile;
  final bool? audioIsPremium;
  final String? subAudioCategoryId;

  CreateAudioModel({
    this.audioTitle,
    this.audioStatus,
    this.audioFile,
    this.audioThumbnailFile,
    this.audioIsPremium,
    this.subAudioCategoryId,
  });

  factory CreateAudioModel.fromJson(Map<String, dynamic> json) {
    return CreateAudioModel(
      audioTitle: json['audioTitle'] as String?,
      audioStatus: json['audioStatus'] as String?,
      audioFile: json['audioFile'] != null ? File(json['audioFile']) : null,
      audioThumbnailFile: json['audioThumbnailFile'] != null
          ? File(json['audioThumbnailFile'])
          : null,
      audioIsPremium: json['audioIsPremium'] as bool?,
      subAudioCategoryId: json['subAudioCategoryId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioTitle': audioTitle,
      'audioStatus': audioStatus,
      'audioIsPremium': audioIsPremium,
      'subAudioCategoryId': subAudioCategoryId,
      'audioFile': audioFile?.path,
      'audioThumbnailFile': audioThumbnailFile?.path,
    };
  }

  Future<FormData> toFormData() async {
    final Map<String, dynamic> data = {
      if (audioTitle != null) 'audioTitle': audioTitle,
      if (audioStatus != null) 'audioStatus': audioStatus,
      if (audioIsPremium != null) 'audioIsPremium': audioIsPremium,
      if (subAudioCategoryId != null) 'subAudioCategoryId': subAudioCategoryId,
    };

    // Handle audio file (can be audio or video)
    if (audioFile != null) {
      final filePath = audioFile!.path;
      final fileName = filePath.split('/').last;
      final mimeType = lookupMimeType(filePath);

      MediaType? mediaType;
      if (mimeType != null) {
        final parts = mimeType.split('/');
        mediaType = MediaType(parts[0], parts[1]);
      }

      data['audioFile'] = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: mediaType,
      );
    }

    // Handle thumbnail file (should be image)
    if (audioThumbnailFile != null) {
      final thumbnailPath = audioThumbnailFile!.path;
      final thumbnailName = thumbnailPath.split('/').last;
      final thumbnailMimeType = lookupMimeType(thumbnailPath);

      MediaType? thumbnailMediaType;
      if (thumbnailMimeType != null) {
        final parts = thumbnailMimeType.split('/');
        thumbnailMediaType = MediaType(parts[0], parts[1]);
      }

      data['audioThumbnailFile'] = await MultipartFile.fromFile(
        thumbnailPath,
        filename: thumbnailName,
        contentType: thumbnailMediaType,
      );
    }

    return FormData.fromMap(data);
  }
}