import 'package:clean_archi_project1/features/daily_news/data/data_sources/local/models/articleEntity.dart';
import 'package:floor/floor.dart';

@dao
abstract class ArticleDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertArticle(ArticleEntity article);

  @Query("SELECT * FROM articles")
  Stream<List<ArticleEntity>> getAllArticles();

  @delete
  Future<void> deleteArticle(ArticleEntity article);
}