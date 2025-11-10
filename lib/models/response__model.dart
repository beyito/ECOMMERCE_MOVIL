class ResponseModel {
  final int? status;
  final int? error;
  final String? message;
  final dynamic values;

  ResponseModel({
    this.status,
    this.error,
    this.message,
    this.values,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      values: json['values'],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'error': error,
        'message': message,
        'values': values,
      };
}
