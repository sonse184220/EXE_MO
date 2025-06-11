import 'dart:io';

import 'package:dio/dio.dart';

class CreateAudioModel {
  final String audioTitle;
  final String audioStatus;
  final File audioFile;
  final File audioThumbnailFile;
  final bool audioIsPremium;
  final String subAudioCategoryId;

  CreateAudioModel({
    required this.audioTitle,
    required this.audioStatus,
    required this.audioFile,
    required this.audioThumbnailFile,
    required this.audioIsPremium,
    required this.subAudioCategoryId,
  });

  factory CreateAudioModel.fromJson(Map<String, dynamic> json) {
    return CreateAudioModel(
      audioTitle: json['audioTitle'],
      audioStatus: json['audioStatus'],
      audioFile: File(json['audioFile']), // This assumes file path is provided
      audioThumbnailFile: File(json['audioThumbnailFile']), // Same here
      audioIsPremium: json['audioIsPremium'],
      subAudioCategoryId: json['subAudioCategoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioTitle': audioTitle,
      'audioStatus': audioStatus,
      'audioIsPremium': audioIsPremium,
      'subAudioCategoryId': subAudioCategoryId,
      'audioFile': audioFile.path,
      'audioThumbnailFile': audioThumbnailFile.path,
    };
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'audioTitle': audioTitle,
      'audioStatus': audioStatus,
      'audioIsPremium': audioIsPremium,
      'subAudioCategoryId': subAudioCategoryId,
      'audioFile': await MultipartFile.fromFile(
        audioFile.path,
        filename: audioFile.path.split('/').last,
      ),
      'audioThumbnailFile': await MultipartFile.fromFile(
        audioThumbnailFile.path,
        filename: audioThumbnailFile.path.split('/').last,
      ),
    });
  }
}