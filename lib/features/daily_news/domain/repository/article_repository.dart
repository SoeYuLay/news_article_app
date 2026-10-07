import 'package:clean_archi_project1/core/error/failure.dart';
import 'package:clean_archi_project1/features/daily_news/domain/entities/article.dart';
import 'package:either_dart/either.dart';

abstract class ArticleRepository {
  //Remote
  // Future<DataState<List<Article>>> getNewsArticles();
  Future<Either<Failure, List<Article>>> getNewsArticles();

  //Local
  Future<Either<Failure, void>> saveArticle(Article article);
  Stream<Either<Failure, List<Article>>> getSavedArticles();
  Future<Either<Failure, void>> deleteArticle(Article article);
}