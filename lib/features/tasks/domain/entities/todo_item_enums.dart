enum TaskPriority {
  low(0, 'Low', 'Düşük'),
  medium(1, 'Medium', 'Orta'),
  high(2, 'High', 'Yüksek'),
  urgent(3, 'Urgent', 'Acil');

  final int value;
  final String apiName;
  final String displayName;

  const TaskPriority(this.value, this.apiName, this.displayName);

  static TaskPriority fromServer(dynamic raw) {
    if (raw == null) return TaskPriority.medium;
    if (raw is int) {
      return TaskPriority.values.firstWhere(
        (p) => p.value == raw,
        orElse: () => TaskPriority.medium,
      );
    }
    final str = raw.toString().trim().toLowerCase();
    switch (str) {
      case 'low':
      case '0':
        return TaskPriority.low;
      case 'high':
      case '2':
        return TaskPriority.high;
      case 'urgent':
      case '3':
        return TaskPriority.urgent;
      case 'medium':
      case '1':
      default:
        return TaskPriority.medium;
    }
  }
}

enum TaskStatus {
  open(0, 'Open', 'Açık'),
  completed(1, 'Completed', 'Tamamlandı');

  final int value;
  final String apiName;
  final String displayName;

  const TaskStatus(this.value, this.apiName, this.displayName);

  bool get isCompleted => this == TaskStatus.completed;

  static TaskStatus fromServer(dynamic raw) {
    if (raw == null) return TaskStatus.open;
    if (raw is int) {
      return TaskStatus.values.firstWhere(
        (s) => s.value == raw,
        orElse: () => TaskStatus.open,
      );
    }
    final str = raw.toString().trim().toLowerCase();
    if (str == 'completed' || str == '1') {
      return TaskStatus.completed;
    }
    return TaskStatus.open;
  }
}

enum TaskFilterType {
  all(0, 'Tümü'),
  onlyMine(1, 'Bana Ait'),
  sharedWithMe(2, 'Paylaşılanlar'),
  sharedByMe(3, 'Paylaştıklarım');

  final int value;
  final String displayName;

  const TaskFilterType(this.value, this.displayName);

  static TaskFilterType fromInt(int? val) {
    if (val == null) return TaskFilterType.all;
    return TaskFilterType.values.firstWhere(
      (f) => f.value == val,
      orElse: () => TaskFilterType.all,
    );
  }
}

enum TaskSortBy {
  createdAt('createdAt', 'Oluşturulma Tarihi'),
  dueDate('dueDate', 'Bitiş Tarihi'),
  title('title', 'Başlık'),
  priority('priority', 'Öncelik');

  final String apiValue;
  final String displayName;

  const TaskSortBy(this.apiValue, this.displayName);
}

enum SortOrder {
  desc('desc', 'Azalan'),
  asc('asc', 'Artan');

  final String apiValue;
  final String displayName;

  const SortOrder(this.apiValue, this.displayName);
}
