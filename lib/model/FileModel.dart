import 'package:intl/intl.dart';

class FileSystemItem {
  final String name;
  final String path;
  final String lastModified;

  FileSystemItem({
    required this.name,
    required this.path,
    required this.lastModified,
  });
}

class FileModel extends FileSystemItem {
  final bool isDirectory;
  final bool isAzienda;

  FileModel({
    required String name,
    required String path,
    required String lastModified,
    required this.isDirectory,
    this.isAzienda = false,
  }) : super(name: name, path: path, lastModified: lastModified);

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      name: json['name'] ?? 'Unnamed File',
      path: json['path'] ?? '',
      lastModified: json['lastModified'] ?? 'Unknown',
      isDirectory: false,
    );
  }
}

class DirectoryModel extends FileSystemItem {
  final List<FileSystemItem> children;

  DirectoryModel({
    required String name,
    required String path,
    required this.children,
    required String lastModified,
  }) : super(name: name, path: path, lastModified: lastModified);

  factory DirectoryModel.fromJson(Map<String, dynamic> json) {
    var childrenList = (json['children'] as List)
        .map((item) => item['type'] == 'directory'
        ? DirectoryModel.fromJson(item)
        : FileModel.fromJson(item))
        .toList();

    return DirectoryModel(
      name: json['name'] ?? 'Unnamed Directory',
      path: json['path'] ?? '',
      lastModified: json['lastModified'] ?? 'Unknown',
      children: childrenList,
    );
  }
}

String formatLastModified(String lastModified) {
  String cleanedLastModified = lastModified.replaceAll(RegExp(r'\s+[A-Z]{2,4}\s\d{4}$'), '');
  final format = DateFormat('EEE MMM dd HH:mm:ss');
  DateTime dateTime;
  try {
    dateTime = format.parse(cleanedLastModified);
  } catch (e) {
    print('Error parsing date: $e');
    return 'Data non valida';
  }
  return DateFormat('dd/MM HH:mm').format(dateTime);
}



