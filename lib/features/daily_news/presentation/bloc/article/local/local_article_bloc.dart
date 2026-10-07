import 'package:clean_archi_project1/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:clean_archi_project1/features/daily_news/domain/usecases/remove_article.dart';
import 'package:clean_archi_project1/features/daily_news/domain/usecases/save_article.dart';
import 'package:clean_archi_project1/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:clean_archi_project1/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalArticleBloc extends Bloc<LocalArticleEvent, LocalArticleState> {
  final GetSavedArticleUseCase _getSavedArticleUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;

  LocalArticleBloc(
    this._getSavedArticleUseCase,
    this._saveArticleUseCase,
    this._removeArticleUseCase,
  ) : super(const LocalArticleLoading()) {
    on<GetSavedArticles>(onGetSavedArticles);
    on<RemoveArticle>(onRemoveArticle);
    on<SaveArticle>(onSaveArticle);
  }

  void onGetSavedArticles(
      GetSavedArticles event, Emitter<LocalArticleState> emit) async {
    await emit.forEach(
        _getSavedArticleUseCase(), 
        onData: (result){
          return result.fold(
              (failure) => LocalArticleError(failure.errorMessage),
              (articles) {
                if(articles.isNotEmpty){
                  return LocalArticleDone(articles);
                }else{
                  return const LocalArticleEmpty('No Saved Articles');
                }
              }
          );
        },
      onError: (error, stackTrace) => LocalArticleError(error.toString())
    );
  }

  void onRemoveArticle(
      RemoveArticle removeArticle, Emitter<LocalArticleState> emit) async {
    await _removeArticleUseCase(params: removeArticle.article);
  }

  void onSaveArticle(
      SaveArticle saveArticle, Emitter<LocalArticleState> emit) async {
    await _saveArticleUseCase(params: saveArticle.article);
  }
}
