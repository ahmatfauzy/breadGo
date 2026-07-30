class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final bool? needsVerification;
  final String? email;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.needsVerification,
    this.email,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'],
      needsVerification: json['needsVerification'] as bool?,
      email: json['email'] as String?,
    );
  }
}
