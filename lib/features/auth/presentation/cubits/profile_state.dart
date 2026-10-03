import 'package:equatable/equatable.dart';

import '../../data/models/user_profile_response_dto.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final bool isDeleting;
  final UserProfileResponseDto? profile;
  final String? errorMessage;
  final bool deletionSuccess;
  final String? deletionError;

  const ProfileState({
    this.isLoading = false,
    this.isDeleting = false,
    this.profile,
    this.errorMessage,
    this.deletionSuccess = false,
    this.deletionError,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isDeleting,
    UserProfileResponseDto? profile,
    String? errorMessage,
    bool? deletionSuccess,
    String? deletionError,
    bool clearError = false,
    bool clearDeletionError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      deletionSuccess: deletionSuccess ?? this.deletionSuccess,
      deletionError: clearDeletionError ? null : (deletionError ?? this.deletionError),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isDeleting,
        profile,
        errorMessage,
        deletionSuccess,
        deletionError,
      ];
}
