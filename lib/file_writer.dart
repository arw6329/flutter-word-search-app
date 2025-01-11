import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
}

Future<String> readFile(String fileName) async {
    final file = File('${await _localPath}/$fileName');
    return file.readAsString();
}

Future<void> writeFile(String fileName, String content) async {
    final file = File('${await _localPath}/$fileName');
    await file.writeAsString(content);
}

Future<bool> fileExists(String fileName) async {
    final file = File('${await _localPath}/$fileName');
    return file.exists();
}

Future<bool> directoryExists(String filePath) async {
    final directory = Directory('${await _localPath}/$filePath');
    return directory.exists();
}

Future<void> mkdir(String filePath) async {
    final directory = Directory('${await _localPath}/$filePath');
    await directory.create();
}

Future<void> deleteFile(String fileName) async {
    final file = File('${await _localPath}/$fileName');
    await file.delete();
}
