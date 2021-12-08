class FolderItem {
  final String folder;

  FolderItem({required this.folder});

  FolderItem.fromJson(Map<String, dynamic> json)
      : folder = json['folder'];

  Map<String, dynamic> toJson() {
    return {
      'folder': folder,
    };
  }
}