import 'package:aastu_map/data/datasources/community_local_data_source.dart';
import 'package:aastu_map/data/datasources/community_remote_data_source.dart';
import 'package:aastu_map/data/models/club_model.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class GetAllCommunity {
  final CommunityLocalDataSource localDataSource;
  final CommunityRemoteDataSource remoteDataSource;

  final InternetConnectionChecker internetConnectionChecker = InternetConnectionChecker.createInstance();

  GetAllCommunity({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  Future<List<ClubModel>> call() async {
    try {
      // Check for internet connectivity
      bool isConnected = await internetConnectionChecker.hasConnection;

      if (isConnected) {
        // If connected to the internet, fetch from the remote data source
        return await remoteDataSource.getAllCommunities();
      } else {
        // If no internet, fetch from the local data source
        return await localDataSource.getAllCommunities();
      }
    } catch (e) {
      return []; // Return empty list on error
    }
  }
}
