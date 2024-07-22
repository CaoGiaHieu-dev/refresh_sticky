import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:refresh_sticky/refresh_sticky.dart';

const refreshPhysic = AlwaysScrollableScrollPhysics(
  parent: BouncingScrollPhysics(),
);
void main() {
  group('RefreshSticky', () {
    testWidgets('should create a RefreshSticky widget with ListView',
        (tester) async {
      var onRefreshCalled = false;
      Future<void> mockOnRefresh() async {
        onRefreshCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshSticky(
              builder: (context, controller) => ListView.builder(
                itemCount: 10,
                physics: refreshPhysic,
                itemBuilder: (context, index) => Text('Item $index'),
                controller: controller,
              ),
              onRefresh: mockOnRefresh,
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(RefreshSticky),
        const Offset(0, 400),
        800,
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(onRefreshCalled, isTrue);
    });

    testWidgets('should move to the first position after refresh',
        (tester) async {
      var onRefreshCalled = false;
      Future<void> mockOnRefresh() async {
        onRefreshCalled = true;
      }

      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshSticky(
              controller: scrollController,
              builder: (context, controller) => ListView.builder(
                itemCount: 10,
                physics: refreshPhysic,
                itemBuilder: (context, index) => Text('Item $index'),
                controller: controller,
              ),
              onRefresh: mockOnRefresh,
              moveToFirstAfterComplete: true,
            ),
          ),
        ),
      );

      scrollController.jumpTo(scrollController.position.maxScrollExtent);

      await tester.pump(const Duration(seconds: 3));

      await tester.fling(
        find.byType(RefreshSticky),
        const Offset(0, 400),
        800,
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(scrollController.offset, equals(0.0));
      expect(onRefreshCalled, isTrue);
    });

    testWidgets('should not move to the first position after refresh',
        (tester) async {
      Future<void> mockOnRefresh() async {}

      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshSticky(
              controller: scrollController,
              builder: (context, controller) => ListView.builder(
                itemCount: 200,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                ),
                controller: controller,
              ),
              onRefresh: mockOnRefresh,
              moveToFirstAfterComplete: false,
            ),
          ),
        ),
      );

      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      await tester.pump(const Duration(seconds: 3));

      await tester.fling(
        find.byType(RefreshSticky),
        const Offset(0, 400),
        800,
      );

      await tester.pump(const Duration(seconds: 3));

      await tester.pump(const Duration(seconds: 3));

      await tester.pump(const Duration(seconds: 3));

      expect(scrollController.offset, isNot(equals(0.0)));
    });

    testWidgets(
        'should show the pre-loading animation when the user scrolls up',
        (tester) async {
      Future<void> mockOnRefresh() async {}

      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshSticky(
              controller: scrollController,
              builder: (context, controller) => ListView.builder(
                itemCount: 200,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                ),
                controller: controller,
              ),
              onRefresh: mockOnRefresh,
              moveToFirstAfterComplete: false,
              preLoadingBuilder: (context) => const Icon(Icons.arrow_upward),
            ),
          ),
        ),
      );

      scrollController.jumpTo(-50);
      await tester.pump();

      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets(
        'should show the loading builder when the loading animation is in progress',
        (tester) async {
      Future<void> mockOnRefresh() async {}
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RefreshSticky(
              controller: scrollController,
              builder: (context, controller) => ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                ),
                controller: controller,
              ),
              onRefresh: mockOnRefresh,
              loadingBuilder: (context) => const Icon(Icons.refresh),
            ),
          ),
        ),
      );

      scrollController.jumpTo(-50);
      await tester.pump();

      await tester.fling(
        find.byType(RefreshSticky),
        const Offset(0, 400),
        800,
      );

      await tester.pump();

      expect(find.byType(Icon), findsOneWidget);
    });
  });
}
