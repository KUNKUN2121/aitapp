import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/application/usecases/main_drawer_usecase.dart';
import 'package:aitapp/presentation/screens/campus_map.dart';
import 'package:aitapp/presentation/screens/course_registration.dart';
import 'package:aitapp/presentation/screens/settings.dart';
import 'package:aitapp/presentation/screens/syllabus_search.dart';
import 'package:aitapp/presentation/wighets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ホーム画面。外部サービス・学内情報・学生生活の各機能へ
/// アイコングリッドから素早く移動できるランチャー。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({required this.onSelectTab, super.key});

  /// お知らせ/時間割/時刻表など、同じ [BottomNavigationBar] のタブへ
  /// 切り替えるためのコールバック。引数はタブのインデックス。
  final void Function(int index) onSelectTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = MainDrawerUseCase(ref, context);

    final sections = <_HomeSection>[
      _HomeSection(
        title: '外部リンク',
        items: [
          _HomeItem(
            icon: Icons.laptop_mac,
            label: 'L-Cam',
            color: const Color(0xFF1976D2),
            external: true,
            onTap: usecase.loginCampus,
          ),
          _HomeItem(
            icon: Icons.cast_for_education,
            label: 'Moodle',
            color: const Color(0xFFF57C00),
            external: true,
            onTap: usecase.openMoodle,
          ),
          _HomeItem(
            icon: Icons.mail_outline,
            label: 'Office365',
            color: const Color(0xFFD32F2F),
            external: true,
            onTap: usecase.openOffice365,
          ),
        ],
      ),
      _HomeSection(
        title: '学生生活',
        items: [
          _HomeItem(
            icon: Icons.assignment,
            label: '履修/成績',
            color: const Color(0xFF3949AB),
            onTap: () => usecase.openWebView(const CourseRegistration()),
          ),
          _HomeItem(
            icon: Icons.search,
            label: 'シラバス検索',
            color: const Color(0xFF00838F),
            onTap: () => usecase.openSyllabusSearch(SyllabusSearchScreen()),
          ),
          _HomeItem(
            icon: Icons.map_rounded,
            label: '学内マップ',
            color: const Color(0xFF6D4C41),
            onTap: () => usecase.go(const CampusMap()),
          ),
        ],
      ),
      _HomeSection(
        title: 'アンケート',
        items: [
          _HomeItem(
            icon: Icons.assignment,
            label: '授業アンケート',
            color: const Color(0xFF7CB342),
            onTap: () => usecase.openWebLink(classEnqueteLink),
          ),
          _HomeItem(
            icon: Icons.assignment_turned_in,
            label: '授業評価\nアンケート',
            color: const Color(0xFF00ACC1),
            onTap: () => usecase.openWebLink(courseEvaluationLink),
          ),
          _HomeItem(
            icon: Icons.poll,
            label: '学内アンケート',
            color: const Color(0xFFC0CA33),
            onTap: () => usecase.openWebLink(enqueteContactLink),
          ),
        ],
      ),
      _HomeSection(
        title: 'その他',
        items: [
          _HomeItem(
            icon: Icons.settings,
            label: '設定',
            color: const Color(0xFF546E7A),
            onTap: () => usecase.go(const Settings()),
          ),
        ],
      ),
    ];

    return Column(
      children: [
        const AppBarWidget(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ホーム',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              for (final section in sections) _SectionView(section: section),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section});

  final _HomeSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
          child: Text(
            section.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            for (final item in section.items) _HomeTile(item: item),
          ],
        ),
      ],
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({required this.item});

  final _HomeItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(item.icon, color: item.color, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (item.external)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeSection {
  const _HomeSection({required this.title, required this.items});

  final String title;
  final List<_HomeItem> items;
}

class _HomeItem {
  const _HomeItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.external = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  /// 外部ブラウザで開く項目。右上に [Icons.open_in_new] を表示する。
  final bool external;
}
