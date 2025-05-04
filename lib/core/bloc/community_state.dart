part of 'community_bloc.dart';

enum CommunityStatus { initial, loading, loaded, error }
class CommunityState extends Equatable {
  final List<ClubModel> communities;
  final CommunityStatus status; 
  const CommunityState({ this.communities = const [], this.status= CommunityStatus.initial });

  CommunityState copyWith({
    List<ClubModel>? communities,
    CommunityStatus? status,
  }) {
    return CommunityState(
      communities: communities ?? this.communities,
      status: status ?? this.status,
    );
  }
  
  @override
  List<Object> get props => [communities, status];
}

