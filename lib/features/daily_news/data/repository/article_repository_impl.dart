// import 'dart:io';
// import 'package:clean_archi_project1/core/resources/constants/constants.dart';
// import 'package:clean_archi_project1/core/resources/data_state.dart';
// import 'package:clean_archi_project1/features/daily_news/data/data_sources/remote/news_api_service.dart';
// import 'package:clean_archi_project1/features/daily_news/domain/entities/article.dart';
// import 'package:clean_archi_project1/features/daily_news/domain/repository/article_repository.dart';
// import 'package:dio/dio.dart';

// class ArticleRepositoryImpl implements ArticleRepository {
//   final NewsApiService _newsApiService;
//   ArticleRepositoryImpl(this._newsApiService);

//   @override
//   Future<DataState<List<Article>>> getNewsArticles() async {
//     try{
//     final httpResponse = await _newsApiService.getNewsArticle(
//       apiKey: newsAPIKey,
//       country: countryQuery,
//       category: categoryQuery,
//     );

//     if(httpResponse.statusCode == HttpStatus.ok) {
//       return DataSuccess(httpResponse.data!);
//     } else {
//       return DataFailed(
//         DioException(
//           requestOptions: httpResponse.requestOptions,
//           response: httpResponse,
//           error: httpResponse.statusMessage ?? 'Failed to fetch articles',
//           type: DioExceptionType.badResponse,
//         ),
//       );
//     }
//     } on DioException catch (e) {
//       return DataFailed(e);
//     }
//   }
// }

import 'package:clean_archi_project1/core/error/failure.dart';
import 'package:clean_archi_project1/core/resources/constants/constants.dart';
import 'package:clean_archi_project1/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:clean_archi_project1/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:clean_archi_project1/features/daily_news/data/mappers/article_mapper.dart';
import 'package:clean_archi_project1/features/daily_news/domain/entities/article.dart';
import 'package:clean_archi_project1/features/daily_news/domain/repository/article_repository.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  // final AppDatabase _appDatabase;
  final ArticleDao _articleDao;
  ArticleRepositoryImpl(this._newsApiService, this._articleDao);

  @override
  Future<Either<Failure, List<Article>>> getNewsArticles() async {
    try {
      final articlesDto = await _newsApiService.getNewsArticle(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      //map DTO to Domain
      final articles = articlesDto.map((dto) => dto.toDomain()).toList();

      return Right(articles);

    } on DioException {
      return Left(ServerFailure('Article Error'));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

   @override
     Future<Either<Failure, void>> deleteArticle(Article article) async {
    try {
      final entity = article.toDb();
      await _articleDao.deleteArticle(entity);
      return const Right(null); // success, no data to return
    } catch (e) {
      return Left(CacheFailure(e.toString())); // failure branch
    }
  }

  @override
  Stream<Either<Failure, List<Article>>> getSavedArticles() async* {
    try {
      await for (final entities in _articleDao.getAllArticles()) {
        final articles = entities.map((e) => e.toDomain()).toList();
        yield Right(articles);
      }
    } catch (e) {
      yield Left(CacheFailure(e.toString()));
    }
  }
  
  @override
 Future<Either<Failure, void>> saveArticle(Article article) async {
    try {
      final entity = article.toDb();
      await _articleDao.insertArticle(entity);
      return const Right(null); // success, no data to return
    } catch (e) {
      return Left(CacheFailure(e.toString())); // failure branch
    }
  }

}
