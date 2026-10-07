import 'package:clean_archi_project1/core/error/failure.dart';
import 'package:clean_archi_project1/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:clean_archi_project1/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:clean_archi_project1/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:clean_archi_project1/features/daily_news/domain/entities/article.dart';
import 'package:clean_archi_project1/features/daily_news/domain/repository/article_repository.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'article_repository_test.mocks.dart';
import 'helper/test_data.dart';

@GenerateMocks([NewsApiService, ArticleDao])
void main() {
  late ArticleRepository articleRepository;
  late MockNewsApiService mockApi;
  late MockArticleDao mockDao;

  setUp(() {
    mockApi = MockNewsApiService();
    mockDao = MockArticleDao();
    articleRepository = ArticleRepositoryImpl(mockApi, mockDao);
  });

  //apiService
  //success (get all articles)
  test('Return list of articles if success ', () async {
    when(mockApi.getNewsArticle(
      apiKey: anyNamed('apiKey'),
      country: anyNamed('country'),
      category: anyNamed('category'),
    )).thenAnswer((_) async => TestData.testArticleDto);
    final result = await articleRepository.getNewsArticles();

    expect(result, isA<Right>());
    expect((result as Right).value, TestData.testArticle);
    verify(mockApi.getNewsArticle(
      apiKey: anyNamed('apiKey'),
      country: anyNamed('country'),
      category: anyNamed('category'),
    )).called(1);
  });

  //failure (get all articles)
  test('Return list of articles if fail ', () async {
    when(mockApi.getNewsArticle(
      apiKey: anyNamed('apiKey'),
      country: anyNamed('country'),
      category: anyNamed('category'),
    )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        response: Response(
            requestOptions: RequestOptions(path: '/top-headlines'),
            statusCode: 400,
            data: {'message': 'Article Error'})));
    final result = await articleRepository.getNewsArticles();

    expect(result, isA<Left>());
    expect((result as Left).value, isA<ServerFailure>());
    expect((result as Left).value.errorMessage, 'Article Error');
    verify(mockApi.getNewsArticle(
      apiKey: anyNamed('apiKey'),
      country: anyNamed('country'),
      category: anyNamed('category'),
    )).called(1);
  });

  //DAO
  //success (save article)
  test('Save Article Successfully', ()async {
    when(mockDao.insertArticle(any)).thenAnswer((_) async {});

    final result = await articleRepository.saveArticle(TestData.testArticle[0]);

    expect(result, isA<Right>());
    expect((result as Right).value, isNull);

    verify(mockDao.insertArticle(any)).called(1);
  });

  //failure (save article)
  test('Save Article Failure', () async {
    when(mockDao.insertArticle(any)).thenThrow(Exception('DB error'));

    final result = await articleRepository.saveArticle(TestData.testArticle[0]);

    expect(result, isA<Left>());
    expect((result as Left).value, isA<CacheFailure>());

    verify(mockDao.insertArticle(any)).called(1);
  });

  //success (delete article)
  test('Delete Article Successfully', ()async {
    when(mockDao.deleteArticle(any)).thenAnswer((_) async {});

    final result = await articleRepository.deleteArticle(TestData.testArticle[0]);

    expect(result, isA<Right>());
    expect((result as Right).value, isNull);

    verify(mockDao.deleteArticle(any)).called(1);
  });

  //failure (delete article)
  test('Delete Article Failure', () async {
    when(mockDao.deleteArticle(any)).thenThrow(Exception('DB error'));

    final result = await articleRepository.deleteArticle(TestData.testArticle[0]);

    expect(result, isA<Left>());
    expect((result as Left).value, isA<CacheFailure>());

    verify(mockDao.deleteArticle(any)).called(1);
  });

  //success (get saved article)
  test('Get List of Saved Articles Successfully', ()async {
    when(mockDao.getAllArticles()).thenAnswer((_) => Stream.value(TestData.testArticleEntity));

    final stream = articleRepository.getSavedArticles();

    final result = await stream.first;

    expect(result, isA<Right<Failure, List<Article>>>());

    result.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (articles) => expect(articles, TestData.testArticle),
    );

    // 5. Verify DAO call
    verify(mockDao.getAllArticles()).called(1);
  });

  //failure (get saved article)
  test('Get List of Saved Articles Failure', ()async {
    when(mockDao.getAllArticles()).thenAnswer((_) => Stream.error(Exception('DB error')));

    final result = await articleRepository.getSavedArticles().first;

    expect(result, isA<Left<Failure, List<Article>>>());
    result.fold(
          (failure) {
        expect(failure, isA<CacheFailure>());
        expect(failure.errorMessage, contains('DB error'));
      },
          (articles) => fail('Expected Left, got Right'),
    );

    verify(mockDao.getAllArticles()).called(1);
  });
}