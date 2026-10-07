import 'package:clean_archi_project1/core/error/failure.dart';
import 'package:clean_archi_project1/features/daily_news/domain/entities/article.dart';
import 'package:clean_archi_project1/features/daily_news/domain/repository/article_repository.dart';
import 'package:either_dart/either.dart';

import '../../../../core/usecase/usecase.dart';

class GetSavedArticleUseCase implements StreamUseCase<Either<Failure, List<Article>>, void>{
  final ArticleRepository _articleRepository;

  GetSavedArticleUseCase(this._articleRepository);

  @override
  Stream<Either<Failure, List<Article>>> call({void params}) {
    return _articleRepository.getSavedArticles();
  }

}