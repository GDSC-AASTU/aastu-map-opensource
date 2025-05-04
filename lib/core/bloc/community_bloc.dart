import 'dart:async';

import 'package:aastu_map/data/models/club_model.dart';
import 'package:aastu_map/data/repository/get_all_community.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'community_event.dart';
part 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  GetAllCommunity getAllCommunities;
  CommunityBloc({required this.getAllCommunities}) : super(CommunityState()) {
    on<GetAllCommunitiesEvent>(_getAllCommunities);
  }

  FutureOr<void> _getAllCommunities(
      GetAllCommunitiesEvent event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.loading));
    
    final community = await getAllCommunities.call();

    if (community.isNotEmpty) {
      emit(state.copyWith(
          communities: community, status: CommunityStatus.loaded));
    } else {
      emit(state.copyWith(status: CommunityStatus.error));
    }
  }
}
