import 'package:shiori/domain/models/dtos.dart';

typedef ProgressChanged = void Function(double);

abstract class ApiService {
  Future<String> getChangelog(String defaultValue);

  Future<ApiResponseDto<ResourceDiffResponseDto?>> checkForUpdates(String currentAppVersion, int currentResourcesVersion);

  Future<bool> downloadAsset(String keyName, String destPath);
}
