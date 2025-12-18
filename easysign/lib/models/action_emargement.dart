class ActionEmargement {
  final int id;
  final int presenceId;
  final String typeAction;
  final String timestamp;

  ActionEmargement({
    required this.id,
    required this.presenceId,
    required this.typeAction,
    required this.timestamp,
  });

  factory ActionEmargement.fromJson(Map<String, dynamic> json) =>
      ActionEmargement(
        id: json['id'],
        presenceId: json['presence_id'],
        typeAction: json['type_action'],
        timestamp: json['timestamp'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'presence_id': presenceId,
    'type_action': typeAction,
    'timestamp': timestamp,
  };
}
